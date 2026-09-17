import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khadem/features/mainScreen/servants/data/models/servant_model.dart';
import 'package:khadem/features/mainScreen/servants/data/models/servant_update.dart';

class ServantRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ServantModel>> getApprovedServants() {
    return _firestore
        .collection('users')
        .where('isServant', isEqualTo: true)
        .where('servantStatus', isEqualTo: 'approved')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return ServantModel.fromJson({...doc.data(), 'uid': doc.id});
          }).toList(),
        );
  }

  // بروفايل الخادم لايف (تستخدمها شاشة الحساب وشاشة تفاصيل الخادم)
  Stream<ServantModel?> getServant(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ServantModel.fromJson({...doc.data()!, 'uid': doc.id});
    });
  }

  Future<void> updateServant({
    required String uid,
    required ServantModel servant,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(servant.toUpdateData(), SetOptions(merge: true));
  }

  Future<void> setNoteVisibility({
    required String uid,
    required bool isVisible,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'isNoteVisible': isVisible,
    });
  }

  // ... جوه الكلاس
  Future<void> updateServantFields({
    required String uid,
    required ServantUpdate update,
  }) async {
    final data = update.toUpdateData();
    if (data.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }
}
