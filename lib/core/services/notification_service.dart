import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// إشعارات رسائل الشات.
///
/// - الجهاز بيسجّل الـ FCM token بتاعه في: users/{uid}/fcmTokens/{token}
/// - الـ Cloud Function (index.js) بتبعت الإشعار لما رسالة جديدة تتكتب.
/// - لما التطبيق مقفول أو في الخلفية: السيستم بيعرض الإشعار لوحده.
/// - لما التطبيق مفتوح: بنعرض إشعار محلي (إلا لو المحادثة نفسها مفتوحة).
///
/// حطه في: lib/core/services/notification_service.dart
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'chat_messages', // لازم يطابق channelId في الـ Cloud Function
    'رسائل المحادثات',
    description: 'إشعارات الرسائل الجديدة',
    importance: Importance.high,
  );

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _paused = false; // بيتفعّل بعد تسجيل الخروج
  String? _currentToken;

  void Function(Map<String, dynamic> data)? _onOpenChat;
  Map<String, dynamic>? _pendingTap;

  /// uid الشخص اللي محادثته مفتوحة دلوقتي (عشان منظهرش إشعار ليها)
  String? activeChatUid;

  // ---------------------------------------------------------------------------
  // Setup
  // ---------------------------------------------------------------------------

  /// نادي عليها بعد تسجيل الدخول (من HomeScreen). آمنة تتنادى أكتر من مرة.
  Future<void> init() async {
    _paused = false;

    if (_initialized) {
      await _saveCurrentToken();
      return;
    }
    _initialized = true;

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Notifications permission denied');
      return;
    }

    // على iOS: منعرضش الإشعار تلقائيًا والتطبيق مفتوح، إحنا اللي بنتحكم
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);
          _handleTap(data);
        } catch (_) {}
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _saveCurrentToken();
    _fcm.onTokenRefresh.listen(_saveToken);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // ضغط على الإشعار والتطبيق في الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _handleTap(m.data));

    // ضغط على الإشعار والتطبيق كان مقفول
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleTap(initial.data);
  }

  // ---------------------------------------------------------------------------
  // Token
  // ---------------------------------------------------------------------------

  Future<void> _saveCurrentToken() async {
    try {
      // على iOS الـ APNs token ممكن يتأخر ثواني بعد أول تشغيل
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        for (var i = 0; i < 10 && await _fcm.getAPNSToken() == null; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      final token = await _fcm.getToken();
      if (token != null) await _saveToken(token);
    } catch (e) {
      debugPrint('FCM getToken error: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    if (_paused) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _currentToken = token;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(token)
          .set({
            'token': token,
            'platform': defaultTargetPlatform.name,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Save FCM token error: $e');
    }
  }

  /// نادي عليها *قبل* signOut، عشان اليوزر القديم يبطل تجيله إشعارات
  /// على الجهاز ده.
  Future<void> removeToken() async {
    _paused = true;

    final uid = FirebaseAuth.instance.currentUser?.uid;

    try {
      final token = _currentToken ?? await _fcm.getToken();

      if (uid != null && token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('fcmTokens')
            .doc(token)
            .delete();
      }

      await _fcm.deleteToken();
    } catch (e) {
      debugPrint('Remove FCM token error: $e');
    }

    _currentToken = null;
  }

  // ---------------------------------------------------------------------------
  // Foreground message
  // ---------------------------------------------------------------------------

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final data = message.data;

    if (data['type'] != 'chat') return;

    // المحادثة دي مفتوحة قدامه، مفيش داعي للإشعار
    if (data['senderId'] != null && data['senderId'] == activeChatUid) return;

    final title = message.notification?.title ?? data['senderName'] ?? 'رسالة';
    final body = message.notification?.body ?? '';

    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  // ---------------------------------------------------------------------------
  // Tap handling
  // ---------------------------------------------------------------------------

  /// سجّل الدالة اللي بتفتح الشات (من HomeScreen).
  /// لو المستخدم فتح التطبيق من إشعار، الدالة بتتنفّذ أول ما تتسجل.
  void attachTapHandler(void Function(Map<String, dynamic> data) onOpenChat) {
    _onOpenChat = onOpenChat;

    final pending = _pendingTap;
    if (pending != null) {
      _pendingTap = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => onOpenChat(pending));
    }
  }

  void detachTapHandler() => _onOpenChat = null;

  void _handleTap(Map<String, dynamic> data) {
    if (data['type'] != 'chat') return;

    final handler = _onOpenChat;
    if (handler == null) {
      _pendingTap = data;
      return;
    }
    handler(data);
  }
}