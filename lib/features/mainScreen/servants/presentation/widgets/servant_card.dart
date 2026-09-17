import 'package:flutter/material.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/features/mainScreen/servants/data/models/servant_model.dart';

class ServantCard extends StatelessWidget {
  final ServantModel servant;
  final VoidCallback? onTap;

  const ServantCard({super.key, required this.servant, this.onTap});

  void _openChat(BuildContext context) {
    if (servant.uid == null || servant.uid!.isEmpty) {
      return;
    }

    pushTo(
      context,
      Routes.chat,
      extra: {
        'uid': servant.uid!,
        'name': servant.name ?? 'خادم',
        'role': servant.specialization ?? 'خادم',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),

        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundImage:
                    servant.image != null && servant.image!.isNotEmpty
                    ? NetworkImage(servant.image!)
                    : null,

                child: servant.image == null || servant.image!.isEmpty
                    ? const Icon(Icons.person, size: 35)
                    : null,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servant.name ?? 'بدون اسم',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(servant.specialization ?? 'غير محدد'),

                    const SizedBox(height: 5),

                    Text('📍 ${servant.governorate ?? 'غير محدد'}'),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  _openChat(context);
                },
                icon: const Icon(
                  Icons.chat_rounded,
                  color: AppColors.primaryColor,
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
