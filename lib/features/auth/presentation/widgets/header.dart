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

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF2962FF),
                size: 20,
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Log In',
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
          textAlign: TextAlign.end,
          widget.title ?? 'put your title here',
                  //  'أهلا بيـك في تـطبيـق خـادم',

          style: TextStyles.title.copyWith(
            fontSize: 32,
            color: const Color(0xFF2962FF),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          textAlign: TextAlign.end,
          widget.subtitle ?? 'put your subtitle here',
          //  'هدف التطبيق إنه يساعد المستخدمين على إيجاد الخدمه المناسبة بسهولة',
          style: const TextStyle(fontSize: 18, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
