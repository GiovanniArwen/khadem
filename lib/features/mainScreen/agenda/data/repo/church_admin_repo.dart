import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khadem/features/auth/data/models/church_admin_model.dart';

class ChurchAdminRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<ChurchAdminModel?> getChurchAdmin(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChurchAdminModel.fromJson({...doc.data()!, 'uid': doc.id});
    });
  }

  Future<void> updateChurchAdmin({
    required String uid,
    required ChurchAdminModel admin,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(admin.toUpdateData(), SetOptions(merge: true));
  }
}
