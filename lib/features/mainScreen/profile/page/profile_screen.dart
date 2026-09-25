import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/services/cloudinary_service.dart';
import 'package:khadem/core/services/notification_service.dart';
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
  bool _isUploadingImage = false;
  final ServantRepo _servantRepo = ServantRepo();
  final ChurchAdminRepo _churchAdminRepo = ChurchAdminRepo();

  final List<String> specializations = [
    'مرنم',
    'واعظ',
    'فريق تسبيح',
    'فريق دراما',
  ];

  final List<String> governorates = [
    'القاهرة',
    'الجيزة',
    'القليوبية',
    'الإسكندرية',
    'البحيرة',
    'الشرقية',
    'الدقهلية',
    'الغربية',
    'المنوفية',
    'كفر الشيخ',
    'دمياط',
    'بورسعيد',
    'الإسماعيلية',
    'السويس',
    'الفيوم',
    'بني سويف',
    'المنيا',
    'أسيوط',
    'سوهاج',
    'قنا',
    'الأقصر',
    'أسوان',
    'البحر الأحمر',
    'الوادي الجديد',
    'مطروح',
    'شمال سيناء',
    'جنوب سيناء',
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'خطأ: المستخدم غير مسجل الدخول',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text(
                    'لم يتم العثور على بيانات الحساب',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                );
              }

              final data = snapshot.data!.data() ?? {};

              final isServant = data['isServant'] == true;
              final isChurchAdmin = data['isChurchAdmin'] == true;

              final name = (data['name'] as String?) ?? 'مستخدم';
              final imageUrl =
                  (data['image'] as String?) ??
                  (data['imageUrl'] as String?) ??
                  '';

              final email =
                  (data['email'] as String?) ??
                  FirebaseAuth.instance.currentUser?.email ??
                  '';

              final phone1 = (data['phone1'] as String?) ?? '';
              final phone2 = (data['phone2'] as String?) ?? '';

              final servantAddress = (data['address'] as String?) ?? '';

              final adminCity = (data['city'] as String?) ?? '';

              final address = isServant ? servantAddress : adminCity;

              final specialization = (data['specialization'] as String?) ?? '';

              final governorate = (data['governorate'] as String?) ?? '';

              final isNoteVisible = isServant
                  ? (data['isNoteVisible'] as bool? ?? false)
                  : false;

              final autoAvailabilityEnabled = isServant
                  ? (data['autoAvailabilityEnabled'] as bool? ?? false)
                  : false;

              final roleLabel = isServant
                  ? (specialization.isNotEmpty ? specialization : 'خادم')
                  : (isChurchAdmin ? 'مسؤول اجتماع' : '');

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================
                    // Header
                    // =========================
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
                              currentPhone1: phone1,
                              currentPhone2: phone2,
                              currentGovernorate: governorate,
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

                    // =========================
                    // Profile Header
                    // =========================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showImageSourceSheet(uid),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 105,
                                  height: 105,
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            width: 97,
                                            height: 97,
                                            fit: BoxFit.cover,
                                            gaplessPlayback: false,
                                            errorBuilder: (_, __, ___) {
                                              return Container(
                                                color: AppColors.secondaryColor,
                                                child: const Icon(
                                                  Icons.person_rounded,
                                                  size: 52,
                                                  color: AppColors.primaryColor,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: AppColors.secondaryColor,
                                            child: const Icon(
                                              Icons.person_rounded,
                                              size: 52,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                  ),
                                ),

                                // زر تغيير الصورة
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: _isUploadingImage
                                      ? const Padding(
                                          padding: EdgeInsets.all(8),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 17,
                                          color: Colors.white,
                                        ),
                                ),
                              ],
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

                    // =========================
                    // Personal Information
                    // =========================
                    _buildSectionTitle('المعلومات الشخصية'),

                    const SizedBox(height: 12),

                    // Email - READ ONLY
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      title: 'البريد الإلكتروني',
                      value: email,
                    ),

                    // Phone 1
                    if (isServant)
                      _buildInfoCard(
                        icon: Icons.phone_outlined,
                        title: 'رقم الهاتف الأساسي',
                        value: phone1.isEmpty ? '—' : phone1,
                      )
                    else
                      _buildInfoCard(
                        icon: Icons.phone_outlined,
                        title: 'رقم الهاتف',
                        value: phone1.isEmpty ? '—' : phone1,
                      ),

                    // Phone 2
                    if (isServant && phone2.isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.phone_android_outlined,
                        title: 'رقم هاتف إضافي',
                        value: phone2,
                      ),

                    // Governorate
                    if (isServant)
                      _buildInfoCard(
                        icon: Icons.location_city_outlined,
                        title: 'المحافظة',
                        value: governorate.isEmpty ? '—' : governorate,
                      ),

                    // Address / City
                    _buildInfoCard(
                      icon: Icons.location_on_outlined,
                      title: isServant ? 'العنوان' : 'المدينة',
                      value: address.isEmpty ? '—' : address,
                    ),

                    // =========================
                    // Servant Section
                    // =========================
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

                      // =========================
                      // Note Visibility
                      // =========================
                      _buildNoteVisibilityCard(
                        uid: uid,
                        isVisible: isNoteVisible,
                      ),

                      const SizedBox(height: 10),

                      // =========================
                      // Auto Availability
                      // =========================
                      _buildAutoAvailabilityCard(
                        uid: uid,
                        isEnabled: autoAvailabilityEnabled,
                      ),
                    ],

                    const SizedBox(height: 28),

                    // =========================
                    // Account Settings
                    // =========================
                    _buildSectionTitle('إعدادات الحساب'),

                    const SizedBox(height: 12),

                    _buildActionTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'تغيير كلمة المرور',
                      onTap: () {
                        // TODO:
                        // Implement change password
                      },
                    ),

                    _buildActionTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'الإشعارات',
                      onTap: () {
                        // TODO:
                        // Notifications settings
                      },
                    ),

                    _buildActionTile(
                      icon: Icons.help_outline_rounded,
                      title: 'المساعدة والدعم',
                      onTap: () {
                        // TODO:
                        // Help & support
                      },
                    ),

                    const SizedBox(height: 12),

                    // =========================
                    // Logout
                    // =========================
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
                          onTap: () async {
                            await NotificationService.instance.removeToken();
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) return;
                            pushAndRemoveUntil(context, Routes.login);
                          },
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

  // =========================================================
  // Note Visibility Card
  // =========================================================

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
            onChanged: (value) async {
              try {
                await _servantRepo.setNoteVisibility(
                  uid: uid,
                  isVisible: value,
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'حدث خطأ أثناء تحديث إعداد النوتة',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Auto Availability Card
  // =========================================================

  Widget _buildAutoAvailabilityCard({
    required String uid,
    required bool isEnabled,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            color: AppColors.primaryColor,
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حساب التوفر تلقائيًا',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'عند التفعيل، يصبح اليوم غير متاح تلقائيًا عند وجود 3 مواعيد أو أكثر.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch(
            value: isEnabled,
            activeColor: AppColors.primaryColor,
            onChanged: (value) async {
              try {
                await _servantRepo.setAutoAvailability(
                  uid: uid,
                  enabled: value,
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'حدث خطأ أثناء تحديث إعداد التوفر',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Edit Profile Dialog
  // =========================================================

  void _showEditProfileDialog({
    required BuildContext context,
    required String uid,
    required bool isServant,
    required bool isChurchAdmin,
    required String currentName,
    required String currentPhone1,
    required String currentPhone2,
    required String currentGovernorate,
    required String currentAddress,
    required String currentSpecialization,
  }) {
    final nameController = TextEditingController(text: currentName);

    final phone1Controller = TextEditingController(text: currentPhone1);

    final phone2Controller = TextEditingController(text: currentPhone2);

    final addressController = TextEditingController(text: currentAddress);

    String? selectedSpecialization = currentSpecialization.isEmpty
        ? null
        : currentSpecialization;

    String? selectedGovernorate = currentGovernorate.isEmpty
        ? null
        : currentGovernorate;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: const Text(
                'تعديل البروفايل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),

              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =========================
                      // Name
                      // =========================
                      TextField(
                        controller: nameController,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText: 'الاسم',
                          labelStyle: const TextStyle(fontFamily: 'Cairo'),
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      // =========================
                      // Email - Read Only
                      // =========================
                      const SizedBox(height: 14),

                      TextField(
                        controller: TextEditingController(
                          text: FirebaseAuth.instance.currentUser?.email ?? '',
                        ),
                        readOnly: true,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          labelStyle: const TextStyle(fontFamily: 'Cairo'),
                          prefixIcon: const Icon(Icons.email_outlined),
                          helperText: 'لا يمكن تعديل البريد الإلكتروني من هنا',
                          helperStyle: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      // =========================
                      // Servant Fields
                      // =========================
                      if (isServant) ...[
                        const SizedBox(height: 14),

                        TextField(
                          controller: phone1Controller,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            labelText: 'رقم الهاتف الأساسي',
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: phone2Controller,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            labelText: 'رقم هاتف إضافي',
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(
                              Icons.phone_android_outlined,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // =========================
                        // Governorate
                        // =========================
                        DropdownButtonFormField<String>(
                          value: selectedGovernorate,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'المحافظة',
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(
                              Icons.location_city_outlined,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: governorates.map((governorate) {
                            return DropdownMenuItem<String>(
                              value: governorate,
                              child: Text(
                                governorate,
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedGovernorate = value);
                          },
                        ),

                        const SizedBox(height: 14),

                        // =========================
                        // Address
                        // =========================
                        TextField(
                          controller: addressController,
                          maxLines: 2,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            labelText: 'العنوان',
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // =========================
                        // Specialization
                        // =========================
                        const Text(
                          'نوع الخدمة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: specializations.map((specialization) {
                            final selected =
                                selectedSpecialization == specialization;

                            return ChoiceChip(
                              label: Text(
                                specialization,
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                              selected: selected,
                              onSelected: (_) {
                                setDialogState(
                                  () => selectedSpecialization = specialization,
                                );
                              },
                              selectedColor: AppColors.primaryColor,
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // =========================
                      // Church Admin
                      // =========================
                      if (!isServant && isChurchAdmin) ...[
                        const SizedBox(height: 14),

                        TextField(
                          controller: addressController,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            labelText: 'المدينة',
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(
                              Icons.location_city_outlined,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final newName = nameController.text.trim();

                    final newPhone1 = phone1Controller.text.trim();

                    final newPhone2 = phone2Controller.text.trim();

                    final newAddress = addressController.text.trim();

                    if (newName.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'من فضلك اكتب الاسم',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      if (isServant) {
                        await _servantRepo.updateServantFields(
                          uid: uid,
                          update: ServantUpdate(
                            name: newName,
                            phone1: newPhone1.isEmpty ? null : newPhone1,
                            phone2: newPhone2.isEmpty ? null : newPhone2,
                            governorate: selectedGovernorate,
                            address: newAddress.isEmpty ? null : newAddress,
                            specialization: selectedSpecialization,
                          ),
                        );
                      } else if (isChurchAdmin) {
                        await _churchAdminRepo.updateChurchAdminFields(
                          uid: uid,
                          update: ChurchAdminUpdate(
                            name: newName,
                            city: newAddress.isEmpty ? null : newAddress,
                          ),
                        );
                      }

                      if (!dialogContext.mounted) {
                        return;
                      }

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم تحديث بيانات البروفايل بنجاح',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!dialogContext.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'حدث خطأ أثناء حفظ التعديلات',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'حفظ',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================
  // Section Title
  // =========================================================

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

  // =========================================================
  // Info Card
  // =========================================================

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

  // =========================================================
  // Action Tile
  // =========================================================

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

  void _showImageSourceSheet(String uid) {
    if (_isUploadingImage) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'تغيير صورة البروفايل',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildImageSourceOption(
                          icon: Icons.photo_library_rounded,
                          title: 'المعرض',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _pickAndUploadImage(
                              uid: uid,
                              source: ImageSource.gallery,
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildImageSourceOption(
                          icon: Icons.camera_alt_rounded,
                          title: 'الكاميرا',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _pickAndUploadImage(
                              uid: uid,
                              source: ImageSource.camera,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage({
    required String uid,
    required ImageSource source,
  }) async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      final File? image = await ProfileImageService.pickImage(source: source);

      if (image == null) {
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
          });
        }
        return;
      }

      final imageUrl = await ProfileImageService.uploadProfileImage(
        uid: uid,
        file: image,
      );

      debugPrint('Saving new image URL to Firestore: $imageUrl');

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'image': imageUrl,
      });

      if (!mounted) return;

      setState(() {
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تحديث صورة البروفايل بنجاح',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء تحديث الصورة: $e',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.accentColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColors.primaryColor),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172B4D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
