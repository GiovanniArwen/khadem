import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/features/auth/data/models/user_type_enum.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_state.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
          if (state is AuthSuccessState) {
      if (state.userType == UserTypeEnum.servant) {

      } else {
        
      }
    }

    if (state is AuthErrorState) {
      // show error
    }
      },
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF2962FF),
                        size: 20,
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'New Account',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2962FF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 30),

                // Full Name
                const Text(
                  'Full name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField('example@example.com'),

                const SizedBox(height: 20),

                // Password
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField('****************', isPassword: true),

                const SizedBox(height: 20),

                // Email
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField('example@example.com'),

                const SizedBox(height: 20),

                // Mobile Number
                const Text(
                  'Mobile Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField('example@example.com'),

                const SizedBox(height: 20),

                // Date Of Birth
                const Text(
                  'Date Of Birth',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField('DD / MM /YYY'),

                const SizedBox(height: 30),

                // Terms & Privacy
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'By continuing, you agree to',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Terms of Use',
                              style: TextStyle(
                                color: Color(0xFF2962FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Text(
                            'and ',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Privacy Policy.',
                              style: TextStyle(
                                color: Color(0xFF2962FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                      shadowColor: const Color(0xFF2962FF).withOpacity(0.4),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Social Footer
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
                    _socialIcon(Icons.g_mobiledata),
                    const SizedBox(width: 20),
                    _socialIcon(Icons.facebook),
                    const SizedBox(width: 20),
                    _socialIcon(Icons.fingerprint),
                  ],
                ),

                const SizedBox(height: 40),

                // Footer Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("already have an account? "),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Log in',
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
    );
  }

  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9FA8DA)),
        filled: true,
        fillColor: const Color(0xFFEDF2FF),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility_off_outlined, color: Colors.grey)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: Color(0xFFEDF2FF),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF2962FF), size: 30),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:gap/gap.dart';
// import 'package:se7ety/components/buttons/main_button.dart';
// import 'package:se7ety/core/extentions/app_regex.dart';
// import 'package:se7ety/core/extentions/dialogs.dart';
// import 'package:se7ety/core/routes/navigation.dart';
// import 'package:se7ety/core/routes/routes.dart';
// import 'package:se7ety/core/utils/colors.dart';
// import 'package:se7ety/core/utils/text_styles.dart';
// import 'package:se7ety/features/auth/data/models/user_type_enum.dart';
// import 'package:se7ety/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:se7ety/features/auth/presentation/bloc/auth_event.dart';
// import 'package:se7ety/features/auth/presentation/bloc/auth_state.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key, required this.userType});
//   final UserTypeEnum userType;

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   bool isVisible = true;

//   String handleUserType() {
//     return widget.userType == UserTypeEnum.doctor ? 'دكتور' : 'مريض';
//   }

//   @override
//   Widget build(BuildContext context) {
//     var bloc = context.read<AuthBloc>();
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.whiteColor,
//         leading: const BackButton(color: AppColors.primaryColor),
//       ),
//       body: BlocListener<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthLoadingState) {
//             showLoadingDialog(context);
//           } else if (state is AuthSuccessState) {
//             pop(context);
//             if (state.userType == UserTypeEnum.doctor) {
//               pushTo(context, Routes.doctorRegistration);
//             } else {
//               pushToBase(context, Routes.mainPatient);
//             }
//           } else if (state is AuthErrorState) {
//             pop(context);
//             showMyDialog(context, state.message);
//           }
//         },
//         child: Center(
//           child: SingleChildScrollView(
//             child: Form(
//               key: bloc.formKey,
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 16, left: 16),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset('assets/images/logo.png', height: 200),
//                     const SizedBox(height: 20),
//                     Text(
//                       'سجل دخول الان كـ "${handleUserType()}"',
//                       style: TextStyles.title,
//                     ),
//                     const SizedBox(height: 30),
//                     TextFormField(
//                       keyboardType: TextInputType.text,
//                       controller: bloc.nameController,
//                       decoration: const InputDecoration(
//                         hintText: 'اسم المستخدم',
//                         prefixIcon: Icon(Icons.person),
//                       ),
//                       textInputAction: TextInputAction.next,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'من فضلك ادخل الاسم';
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 25.0),
//                     TextFormField(
//                       keyboardType: TextInputType.emailAddress,
//                       controller: bloc.emailController,
//                       textAlign: TextAlign.end,
//                       decoration: const InputDecoration(
//                         hintText: 'Sayed@example.com',
//                         prefixIcon: Icon(Icons.email_rounded),
//                       ),
//                       textInputAction: TextInputAction.next,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'من فضلك ادخل الايميل';
//                         } else if (!AppRegex.isEmailValid(value)) {
//                           return 'من فضلك ادخل الايميل صحيحا';
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 25.0),
//                     TextFormField(
//                       controller: bloc.passwordController,
//                       textAlign: TextAlign.end,
//                       style: const TextStyle(color: AppColors.darkColor),
//                       obscureText: isVisible,
//                       keyboardType: TextInputType.visiblePassword,
//                       inputFormatters: [
//                         LengthLimitingTextInputFormatter(8),
//                         FilteringTextInputFormatter.allow(
//                           RegExp('[a-zA-Z0-9]'),
//                         ),
//                       ],
//                       decoration: InputDecoration(
//                         hintText: '********',
//                         suffixIcon: IconButton(
//                           onPressed: () {
//                             setState(() {
//                               isVisible = !isVisible;
//                             });
//                           },
//                           icon: Icon(
//                             (isVisible)
//                                 ? Icons.remove_red_eye
//                                 : Icons.visibility_off_rounded,
//                           ),
//                         ),
//                         prefixIcon: const Icon(Icons.lock),
//                       ),
//                       validator: (value) {
//                         if (value!.isEmpty) return 'من فضلك ادخل كلمة السر';
//                         return null;
//                       },
//                     ),

//                     const Gap(20),
//                     MainButton(
//                       onPressed: () async {
//                         if (bloc.formKey.currentState!.validate()) {
//                           bloc.add(SignUpEvent(userType: widget.userType));
//                         }
//                       },
//                       text: "تسجيل حساب جديد",
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 30),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'لدي حساب ؟',
//                             style: TextStyles.body.copyWith(
//                               color: AppColors.darkColor,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               pushWithReplacement(
//                                 context,
//                                 Routes.login,
//                                 extra: widget.userType,
//                               );
//                             },
//                             child: Text(
//                               'سجل دخول',
//                               style: TextStyles.body.copyWith(
//                                 color: AppColors.primaryColor,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
