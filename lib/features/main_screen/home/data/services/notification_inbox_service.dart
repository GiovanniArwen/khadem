import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationInboxService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationInboxService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _notifications {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('يجب تسجيل الدخول أولاً.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchNotifications() {
    return _notifications
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<int> watchUnreadCount() {
    return _notifications
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAsRead(String notificationId) async {
    await _notifications.doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead() async {
    final unread = await _notifications
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();

    for (final document in unread.docs) {
      batch.update(document.reference, {'isRead': true});
    }

    if (unread.docs.isNotEmpty) {
      await batch.commit();
    }
  }
}