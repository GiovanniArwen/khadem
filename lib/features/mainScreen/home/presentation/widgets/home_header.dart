import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khadem/core/utils/text_styles.dart';

/// هيدر الهوم:
/// أهلاً بك، يا <الاسم> 👋
/// وتحتها: ربنا يبارك خدمتك ✨
///
/// ترتيب الهيدر ثابت:
/// أهلاً بك، يا → الاسم → 👋 → 🔔
class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots();
    }
  }

  /// أول اسم فقط.
  String _firstName(String? fullName) {
    final trimmed = (fullName ?? '').trim();

    if (trimmed.isEmpty) return '';

    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream,
      builder: (context, snapshot) {
        final name = _firstName(
          snapshot.data?.data()?['name'] as String?,
        );

        return Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =====================================================
                  // السطر الأول
                  // أهلاً بك، يا → الاسم → 👋
                  // =====================================================
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      // أهلاً بك، يا
                      Text(
                        name.isEmpty ? 'أهلاً بك' : 'أهلاً بك، يا',
                        style: TextStyles.title.copyWith(
                          fontSize: 24,
                        ),
                      ),

                      if (name.isNotEmpty) ...[
                        const SizedBox(width: 6),

                        // الاسم
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: TextStyles.title.copyWith(
                              fontSize: 24,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // 👋
                        const _WavingHand(),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  // =====================================================
                  // السطر الثاني
                  // ربنا يبارك خدمتك ✨
                  // =====================================================
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'ربنا يبارك خدمتك ',
                            style: TextStyles.headline.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const TextSpan(
                            text: '✨',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ===========================================================
            // Notification
            // ===========================================================
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 26,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// اليد بتلوّح مرة واحدة أول ما الشاشة تفتح وبعدين تثبت.
/// ومش بتتحرك لو المستخدم مفعّل تقليل الحركة في الموبايل.
class _WavingHand extends StatefulWidget {
  const _WavingHand();

  @override
  State<_WavingHand> createState() => _WavingHandState();
}

class _WavingHandState extends State<_WavingHand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  late final Animation<double> _angle = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: 0.45),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.45, end: -0.2),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(begin: -0.2, end: 0.45),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.45, end: -0.1),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(begin: -0.1, end: 0.0),
      weight: 1,
    ),
  ]).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ),
  );

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      if (MediaQuery.of(context).disableAnimations) return;

      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _angle,
      builder: (context, child) {
        return Transform.rotate(
          angle: _angle.value,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
      child: const Text(
        '👋',
        style: TextStyle(fontSize: 26),
      ),
    );
  }
}
