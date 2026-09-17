import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({super.key});

  Stream<DocumentSnapshot<Map<String, dynamic>>> get userStream {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة الحساب'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('لم يتم العثور على بيانات الحساب'),
            );
          }

          final data = snapshot.data!.data()!;

          final bool isServant =
              data['isServant'] == true;

          final bool isChurchAdmin =
              data['isChurchAdmin'] == true;

          final String servantStatus =
              data['servantStatus'] ?? 'not_requested';

          final String churchAdminStatus =
              data['churchAdminStatus'] ??
                  'not_requested';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'حالة حسابك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                if (isServant)
                  _StatusCard(
                    title: 'خادم',
                    status: servantStatus,
                  ),

                if (isChurchAdmin)
                  _StatusCard(
                    title: 'مسؤول اجتماع',
                    status: churchAdminStatus,
                  ),

                const SizedBox(height: 30),

                const Text(
                  'يمكنك استخدام الحساب، وسيتم تفعيل كل صلاحية بعد الموافقة عليها.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String status;

  const _StatusCard({
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    String text;

    IconData icon;

    if (status == 'approved') {
      text = 'تمت الموافقة';
      icon = Icons.check_circle;
    } else if (status == 'rejected') {
      text = 'تم رفض الطلب';
      icon = Icons.cancel;
    } else {
      text = 'قيد المراجعة';
      icon = Icons.hourglass_top;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(
          icon,
          size: 35,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(text),
      ),
    );
  }
}