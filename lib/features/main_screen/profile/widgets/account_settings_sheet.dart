
import 'package:flutter/material.dart';
import 'package:khadem/features/main_screen/profile/widgets/change_password_dialog.dart';
import 'package:khadem/features/main_screen/profile/widgets/notification_settings_dialog.dart';


class AccountSettingsSheet {
  const AccountSettingsSheet._();

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onHelpSupport,
    required VoidCallback onDeleteAccount,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: false,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'إعدادات الحساب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline_rounded),
                title: const Text('تغيير كلمة المرور'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ChangePasswordDialog.show(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none_rounded),
                title: const Text('الإشعارات'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  NotificationSettingsDialog.show(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline_rounded),
                title: const Text('المساعدة والدعم'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onHelpSupport();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  'حذف الحساب',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onDeleteAccount();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
