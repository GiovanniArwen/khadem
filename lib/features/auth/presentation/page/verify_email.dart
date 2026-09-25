import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/utils/colors.dart';

class VerifyEmailScreen extends StatefulWidget {
  final bool isServant;
  final bool isChurchAdmin;
  final String uid;
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.isServant,
    required this.isChurchAdmin,
    required this.uid,
    required this.email,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isChecking = false;
  bool isResending = false;

  Future<void> _checkVerification() async {
    setState(() {
      isChecking = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage('حدث خطأ، من فضلك حاول تسجيل الدخول مرة أخرى');
        return;
      }

      // Refresh user data from Firebase
      await user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser?.emailVerified == true) {
        if (!mounted) return;

        pushWithReplacement(
          context,
          Routes.completeProfile,
          extra: {
            'isServant': widget.isServant,
            'isChurchAdmin': widget.isChurchAdmin,
          },
        );
      } else {
        _showMessage(
          'لم يتم تأكيد البريد الإلكتروني بعد.\n'
          'افتح رسالة Firebase واضغط على رابط التأكيد.',
        );
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'حدث خطأ أثناء التحقق');
    } catch (e) {
      _showMessage('حدث خطأ، من فضلك حاول مرة أخرى');
    } finally {
      if (mounted) {
        setState(() {
          isChecking = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      isResending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage('حدث خطأ، من فضلك حاول تسجيل الدخول مرة أخرى');
        return;
      }

      await user.sendEmailVerification();

      _showMessage(
        'تم إرسال رسالة تأكيد جديدة إلى بريدك الإلكتروني',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        _showMessage(
          'تم إرسال رسائل كثيرة، من فضلك انتظر قليلًا ثم حاول مرة أخرى',
        );
      } else {
        _showMessage(
          e.message ?? 'تعذر إرسال رسالة التأكيد',
        );
      }
    } catch (e) {
      _showMessage('تعذر إرسال رسالة التأكيد');
    } finally {
      if (mounted) {
        setState(() {
          isResending = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.right,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _circleButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      onTap: () => pop(context),
                    ),
                  ],
                ),

                const Spacer(),

                // Email icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 52,
                    color: AppColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'أكد بريدك الإلكتروني',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkColor,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'أرسلنا لك رسالة تأكيد على البريد الإلكتروني',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGreyColor,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'افتح بريدك الإلكتروني واضغط على رابط التأكيد، '
                  'ثم ارجع للتطبيق واضغط على "لقد أكدت البريد".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textGreyColor,
                  ),
                ),

                const SizedBox(height: 30),

                // Check verification button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isChecking ? null : _checkVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor: AppColors.borderColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isChecking
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'لقد أكدت البريد الإلكتروني',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 14),

                // Resend button
                TextButton(
                  onPressed: isResending
                      ? null
                      : _resendVerificationEmail,
                  child: isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'إعادة إرسال رسالة التأكيد',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderColor,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}