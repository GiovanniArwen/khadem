import 'package:flutter/material.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/utils/text_styles.dart';
import 'package:khadem/features/auth/presentation/widgets/header.dart';
import 'package:khadem/features/auth/presentation/widgets/social_icon.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'هدف التطبيق إنه يساعد المستخدمين على إيجاد الخدمه المناسبة بسهولة',
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
               TextField(
                decoration: InputDecoration(
                  hintText: 'example@example.com',
                  hintStyle: const TextStyle(color: Color(0xFF9FA8DA)),
                  filled: true,
                  fillColor: const Color(0xFFEDF2FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '**************',
                  hintStyle: const TextStyle(color: Color(0xFF9FA8DA)),
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
                    iconColor: const Color.fromARGB(255, 39, 48, 73),
                  ),
                  const SizedBox(width: 20),
                  SocialIcon(
                    icon: Icons.fingerprint,
                    bgColor: const Color(0xFFEDF2FF),
                    iconColor: const Color.fromARGB(255, 39, 48, 73),
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
                      pushTo(context,Routes.signup); 
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
    );
  }


}









// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_gap/flutter_gap.dart';
// import 'package:khadem/components/buttons/main_button.dart';
// import 'package:khadem/core/routes/navigation.dart';
// import 'package:khadem/core/utils/colors.dart';
// import 'package:khadem/core/utils/text_styles.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key,});
// //  final UserTypeEnum userType;

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool isVisible = true;

//   // String handleUserType() {
//   //   return widget.userType == UserTypeEnum.doctor ? 'خادم' : 'مسؤل';
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.whiteColor,
//         leading: const BackButton(color: AppColors.primaryColor),
//       ),
//       body: 
      
//       Center(
//         child: SingleChildScrollView(
//           child: Form(
//           //  key: formKey,
//             child: Padding(
//               padding: const EdgeInsets.only(right: 16, left: 16),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset('assets/images/logo.png', height: 200),
//                   const SizedBox(height: 20),
//                   Text(
//                      'سجل دخول الان كـ ',
//                     style: TextStyles.title,
//                   ),
//                   const SizedBox(height: 30),
//                   TextFormField(
//                     keyboardType: TextInputType.emailAddress,
//                     textAlign: TextAlign.end,
//                     decoration: const InputDecoration(
//                       hintText: 'Sayed@example.com',
//                       prefixIcon: Icon(Icons.email_rounded),
//                     ),
//                     textInputAction: TextInputAction.next,
//                     validator: (value) {

//                     },
//                   ),
//                   const SizedBox(height: 25.0),
//                   TextFormField(
//                     textAlign: TextAlign.end,
//                     style: const TextStyle(color: AppColors.darkColor),
//                     obscureText: isVisible,
//                     keyboardType: TextInputType.visiblePassword,
//                     decoration: InputDecoration(
//                       hintText: '********',
//                       suffixIcon: IconButton(
//                         onPressed: () {
//                           setState(() {
//                             isVisible = !isVisible;
//                           });
//                         },
//                         icon: Icon(
//                           (isVisible)
//                               ? Icons.remove_red_eye
//                               : Icons.visibility_off_rounded,
//                         ),
//                       ),
//                       prefixIcon: const Icon(Icons.lock),
//                     ),
//                     validator: (value) {
//                       if (value!.isEmpty) return 'من فضلك ادخل كلمة السر';
//                       return null;
//                     },
//                   ),
//                   Container(
//                     alignment: Alignment.centerRight,
//                     padding: const EdgeInsetsDirectional.only(
//                       top: 10,
//                       start: 10,
//                     ),
//                     child: Text('نسيت كلمة السر ؟', style: TextStyles.small),
//                   ),
//                   const Gap(20),
//                   MainButton(
//                     onPressed: () async {
//                       // if (bloc.formKey.currentState!.validate()) {
//                       //   bloc.add(LoginEvent(userType: widget.userType));
//                       // }
//                     },
//                     text: "تسجيل الدخول",
//                   ),
//                   Row(
//                     children: [
//                       const Expanded(
//                         child: Divider(
//                           color: AppColors.greyColor,
//                           thickness: 1,
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Text(
//                           'او',
//                           style: TextStyles.body.copyWith(
//                             color: AppColors.darkColor,
//                           ),
//                         ),
//                       ),
//                       const Expanded(
//                         child: Divider(
//                           color: AppColors.greyColor,
//                           thickness: 1,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Gap(20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       OutlinedButton(
//                         onPressed: () {
//                           // signInWithGoogle().then((value) {
//                           //   log(value.user?.email.toString() ?? '');
//                           // });
//                         },
//                         child: const Text('Google'),
//                       ),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 30),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'ليس لدي حساب ؟',
//                           style: TextStyles.body.copyWith(
//                             color: AppColors.darkColor,
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             // pushWithReplacement(
//                             //   context,
//                             // //  Routes.register,
//                             //   extra: widget.userType,
//                             // );
//                           },
//                           child: Text(
//                             'سجل الان',
//                             style: TextStyles.body.copyWith(
//                               color: AppColors.primaryColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Future<UserCredential> signInWithGoogle() async {
//   //   // Trigger the authentication flow
//   //   await GoogleSignIn.instance.initialize(
//   //     serverClientId:
//   //         "768470228155-o0f6i2qtdimh027j5nodcmcqshqbv0vf.apps.googleusercontent.com",
//   //   );

//   //   final GoogleSignInAccount googleUser = await GoogleSignIn.instance
//   //       .authenticate(scopeHint: ['email']);
//   //   // Obtain the auth details from the request
//   //   final GoogleSignInAuthentication googleAuth = googleUser.authentication;

//   //   // Create a new credential
//   //   final credential = GoogleAuthProvider.credential(
//   //     idToken: googleAuth.idToken,
//   //   );

//   //   // Once signed in, return the UserCredential
//   //   return await FirebaseAuth.instance.signInWithCredential(credential);
//   // }
// }
