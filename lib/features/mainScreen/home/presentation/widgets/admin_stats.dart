import 'package:flutter/material.dart';
import 'package:khadem/features/mainScreen/home/presentation/widgets/state_card.dart';

class AdminStats extends StatelessWidget {
  const AdminStats({
    super.key,
    required this.servantsCount,
    required this.pendingInvitations,
  });

  final String servantsCount;
  final String pendingInvitations;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.people_alt_rounded,
            number: servantsCount,
            title: 'خادم',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: StatCard(
            icon: Icons.pending_actions_rounded,
            number: pendingInvitations,
            title: 'دعوات معلقة',
          ),
        ),
      ],
    );
  }
}