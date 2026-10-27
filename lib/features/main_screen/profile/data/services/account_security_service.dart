
import 'package:firebase_auth/firebase_auth.dart';

class AccountSecurityService {
  final FirebaseAuth _auth;

  AccountSecurityService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('يجب تسجيل الدخول أولاً.');
    }

    final email = user.email;

    if (email == null || email.isEmpty) {
      throw Exception(
        'لا يمكن تغيير كلمة المرور لهذا الحساب باستخدام كلمة المرور الحالية.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
