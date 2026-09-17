import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khadem/features/auth/data/models/church_admin_model.dart';
import 'package:khadem/features/mainScreen/servants/data/models/servant_model.dart';

import '../models/chat_user_model.dart';

class UserProfileRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ChatUserModel?> getChatUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;

    final isServant = data['isServant'] == true;
    final isChurchAdmin = data['isChurchAdmin'] == true;

    ServantModel? servant;
    ChurchAdminModel? churchAdmin;

    if (isServant) {
      servant = ServantModel.fromJson({...data, 'uid': doc.id});
    }

    if (isChurchAdmin) {
      churchAdmin = ChurchAdminModel.fromJson({...data, 'uid': doc.id});
    }

    return ChatUserModel(
      uid: uid,
      isServant: isServant,
      isChurchAdmin: isChurchAdmin,
      servant: servant,
      churchAdmin: churchAdmin,
    );
  }
}
