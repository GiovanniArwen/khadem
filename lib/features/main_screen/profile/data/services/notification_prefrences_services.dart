
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPreferencesService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationPreferencesService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> get _userDocument {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('يجب تسجيل الدخول أولاً.');
    }

    return _firestore.collection('users').doc(user.uid);
  }

  Future<Map<String, bool>> getPreferences() async {
    final snapshot = await _userDocument.get();

    final data = snapshot.data() ?? {};
    final settings =
        data['notificationSettings'] as Map<String, dynamic>? ?? {};

    return {
      'chatMessages': settings['chatMessages'] as bool? ?? true,
      'appUpdates': settings['appUpdates'] as bool? ?? true,
    };
  }

  Future<void> updatePreference({
    required String key,
    required bool enabled,
  }) async {
    const supportedKeys = {'chatMessages', 'appUpdates'};

    if (!supportedKeys.contains(key)) {
      throw ArgumentError('نوع الإشعار غير مدعوم.');
    }

    await _userDocument.set({
      'notificationSettings': {key: enabled},
    }, SetOptions(merge: true));
  }
}
