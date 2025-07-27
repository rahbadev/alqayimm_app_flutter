import 'package:alqayimm_app_flutter/utils/preferences_utils.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/custom_alert_dialog.dart';
import 'package:flutter/material.dart';

/// Dialog تحذير استخدام بيانات الجوال

/// عرض حوار تحذير استخدام بيانات الجوال
Future<bool?> showWifiWarningDialog(
  BuildContext context, {
  VoidCallback? onProceed,
  VoidCallback? onCancel,
}) async {
  bool dontShowAgain = false;
  return await showDialog<bool?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return CustomAlertDialog(
            icon: Icons.warning_amber_rounded,
            title: 'تحذير استخدام البيانات',
            color: Colors.orange,
            onColor: Colors.white,
            subtitle:
                'أنت متصل بشبكة بيانات الجوال. قد يؤدي التنزيل إلى استهلاك باقة البيانات الخاصة بك.\nهل تريد المتابعة؟',
            additionalContent: CheckboxListTile(
              value: dontShowAgain,
              onChanged:
                  (value) => setState(() => dontShowAgain = value ?? false),
              title: const Text(
                'عدم إظهار هذا التحذير مرة أخرى',
                style: TextStyle(fontSize: 14),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            confirmText: 'متابعة',
            cancelText: 'إلغاء',
            onConfirm: () async {
              if (dontShowAgain) {
                await PreferencesUtils.setWifiWarningDontShowAgain(true);
              }
              if (onProceed != null) onProceed();
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            onCancel: () {
              if (onCancel != null) onCancel();
              Navigator.of(context).pop(false);
            },
          );
        },
      );
    },
  );
}
