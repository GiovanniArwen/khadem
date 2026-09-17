import 'package:khadem/features/auth/data/models/church_admin_model.dart';
import 'package:khadem/features/mainScreen/servants/data/models/servant_model.dart';

class ChatUserModel {
  final String uid;
  final bool isServant;
  final bool isChurchAdmin;

  final ServantModel? servant;
  final ChurchAdminModel? churchAdmin;

  ChatUserModel({
    required this.uid,
    required this.isServant,
    required this.isChurchAdmin,
    this.servant,
    this.churchAdmin,
  });

  String get name {
    if (servant?.name != null && servant!.name!.isNotEmpty) {
      return servant!.name!;
    }

    if (churchAdmin?.name != null && churchAdmin!.name!.isNotEmpty) {
      return churchAdmin!.name!;
    }

    return 'مستخدم';
  }

  String? get image {
    if (servant?.image != null && servant!.image!.isNotEmpty) {
      return servant!.image;
    }

    if (churchAdmin?.image != null && churchAdmin!.image!.isNotEmpty) {
      return churchAdmin!.image;
    }

    return null;
  }

  String get governorate {
    if (servant?.governorate != null && servant!.governorate!.isNotEmpty) {
      return servant!.governorate!;
    }

    return '';
  }

  String get specialization {
    if (servant?.specialization != null &&
        servant!.specialization!.isNotEmpty) {
      return servant!.specialization!;
    }

    return '';
  }

  String get roleText {
    if (isServant && isChurchAdmin) {
      return 'خادم • مسؤول اجتماع';
    }

    if (isServant) {
      return 'خادم';
    }

    if (isChurchAdmin) {
      return 'مسؤول اجتماع';
    }

    return '';
  }

  bool get hasServantProfile => servant != null;
}
