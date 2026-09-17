// lib/features/completeProfile/presentation/screens/complete_profile_screen.dart

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khadem/core/routes/navigation.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/services/cloudinary_service.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:khadem/features/completeProfile/presentation/bloc/complete_profile_bloc.dart';
import 'package:khadem/features/completeProfile/presentation/bloc/complete_profile_event.dart';
import 'package:khadem/features/completeProfile/presentation/bloc/complete_profile_state.dart';

class CompleteProfileScreen extends StatefulWidget {
  final bool isServant;
  final bool isChurchAdmin;

  const CompleteProfileScreen({
    super.key,
    required this.isServant,
    required this.isChurchAdmin,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final phone1Controller = TextEditingController();
  final phone2Controller = TextEditingController();
  final ageController = TextEditingController();
  final churchController = TextEditingController();
  final bioController = TextEditingController();
  final meetingNameController = TextEditingController();

  String? selectedGovernorate;
  String? selectedSpecialization;

  TimeOfDay? openHour;
  TimeOfDay? closeHour;

  File? imageFile;
  bool imageError = false;

  final List<String> governorates = const [
    'القاهرة',
    'الجيزة',
    'القليوبية',
    'الإسكندرية',
    'البحيرة',
    'مطروح',
    'دمياط',
    'الدقهلية',
    'الشرقية',
    'الغربية',
    'المنوفية',
    'كفر الشيخ',
    'بورسعيد',
    'الإسماعيلية',
    'السويس',
    'شمال سيناء',
    'جنوب سيناء',
    'بني سويف',
    'الفيوم',
    'المنيا',
    'أسيوط',
    'سوهاج',
    'قنا',
    'الأقصر',
    'أسوان',
    'البحر الأحمر',
    'الوادي الجديد',
  ];

  final List<Map<String, dynamic>> specializations = const [
    {'name': 'مرنم', 'icon': Icons.music_note_rounded},
    {'name': 'واعظ', 'icon': Icons.record_voice_over_rounded},
    {'name': 'فريق تسبيح', 'icon': Icons.groups_2_rounded},
    {'name': 'فريق دراما', 'icon': Icons.theater_comedy_rounded},
  ];

  @override
  void dispose() {
    phone1Controller.dispose();
    phone2Controller.dispose();
    ageController.dispose();
    churchController.dispose();
    bioController.dispose();
    meetingNameController.dispose();
    super.dispose();
  }

  // =========================
  // Image
  // =========================
  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await ProfileImageService.pickImage(source: source);

      if (file == null) return;

      setState(() {
        imageFile = file;
        imageError = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الصور، تأكد من الصلاحيات')),
      );
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightBlueColor,
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: const Text('اختيار من المعرض'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightBlueColor,
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: const Text('التقاط صورة'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (imageFile != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.lightRedColor,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.redColor,
                      ),
                    ),
                    title: const Text('حذف الصورة'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() => imageFile = null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================
  // Time
  // =========================
  Future<void> _pickTime({required bool isOpen}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );

    if (picked == null) return;

    setState(() {
      if (isOpen) {
        openHour = picked;
      } else {
        closeHour = picked;
      }
    });
  }

  String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;

    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';

    return '$hour:$minute $period';
  }

  // =========================
  // Save
  // =========================
  void _saveProfile() {
    final isFormValid = _formKey.currentState!.validate();

    // الصورة إجبارية للخادم فقط
    final needsImage = widget.isServant && imageFile == null;

    if (needsImage) {
      setState(() => imageError = true);
    }

    if (!isFormValid || needsImage) {
      if (needsImage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('من فضلك أضف صورة شخصية')));
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ، برجاء تسجيل الدخول مرة أخرى')),
      );
      return;
    }

    context.read<CompleteProfileBloc>().add(
      SaveCompleteProfileEvent(
        uid: user.uid,
        isServant: widget.isServant,
        isChurchAdmin: widget.isChurchAdmin,
        name: user.displayName ?? '',
        email: user.email ?? '',
        imageFile: imageFile,
        phone1: phone1Controller.text.trim(),
        phone2: phone2Controller.text.trim(),
        age: ageController.text.trim(),
        governorate: selectedGovernorate!,
        church: churchController.text.trim(),
        bio: bioController.text.trim(),
        specialization: widget.isServant ? selectedSpecialization : null,
        openHour: widget.isServant ? _formatTime(openHour) : null,
        closeHour: widget.isServant ? _formatTime(closeHour) : null,
        meetingName: widget.isChurchAdmin
            ? meetingNameController.text.trim()
            : null,
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<CompleteProfileBloc, CompleteProfileState>(
        listener: (context, state) {
          if (state is CompleteProfileSuccessState) {
            pushWithReplacement(
              context,
              Routes.main,
              extra: {
                'isServant': widget.isServant,
                'isChurchAdmin': widget.isChurchAdmin,
              },
            );
          }

          if (state is CompleteProfileErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is CompleteProfileLoadingState;

          return Scaffold(
            backgroundColor: AppColors.scaffoldColor,
            body: Column(
              children: [
                _buildHeader(user?.displayName ?? 'أهلاً بك'),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== البيانات الأساسية =====
                          _SectionCard(
                            icon: Icons.person_outline_rounded,
                            title: 'البيانات الأساسية',
                            children: [
                              _buildField(
                                controller: phone1Controller,
                                label: 'رقم الهاتف',
                                hint: '01xxxxxxxxx',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(11),
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'رقم الهاتف مطلوب';
                                  }
                                  if (!RegExp(
                                    r'^01[0125]\d{8}$',
                                  ).hasMatch(value.trim())) {
                                    return 'رقم هاتف غير صحيح';
                                  }
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: phone2Controller,
                                label: 'رقم هاتف إضافي (اختياري)',
                                hint: '01xxxxxxxxx',
                                icon: Icons.phone_iphone_rounded,
                                keyboardType: TextInputType.phone,
                                isRequired: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(11),
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return null;
                                  }
                                  if (!RegExp(
                                    r'^01[0125]\d{8}$',
                                  ).hasMatch(value.trim())) {
                                    return 'رقم هاتف غير صحيح';
                                  }
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: ageController,
                                label: 'السن',
                                hint: 'مثال: 25',
                                icon: Icons.cake_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'السن مطلوب';
                                  }
                                  final age = int.tryParse(value.trim());
                                  if (age == null) return 'اكتب سن صحيح';
                                  if (age < 18) {
                                    return 'يجب أن يكون عمرك 18 سنة على الأقل';
                                  }
                                  if (age > 90) return 'اكتب سن صحيح';
                                  return null;
                                },
                              ),
                              _buildGovernorateDropdown(),
                              const SizedBox(height: 18),
                              _buildField(
                                controller: churchController,
                                label: 'اسم الكنيسة',
                                hint: 'مثال: كنيسة مارجرجس',
                                icon: Icons.church_outlined,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'اسم الكنيسة مطلوب';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          // ===== بيانات الخادم =====
                          if (widget.isServant) ...[
                            const SizedBox(height: 18),
                            _SectionCard(
                              icon: Icons.volunteer_activism_rounded,
                              title: 'بيانات الخادم',
                              children: [
                                _buildSpecializations(),
                                const SizedBox(height: 20),
                                _buildTimeRow(),
                                const SizedBox(height: 18),
                                _buildField(
                                  controller: bioController,
                                  label: 'نبذة عنك (اختياري)',
                                  hint: 'اكتب نبذة قصيرة عن خدمتك وخبرتك',
                                  icon: Icons.notes_rounded,
                                  isRequired: false,
                                  maxLines: 4,
                                  maxLength: 200,
                                ),
                              ],
                            ),
                          ],

                          // ===== بيانات مسؤول الاجتماع =====
                          if (widget.isChurchAdmin) ...[
                            const SizedBox(height: 18),
                            _SectionCard(
                              icon: Icons.groups_outlined,
                              title: 'بيانات مسؤول الاجتماع',
                              children: [
                                _buildField(
                                  controller: meetingNameController,
                                  label: 'اسم الاجتماع',
                                  hint: 'مثال: اجتماع الشباب',
                                  icon: Icons.groups_outlined,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'اسم الاجتماع مطلوب';
                                    }
                                    return null;
                                  },
                                ),
                                if (!widget.isServant)
                                  _buildField(
                                    controller: bioController,
                                    label: 'نبذة عن الاجتماع (اختياري)',
                                    hint: 'اكتب نبذة قصيرة عن الاجتماع',
                                    icon: Icons.notes_rounded,
                                    isRequired: false,
                                    maxLines: 4,
                                    maxLength: 200,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildSaveButton(isLoading),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
      decoration: const BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'إكمال البيانات',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'خطوة 2 من 2',
                    style: TextStyle(color: AppColors.whiteColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildAvatar(),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                color: AppColors.whiteColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.isServant
                  ? 'الصورة الشخصية مطلوبة للخادم'
                  : 'يمكنك إضافة صورة شخصية (اختياري)',
              style: TextStyle(
                color: imageError
                    ? AppColors.warningTextColor
                    : AppColors.whiteColor.withOpacity(0.75),
                fontSize: 12,
                fontWeight: imageError ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _showImageOptions,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteColor.withOpacity(0.2),
              border: Border.all(
                color: imageError
                    ? AppColors.softRedColor
                    : AppColors.whiteColor,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: imageFile != null
                  ? Image.file(
                      imageFile!,
                      width: 104,
                      height: 104,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: AppColors.whiteColor,
                      size: 54,
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                shape: BoxShape.circle,
                boxShadow: AppColors.softShadow,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primaryColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isRequired = true,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDarkColor,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(color: AppColors.redColor, fontSize: 14),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            maxLines: maxLines,
            maxLength: maxLength,
            style: const TextStyle(color: AppColors.textDarkColor),
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              hintStyle: const TextStyle(
                color: AppColors.hintColor,
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 21),
              filled: true,
              fillColor: AppColors.fieldColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: _fieldBorder(Colors.transparent),
              enabledBorder: _fieldBorder(Colors.transparent),
              focusedBorder: _fieldBorder(AppColors.primaryColor, width: 1.4),
              errorBorder: _fieldBorder(AppColors.redColor),
              focusedErrorBorder: _fieldBorder(AppColors.redColor, width: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildGovernorateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'المحافظة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDarkColor,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(color: AppColors.redColor, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedGovernorate,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primaryColor,
          ),
          hint: const Text(
            'اختر المحافظة',
            style: TextStyle(color: AppColors.hintColor, fontSize: 13),
          ),
          borderRadius: BorderRadius.circular(16),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primaryColor,
              size: 21,
            ),
            filled: true,
            fillColor: AppColors.fieldColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: _fieldBorder(Colors.transparent),
            enabledBorder: _fieldBorder(Colors.transparent),
            focusedBorder: _fieldBorder(AppColors.primaryColor, width: 1.4),
            errorBorder: _fieldBorder(AppColors.redColor),
            focusedErrorBorder: _fieldBorder(AppColors.redColor, width: 1.4),
          ),
          items: governorates.map((governorate) {
            return DropdownMenuItem<String>(
              value: governorate,
              child: Text(governorate),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedGovernorate = value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) return 'اختر المحافظة';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSpecializations() {
    return FormField<String>(
      initialValue: selectedSpecialization,
      validator: (_) {
        if (selectedSpecialization == null) return 'اختر التخصص';
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'التخصص',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkColor,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(color: AppColors.redColor, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: specializations.map((item) {
                final name = item['name'] as String;
                final isSelected = selectedSpecialization == name;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedSpecialization = name);
                    field.didChange(name);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.fieldColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 18,
                          color: isSelected
                              ? AppColors.whiteColor
                              : AppColors.textGreyColor,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          name,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.whiteColor
                                : AppColors.textDarkColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: AppColors.redColor,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTimeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مواعيد الخدمة المتاحة (اختياري)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTimeBox(
                label: 'من',
                value: _formatTime(openHour),
                onTap: () => _pickTime(isOpen: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeBox(
                label: 'إلى',
                value: _formatTime(closeHour),
                onTap: () => _pickTime(isOpen: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeBox({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.fieldColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              value ?? label,
              style: TextStyle(
                color: value == null
                    ? AppColors.hintColor
                    : AppColors.textDarkColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: isLoading ? null : AppColors.mainGradient,
              color: isLoading ? AppColors.borderColor : null,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'حفظ البيانات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================
// Section Card
// =========================
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 4),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.lightBlueColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
