import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khadem/core/services/local/shared_pref.dart';
import 'package:khadem/features/auth/data/models/auth_user_roles.dart';

class AuthRepo {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // Get Current User Roles
  // =========================
  static Future<Either<String, AuthUserRoles>> getCurrentUserRoles() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return const Left('المستخدم غير مسجل الدخول');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        return const Left('بيانات المستخدم غير موجودة');
      }

      final data = userDoc.data()!;

      final isServant = data['isServant'] == true;
      final isChurchAdmin = data['isChurchAdmin'] == true;

      if (!isServant && !isChurchAdmin) {
        return const Left('المستخدم ليس لديه صلاحية');
      }

      await SharedPref.setUserId(user.uid);

      return Right(
        AuthUserRoles(
          uid: user.uid,
          isServant: isServant,
          isChurchAdmin: isChurchAdmin,
        ),
      );
    } catch (e) {
      return const Left('حدث خطأ أثناء تحميل بيانات المستخدم');
    }
  }

  // =========================
  // Sign Up
  // =========================

  static Future<Either<String, AuthUserRoles>> signUp({
    required String name,
    required String email,
    required String password,
    required bool isServant,
    required bool isChurchAdmin,
  }) async {
    try {
      final cleanEmail = email.trim();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        return const Left('تعذر إنشاء الحساب. حاول مرة أخرى.');
      }

      await user.updateDisplayName(name.trim());

      await user.sendEmailVerification();

      await SharedPref.setUserId(user.uid);

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': cleanEmail,
        'isServant': isServant,
        'isChurchAdmin': isChurchAdmin,
        'servantStatus': isServant ? 'approved' : 'not_requested',
        'churchAdminStatus': isChurchAdmin ? 'approved' : 'not_requested',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Right(
        AuthUserRoles(
          uid: user.uid,
          isServant: isServant,
          isChurchAdmin: isChurchAdmin,
        ),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return const Left(
            'البريد الإلكتروني مسجل بالفعل. جرّب تسجيل الدخول.',
          );
        case 'invalid-email':
          return const Left('البريد الإلكتروني غير صحيح.');
        case 'weak-password':
          return const Left('كلمة المرور ضعيفة. اختر كلمة مرور أقوى.');
        case 'network-request-failed':
          return const Left(
            'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مجددًا.',
          );
        case 'too-many-requests':
          return const Left('محاولات كثيرة جدًا. حاول مرة أخرى لاحقًا.');
        case 'operation-not-allowed':
          return const Left('التسجيل بالبريد الإلكتروني غير مفعّل حاليًا.');
        default:
          return Left('تعذر إنشاء الحساب (${e.code}). حاول مرة أخرى.');
      }
    } on FirebaseException catch (e) {
      return Left(
        'تم إنشاء حساب الدخول، لكن تعذر حفظ البيانات (${e.code}). '
        'حاول استكمال التسجيل أو تواصل مع الدعم.',
      );
    } catch (e) {
      return const Left('حدث خطأ غير متوقع أثناء إنشاء الحساب. حاول مرة أخرى.');
    }
  }

  // =========================
  // Login
  // =========================
  static Future<Either<String, AuthUserRoles>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return const Left('تعذر تسجيل الدخول. حاول مرة أخرى.');
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      if (!userDoc.exists) {
        await _auth.signOut();
        await SharedPref.setUserId('');

        return const Left('بيانات الحساب غير موجودة. تواصل مع الدعم الفني.');
      }

      final data = userDoc.data()!;

      final isServant = data['isServant'] == true;
      final isChurchAdmin = data['isChurchAdmin'] == true;

      if (!isServant && !isChurchAdmin) {
        await _auth.signOut();
        await SharedPref.setUserId('');

        return const Left('الحساب ليس لديه صلاحية للدخول.');
      }

      await SharedPref.setUserId(user.uid);

      return Right(
        AuthUserRoles(
          uid: user.uid,
          isServant: isServant,
          isChurchAdmin: isChurchAdmin,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return const Left('البريد الإلكتروني غير مستخدم');
      }

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return const Left('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }

      return const Left('حدث خطأ أثناء تسجيل الدخول');
    } catch (e) {
      return const Left('حدث خطأ أثناء تسجيل الدخول');
    }
  } // =========================

  // Forgot Password
  // =========================
  static Future<Either<String, String>> forgotPassword({
    required String email,
    required String languageCode,
  }) async {
    try {
      final cleanEmail = email.trim();

      if (cleanEmail.isEmpty) {
        return const Left('من فضلك اكتب البريد الإلكتروني');
      }

      await _auth.setLanguageCode(languageCode);

      await _auth.sendPasswordResetEmail(email: cleanEmail);

      return const Right(
        'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return const Left('لا يوجد حساب مرتبط بهذا البريد الإلكتروني');
      }

      if (e.code == 'invalid-email') {
        return const Left('البريد الإلكتروني غير صحيح');
      }

      if (e.code == 'too-many-requests') {
        return const Left('تم إرسال طلبات كثيرة، حاول مرة أخرى لاحقًا');
      }

      return const Left('حدث خطأ أثناء إرسال رابط إعادة تعيين كلمة المرور');
    }
  }
}
