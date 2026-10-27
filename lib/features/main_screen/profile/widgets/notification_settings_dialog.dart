
import 'package:flutter/material.dart';
import 'package:khadem/features/main_screen/profile/data/services/notification_prefrences_services.dart';

class NotificationSettingsDialog extends StatefulWidget {
  const NotificationSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const NotificationSettingsDialog(),
    );
  }

  @override
  State<NotificationSettingsDialog> createState() =>
      _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState
    extends State<NotificationSettingsDialog> {
  final _preferencesService = NotificationPreferencesService();

  bool _chatMessages = true;
  bool _appUpdates = true;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = await _preferencesService.getPreferences();

      if (!mounted) return;

      setState(() {
        _chatMessages = preferences['chatMessages'] ?? true;
        _appUpdates = preferences['appUpdates'] ?? true;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل إعدادات الإشعارات.';
      });
    }
  }

  Future<void> _updatePreference({
    required String key,
    required bool enabled,
  }) async {
    final oldValue = key == 'chatMessages' ? _chatMessages : _appUpdates;

    setState(() {
      if (key == 'chatMessages') {
        _chatMessages = enabled;
      } else {
        _appUpdates = enabled;
      }
      _errorMessage = null;
    });

    try {
      await _preferencesService.updatePreference(
        key: key,
        enabled: enabled,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        if (key == 'chatMessages') {
          _chatMessages = oldValue;
        } else {
          _appUpdates = oldValue;
        }
        _errorMessage = 'تعذر حفظ التغيير. حاول مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إعدادات الإشعارات'),
      content: _isLoading
          ? const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('رسائل الشات'),
                  subtitle: const Text(
                    'استقبال إشعارات الرسائل الجديدة.',
                  ),
                  value: _chatMessages,
                  onChanged: (value) => _updatePreference(
                    key: 'chatMessages',
                    enabled: value,
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تحديثات التطبيق'),
                  subtitle: const Text(
                    'استقبال الإعلانات المتعلقة بتحديثات التطبيق.',
                  ),
                  value: _appUpdates,
                  onChanged: (value) => _updatePreference(
                    key: 'appUpdates',
                    enabled: value,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
