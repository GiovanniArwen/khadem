import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/features/main_screen/servants/data/models/servant_model.dart';

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
        'role': 'خادم',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSpecializations =
        servant.specialization != null && servant.specialization!.isNotEmpty;

    final hasInstruments =
        servant.instruments != null && servant.instruments!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // Profile Image
              // =========================
              Stack(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.08),
                    backgroundImage:
                        servant.image != null && servant.image!.isNotEmpty
                        ? NetworkImage(servant.image!)
                        : null,
                    child: servant.image == null || servant.image!.isEmpty
                        ? const Icon(
                            Icons.person_rounded,
                            size: 38,
                            color: AppColors.primaryColor,
                          )
                        : null,
                  ),

                  // Online / approved style indicator
                  // Positioned(
                  //   bottom: 2,
                  //   right: 2,
                  //   child: Container(
                  //     width: 15,
                  //     height: 15,
                  //     decoration: BoxDecoration(
                  //       color: Colors.green,
                  //       shape: BoxShape.circle,
                  //       border: Border.all(
                  //         color: Colors.white,
                  //         width: 2,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              const SizedBox(width: 14),

              // =========================
              // Information
              // =========================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Arrow
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            servant.name ?? 'بدون اسم',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // =========================
                    // Specializations
                    // =========================
                    if (hasSpecializations)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: servant.specialization!
                            .map(
                              (specialization) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  specialization,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    else
                      const Text(
                        'التخصص غير محدد',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                    // =========================
                    // Instruments
                    // =========================
                    if (hasInstruments) ...[
                      const SizedBox(height: 9),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.music_note_rounded,
                            size: 16,
                            color: Colors.orange,
                          ),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              servant.instruments!.join(' • '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 8),

                    // =========================
                    // Governorate
                    // =========================
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            servant.governorate ?? 'المحافظة غير محددة',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),

              const SizedBox(width: 8),

              // =========================
              // Chat Button
              // =========================
              Material(
                color: AppColors.primaryColor.withOpacity(0.08),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _openChat(context),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
