import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/core/extentions/dialogs.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/features/auth/data/models/user_type_enum.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_event.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_state.dart';
import 'package:khadem/features/auth/presentation/widgets/auth_text_field_forlogin.dart';
import 'package:khadem/features/auth/presentation/widgets/header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final forgotEmailController = TextEditingController(
      text: emailController.text,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'نسيت كلمة المرور؟',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اكتب البريد الإلكتروني المرتبط بحسابك، وسنرسل لك رابطًا لإعادة تعيين كلمة المرور.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: forgotEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'example@example.com',
                  filled: true,
                  fillColor: const Color(0xFFEDF2FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = forgotEmailController.text.trim();

                if (email.isEmpty) {
                  showMyDialog(context, 'من فضلك اكتب البريد الإلكتروني');
                  return;
                }

                Navigator.pop(dialogContext);

                context.read<AuthBloc>().add(ForgotPasswordEvent(email: email));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );
  }

  // final bioController = TextEditingController();
  // final openHourController = TextEditingController();
  // final closeHourController = TextEditingController();
  // final addressController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoadingState) {
          showLoadingDialog(context);
        }

        if (state is AuthSuccessState) {
          Navigator.of(context, rootNavigator: true).maybePop();

          pushWithReplacement(
            context,
            Routes.main,
            extra: {
              'isServant': state.isServant,
              'isChurchAdmin': state.isChurchAdmin,
              'uid': state.uid,
            },
          );
        }

        if (state is ForgotPasswordSuccessState) {
          Navigator.of(context, rootNavigator: true).maybePop();

          showMyDialog(
            context,
            'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.',
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;

            showMyDialog(
              context,
              'إذا لم تجد الرابط في البريد الوارد، يرجى التحقق من مجلد Spam أو الرسائل غير المرغوب فيها في Gmail.',
            );
          });
        }
        if (state is AuthErrorState) {
          Navigator.of(context, rootNavigator: true).maybePop();

          showMyDialog(context, state.message);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Stack(
            children: [
              Form(
                key: formKey,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Top Navigation
                          Header(
                            title: 'أهلا بيـك في تـطبيـق خدمـتي',
                            subtitle:
                                'لدعوة المرنمين والمتكلمين وفرق التسبيح والدراما للكنيسة المحلية الخاصة بك',
                          ),
                          // Email Input
                          AuthTextField(
                            label: 'Email',
                            hintText: 'example@example.com',
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),
                          // Password Input
                          AuthTextField(
                            label: 'Password',
                            hintText: '****************',
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                _showForgotPasswordDialog(context);
                              },
                              child: const Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  color: Color(0xFF2962FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    LoginEvent(
                                      email: emailController.text,
                                      password: passwordController.text,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2962FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                                shadowColor: const Color(
                                  0xFF2962FF,
                                ).withOpacity(0.4),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Social Login
                          // const Center(
                          //   child: Text(
                          //     'سجل الدخول بـواسـطة',
                          //     style: TextStyle(color: Colors.black45),
                          //   ),
                          // ),
                          // const SizedBox(height: 20),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     SocialIcon(
                          //       icon: Icons.g_mobiledata,
                          //       bgColor: const Color(0xFFEDF2FF),
                          //       iconColor: const Color(0xFF2962FF),
                          //     ),
                          //     const SizedBox(width: 20),
                          //     SocialIcon(
                          //       icon: Icons.facebook,
                          //       bgColor: const Color(0xFFEDF2FF),
                          //       iconColor: const Color.fromARGB(
                          //         255,
                          //         39,
                          //         48,
                          //         73,
                          //       ),
                          //     ),
                          //     const SizedBox(width: 20),
                          //     SocialIcon(
                          //       icon: Icons.fingerprint,
                          //       bgColor: const Color(0xFFEDF2FF),
                          //       iconColor: const Color.fromARGB(
                          //         255,
                          //         39,
                          //         48,
                          //         73,
                          //       ),
                          //     ),
                          //   ],
                          // ),

                          // const SizedBox(height: 40),
                          // Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  pushTo(
                                    context,
                                    Routes.signup,
                                    extra: UserTypeEnum.servant,
                                  );
                                },
                                child: Text(
                                  'إنشاء حساب',
                                  style: TextStyle(
                                    color: Color(0xFF2962FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Text(" ليس لديك حساب قم بـ"),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // if (state is AuthLoadingState)
              //    const Center(child: AppLoading()),
            ],
          );
        },
      ),
    );
  }
}
