import 'package:flutter/material.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/core/utils/text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OnboardingData {
  final String title;
  final String desc;
  final IconData icon;

  const _OnboardingData({
    required this.title,
    required this.desc,
    required this.icon,
  });
}

const List<_OnboardingData> _pages = [
  _OnboardingData(
    title: 'لو مسؤول اجتماع.. اكتشف الخدام المتاحين',
    desc:
        'شوف كل الخدام والمتكلمين والمرنمين، واعرف مواعيدهم المتاحة والمشغولة عشان تحجز في الوقت المناسب.',
    icon: Icons.event_available_rounded,
  ),
  _OnboardingData(
    title: 'خدمتك... في مكان واحد',
    desc:
        'خدمتي يجمع مسؤولي الاجتماعات بالخدام والمتكلمين والمرنمين وفريق الدراما، عشان تنظيم الخدمة يبقى أسهل.',
    icon: Icons.diversity_3_rounded,
  ),
  _OnboardingData(
    title: 'لو خادم.. النوتة والدردشة في مكان واحد',
    desc:
        'احتفظ بنوتة كل خدمة، وتواصل مع مسؤولي الاجتماعات والكنائس من غير ما تنقّل بين تطبيقات كتير.',
    icon: Icons.forum_rounded,
  ),
  _OnboardingData(
    title: 'تواصل واضبط التفاصيل',
    desc:
        'ابعت رسالة مباشرة لأي خادم أو متكلم، واتفقوا على كل تفاصيل الخدمة قبل الموعد بارتياح.',
    icon: Icons.handshake_rounded,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  /// نفس المفتاح المستخدم في SplashScreen بالظبط.
  static const String _kHasSeenOnboardingKey = 'has_seen_onboarding';

  bool _isFinishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_isFinishing) return; // يمنع الضغط أكتر من مرة أثناء الحفظ
    _isFinishing = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasSeenOnboardingKey, true);

    if (!mounted) return;

    // خد بالك: غيّر الوجهة هنا لو عايز onboarding يودي على SignUp
    // بدل Login في أول مرة يفتح فيها المستخدم التطبيق.
    pushWithReplacement(context, Routes.login);
  }

  void _next() {
    if (_current == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_current == 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _current == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // Back + Skip row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Opacity(
                    opacity: _current == 0 ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: _current == 0,
                      child: IconButton(
                        onPressed: _back,
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                        ),
                        color: AppColors.textGreyColor,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: isLast ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: isLast,
                      child: TextButton(
                        onPressed: _finish,
                        child: Text(
                          'تخطي',
                          style: TextStyles.body.copyWith(
                            color: AppColors.textGreyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _OnboardingIllustration(icon: page.icon),
                        const SizedBox(height: 36),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyles.headline.copyWith(
                            fontSize: 22,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page.desc,
                          textAlign: TextAlign.center,
                          style: TextStyles.body.copyWith(
                            color: AppColors.textGreyColor,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots + Next
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _current;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primaryColor
                              : AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  isLast
                      ? SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _finish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                              shadowColor: AppColors.primaryColor.withOpacity(
                                0.35,
                              ),
                            ),
                            child: Text(
                              'ابدأ الخدمة',
                              style: TextStyles.body.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _next,
                              child: Text(
                                'التالي',
                                style: TextStyles.body.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _next,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: AppColors.mainGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: AppColors.softShadow,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  final IconData icon;

  const _OnboardingIllustration({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient,
              shape: BoxShape.circle,
              boxShadow: AppColors.softShadow,
            ),
            child: Icon(icon, color: Colors.white, size: 56),
          ),
        ],
      ),
    );
  }
}