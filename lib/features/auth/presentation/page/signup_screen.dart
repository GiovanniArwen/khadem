// lib/features/auth/presentation/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_event.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isServant = false;
  bool isChurchAdmin = false;

  bool isPasswordVisible = false;
  bool isConfirmVisible = false;
  bool acceptTerms = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (!formKey.currentState!.validate()) return;

    if (!isServant && !isChurchAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك اختر دورك في التطبيق')),
      );
      return;
    }

    if (!acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك وافق على الشروط والأحكام')),
      );
      return;
    }

    context.read<AuthBloc>().add(
      SignUpEvent(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        isServant: isServant,
        isChurchAdmin: isChurchAdmin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccessState) {
            pushWithReplacement(
              context,
              Routes.completeProfile,
              extra: {
                'isServant': state.isServant,
                'isChurchAdmin': state.isChurchAdmin,
              },
            );
          }

          if (state is AuthErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoadingState;

          return Scaffold(
            backgroundColor: AppColors.scaffoldColor,
            body: SafeArea(
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== Top bar =====
                      Row(
                        children: [
                          _circleButton(
                            icon: Icons.arrow_forward_ios_rounded,
                            onTap: () => pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'سجّل بياناتك عشان تبدأ خدمتك معانا',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGreyColor,
                        ),
                      ),

                      const SizedBox(height: 28),

                      _buildField(
                        controller: nameController,
                        label: 'الاسم بالكامل',
                        hint: 'اكتب اسمك الثلاثي',
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'من فضلك ادخل الاسم';
                          }
                          if (value.trim().length < 3) {
                            return 'الاسم قصير جداً';
                          }
                          return null;
                        },
                      ),

                      _buildField(
                        controller: emailController,
                        label: 'البريد الإلكتروني',
                        hint: 'example@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'من فضلك ادخل الايميل';
                          }
                          final emailRegex = RegExp(
                            r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'الايميل غير صحيح';
                          }
                          return null;
                        },
                      ),

                      _buildField(
                        controller: passwordController,
                        label: 'كلمة السر',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscure: !isPasswordVisible,
                        suffix: IconButton(
                          onPressed: () => setState(
                            () => isPasswordVisible = !isPasswordVisible,
                          ),
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppColors.hintColor,
                            size: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'من فضلك ادخل كلمة السر';
                          }
                          if (value.length < 6) {
                            return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),

                      _buildField(
                        controller: confirmPasswordController,
                        label: 'تأكيد كلمة السر',
                        hint: '••••••••',
                        icon: Icons.lock_reset_rounded,
                        obscure: !isConfirmVisible,
                        suffix: IconButton(
                          onPressed: () => setState(
                            () => isConfirmVisible = !isConfirmVisible,
                          ),
                          icon: Icon(
                            isConfirmVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppColors.hintColor,
                            size: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'كلمة السر غير متطابقة';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'اختار دورك في التطبيق',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'تقدر تختار أكتر من دور',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGreyColor,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _roleCard(
                        icon: Icons.volunteer_activism_rounded,
                        title: 'خادم',
                        subtitle: 'أريد الخدمة واستقبال الدعوات',
                        selected: isServant,
                        onTap: () => setState(() => isServant = !isServant),
                      ),

                      const SizedBox(height: 12),

                      _roleCard(
                        icon: Icons.groups_rounded,
                        title: 'مسؤول اجتماع',
                        subtitle: 'هدعي الخدام للاجتماع',
                        selected: isChurchAdmin,
                        onTap: () =>
                            setState(() => isChurchAdmin = !isChurchAdmin),
                      ),

                      const SizedBox(height: 18),

                      // ===== Terms =====
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: acceptTerms,
                              activeColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              onChanged: (value) =>
                                  setState(() => acceptTerms = value ?? false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'أوافق على ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textGreyColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'الشروط والأحكام',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ' وسياسة الخصوصية'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ===== Sign up button =====
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: isLoading ? null : AppColors.mainGradient,
                            color: isLoading ? AppColors.borderColor : null,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryColor,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'إنشاء الحساب',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'عندك حساب بالفعل؟ ',
                              style: TextStyle(color: AppColors.textGreyColor),
                            ),
                            GestureDetector(
                              onTap: () => pushTo(context, Routes.login),
                              child: const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Icon(icon, size: 18, color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDarkColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            validator: validator,
            style: const TextStyle(color: AppColors.textDarkColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.hintColor,
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 21),
              suffixIcon: suffix,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              border: _border(AppColors.borderColor),
              enabledBorder: _border(AppColors.borderColor),
              focusedBorder: _border(AppColors.primaryColor, width: 1.4),
              errorBorder: _border(AppColors.redColor),
              focusedErrorBorder: _border(AppColors.redColor, width: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _roleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF1FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primaryColor : AppColors.borderColor,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryColor : AppColors.fieldColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : AppColors.textGreyColor,
                size: 23,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGreyColor,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primaryColor : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.primaryColor
                      : AppColors.borderColor,
                  width: 1.6,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 15,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
