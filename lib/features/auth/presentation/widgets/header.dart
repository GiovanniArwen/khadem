import 'package:flutter/material.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/utils/text_styles.dart';

class Header extends StatefulWidget {
  const Header({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  pop(context);
                },
                icon: const Icon(
                  // في RTL سهم الرجوع بيبقى لليمين مش لليسار
                  Icons.arrow_forward_ios,
                  color: Color(0xFF2962FF),
                  size: 20,
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2962FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Offset for back button alignment
            ],
          ),

          const SizedBox(height: 40),

          // Welcome Header
          Text(
            widget.title,
            textAlign: TextAlign.right,
            style: TextStyles.title.copyWith(
              fontSize: 32,
              color: const Color(0xFF2962FF),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.subtitle,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}