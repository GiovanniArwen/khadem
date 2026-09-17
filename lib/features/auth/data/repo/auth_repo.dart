import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khadem/core/services/local/shared_pref.dart';
import 'package:khadem/features/auth/data/models/user_role.dart';

class AuthRepo {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =========================
  // Get Current User Roles
  // =========================
  static Future<Either<String, AuthUserRoles>>
      getCurrentUserRoles() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return const Left('المستخدم غير مسجل الدخول');
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

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
          isServant: isServant,
          isChurchAdmin: isChurchAdmin,
        ),
      );
    } catch (e) {
      return const Left(
        'حدث خطأ أثناء تحميل بيانات المستخدم',
      );
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
      final userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user!;

      await user.updateDisplayName(name);

      await SharedPref.setUserId(user.uid);

      // =========================
      // Create User Document
      // =========================
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': name,
        'email': email.trim(),

        // Roles
        'isServant': isServant,
        'isChurchAdmin': isChurchAdmin,

        // Verification
        'servantStatus':
            isServant ? 'approved' : 'not_requested',

        'churchAdminStatus':
            isChurchAdmin ? 'approved' : 'not_requested',

        'createdAt': FieldValue.serverTimestamp(),
      });

      return Right(
        AuthUserRoles(
          isServant: isServant,
          isChurchAdmin: isChurchAdmin,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return const Left('كلمة المرور ضعيفة');
      }

      if (e.code == 'email-already-in-use') {
        return const Left(
          'البريد الإلكتروني مستخدم بالفعل',
        );
      }

      if (e.code == 'invalid-email') {
        return const Left(
          'البريد الإلكتروني غير صحيح',
        );
      }

      return const Left('حدث خطأ ما');
    } catch (e) {
      return const Left('حدث خطأ ما');
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
      final credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      await SharedPref.setUserId(user.uid);

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        return const Left(
          'بيانات المستخدم غير موجودة',
        );
      }

      final data = userDoc.data()!;

      final isServant = data['isServant'] == true;
      final isChurchAdmin =
          data['isChurchAdmin'] == true;

      if (!isServant && !isChurchAdmin) {
        return const Left(
          'المستخدم ليس لديه صلاحية',
        );
      }

      return Right(
        AuthUserRoles(
          isServant: isServant,
          isChurchAdmin: isChurchAdmin,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return const Left(
          'البريد الإلكتروني غير مستخدم',
        );
      }

      if (e.code == 'wrong-password') {
        return const Left(
          'كلمة المرور غير صحيحة',
        );
      }

      if (e.code == 'invalid-credential') {
        return const Left(
          'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        );
      }

      return const Left('حدث خطأ ما');
    } catch (e) {
      return const Left('حدث خطأ ما');
    }
  }
}