import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';

/// صورة المستخدم: بتظهر الصورة جوه دايرة بإطار متدرج،
/// ولو مفيش صورة (أو فشل تحميلها) بتظهر أول حرف من الاسم.
/// حطها في: features/mainScreen/chat/presentation/widgets/user_avatar.dart
class UserAvatar extends StatelessWidget {
  final String name;
  final String? image;
  final double size;
  final bool showRing;

  /// لو اتحدد، الإطار بيبقى لون واحد (مفيد فوق الـ AppBar الملوّن)
  final Color? ringColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.image,
    this.size = 56,
    this.showRing = true,
    this.ringColor,
  });

  bool get _hasImage => image != null && image!.trim().isNotEmpty;

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return String.fromCharCode(trimmed.runes.first);
  }

  @override
  Widget build(BuildContext context) {
    const ringWidth = 2.0;
    const gap = 2.0;
    final inner = showRing ? size - (ringWidth + gap) * 2 : size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final avatar = ClipOval(
      child: SizedBox(
        width: inner,
        height: inner,
        child: _hasImage
            ? Image.network(
                image!.trim(),
                fit: BoxFit.cover,
                cacheWidth: (inner * pixelRatio).round(),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _fallback(inner),
                errorBuilder: (context, error, stackTrace) => _fallback(inner),
              )
            : _fallback(inner),
      ),
    );

    if (!showRing) return avatar;

    if (ringColor != null) {
      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(gap),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor!, width: ringWidth),
        ),
        child: avatar,
      );
    }

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(ringWidth),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(gap),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.whiteColor,
        ),
        child: avatar,
      ),
    );
  }

  Widget _fallback(double s) {
    return Container(
      color: AppColors.secondaryColor,
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: TextStyle(
          fontSize: s * 0.4,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}