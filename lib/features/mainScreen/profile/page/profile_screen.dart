import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/features/auth/data/models/church_admin_update.dart';
import 'package:khadem/features/mainScreen/chat/data/repo/chat_admin_repo.dart';
import 'package:khadem/features/mainScreen/servants/data/models/servant_update.dart';
import 'package:khadem/features/mainScreen/servants/data/repo/servant_repo.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ServantRepo _servantRepo = ServantRepo();
  final ChurchAdminRepo _churchAdminRepo = ChurchAdminRepo();

  final List<String> specializations = [
    'مرنم',
    'واعظ',
    'فريق تسبيح',
    'فريق دراما',
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('خطأ: المستخدم غير مسجل الدخول')),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!.data() ?? {};
              final isServant = data['isServant'] == true;
              final isChurchAdmin = data['isChurchAdmin'] == true;

              final name = (data['name'] as String?) ?? 'مستخدم';
              final email =
                  (data['email'] as String?) ??
                  FirebaseAuth.instance.currentUser?.email ??
                  '';
              final phone = (data['phone'] as String?) ?? '';
              final address = isServant
                  ? (data['address'] as String?) ?? ''
                  : (data['city'] as String?) ?? '';
              final specialization = (data['specialization'] as String?) ?? '';
              final isNoteVisible = isServant
                  ? (data['isNoteVisible'] as bool? ?? true)
                  : true;

              final roleLabel = isServant
                  ? (specialization.isNotEmpty ? specialization : 'خادم')
                  : (isChurchAdmin ? 'مسؤول اجتماع' : '');

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'حسابي',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF172B4D),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => _showEditProfileDialog(
                              context: context,
                              uid: uid,
                              isServant: isServant,
                              isChurchAdmin: isChurchAdmin,
                              currentName: name,
                              currentAddress: address,
                              currentSpecialization: specialization,
                            ),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 95,
                            height: 95,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondaryColor,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 52,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            roleLabel,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildSectionTitle('المعلومات الشخصية'),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      title: 'البريد الإلكتروني',
                      value: email,
                    ),
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      title: 'رقم الهاتف',
                      value: phone.isEmpty ? '—' : phone,
                    ),
                    _buildInfoCard(
                      icon: Icons.location_on_outlined,
                      title: 'العنوان',
                      value: address.isEmpty ? '—' : address,
                    ),

                    if (isServant) ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('نوع الخدمة'),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.badge_outlined,
                        title: 'التخصص',
                        value: specialization.isEmpty ? '—' : specialization,
                      ),

                      const SizedBox(height: 16),
                      _buildSectionTitle('نوتة التوفر'),
                      const SizedBox(height: 12),
                      _buildNoteVisibilityCard(
                        uid: uid,
                        isVisible: isNoteVisible,
                      ),
                    ],

                    const SizedBox(height: 28),

                    _buildSectionTitle('إعدادات الحساب'),
                    const SizedBox(height: 12),

                    _buildActionTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'تغيير كلمة المرور',
                      onTap: () {},
                    ),
                    _buildActionTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'الإشعارات',
                      onTap: () {},
                    ),
                    _buildActionTile(
                      icon: Icons.help_outline_rounded,
                      title: 'المساعدة والدعم',
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              pushAndRemoveUntil(context, Routes.login),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 14),
                                Text(
                                  'تسجيل الخروج',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // =========================
  // Note visibility switch
  // =========================
  Widget _buildNoteVisibilityCard({
    required String uid,
    required bool isVisible,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'إظهار النوتة الشخصية للمسؤولين اللي بيدعوني',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: isVisible,
            activeColor: AppColors.primaryColor,
            onChanged: (value) {
              _servantRepo.setNoteVisibility(uid: uid, isVisible: value);
            },
          ),
        ],
      ),
    );
  }

  // =========================
  // Edit dialog
  // =========================
  void _showEditProfileDialog({
    required BuildContext context,
    required String uid,
    required bool isServant,
    required bool isChurchAdmin,
    required String currentName,
    required String currentAddress,
    required String currentSpecialization,
  }) {
    final nameController = TextEditingController(text: currentName);
    final addressController = TextEditingController(text: currentAddress);
    String? selectedSpecialization = currentSpecialization.isEmpty
        ? null
        : currentSpecialization;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text('تعديل البروفايل'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'الاسم'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'العنوان'),
                    ),
                    if (isServant) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'نوع الخدمة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: specializations.map((s) {
                          final selected = selectedSpecialization == s;
                          return ChoiceChip(
                            label: Text(s),
                            selected: selected,
                            onSelected: (_) {
                              setDialogState(() => selectedSpecialization = s);
                            },
                            selectedColor: AppColors.primaryColor,
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    final newAddress = addressController.text.trim();

                    if (isServant) {
                      await _servantRepo.updateServantFields(
                        uid: uid,
                        update: ServantUpdate(
                          name: newName.isEmpty ? null : newName,
                          address: newAddress.isEmpty ? null : newAddress,
                          specialization: selectedSpecialization,
                        ),
                      );
                    } else if (isChurchAdmin) {
                      await _churchAdminRepo.updateChurchAdminFields(
                        uid: uid,
                        update: ChurchAdminUpdate(
                          name: newName.isEmpty ? null : newName,
                          city: newAddress.isEmpty ? null : newAddress,
                        ),
                      );
                    }

                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Color(0xFF172B4D),
      ),
    );
  }

  static Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.accentColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172B4D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.accentColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primaryColor, size: 22),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF172B4D),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
