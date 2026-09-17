import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/core/extentions/dialogs.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/features/auth/data/models/user_type_enum.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_event.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_state.dart';
import 'package:khadem/features/auth/presentation/widgets/header.dart';
import 'package:khadem/features/auth/presentation/widgets/social_icon.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
          // print('LOGIN SUCCESS');
          // print('isServant: ${state.isServant}');
          // print('isChurchAdmin: ${state.isChurchAdmin}');
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

        if (state is AuthErrorState) {
          Navigator.of(context, rootNavigator: true).pop();

          showMyDialog(context, "اسم المستخدم او كلمة السر يوجدا بهما خطأ");
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
                            title: 'أهلا بيـك في تـطبيـق خـادم',
                            subtitle:
                                'لدعوة المرنمين والمتكلمين وفرق التسبيح والدراما للكنيسة المحلية الخاصة بك',
                          ),
                          // Email Input
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'example@example.com',
                              hintStyle: const TextStyle(
                                color: Color(0xFF9FA8DA),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFEDF2FF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Password Input
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '**************',
                              hintStyle: const TextStyle(
                                color: Color(0xFF9FA8DA),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFEDF2FF),
                              suffixIcon: const Icon(
                                Icons.visibility_off_outlined,
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forget Password',
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
                          const Center(
                            child: Text(
                              'or sign up with',
                              style: TextStyle(color: Colors.black45),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialIcon(
                                icon: Icons.g_mobiledata,
                                bgColor: const Color(0xFFEDF2FF),
                                iconColor: const Color(0xFF2962FF),
                              ),
                              const SizedBox(width: 20),
                              SocialIcon(
                                icon: Icons.facebook,
                                bgColor: const Color(0xFFEDF2FF),
                                iconColor: const Color.fromARGB(
                                  255,
                                  39,
                                  48,
                                  73,
                                ),
                              ),
                              const SizedBox(width: 20),
                              SocialIcon(
                                icon: Icons.fingerprint,
                                bgColor: const Color(0xFFEDF2FF),
                                iconColor: const Color.fromARGB(
                                  255,
                                  39,
                                  48,
                                  73,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          // Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
                              GestureDetector(
                                onTap: () {
                                  pushTo(
                                    context,
                                    Routes.signup,
                                    extra: UserTypeEnum.servant,
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Color(0xFF2962FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
