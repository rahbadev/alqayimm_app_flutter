import 'package:alqayimm_app_flutter/theme/theme.dart';
import 'package:alqayimm_app_flutter/widget/icons.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final Color? onColor;
  final String? subtitle;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const CustomAlertDialog({
    super.key,
    required this.icon,
    required this.title,
    this.color,
    this.onColor,
    this.subtitle,
    this.confirmText = 'موافق',
    this.cancelText = 'إلغاء',
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.primary,
        size: 60,
      ),
      iconPadding: const EdgeInsets.only(top: 40, bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      titlePadding: const EdgeInsets.only(top: 8, bottom: 0),
      contentPadding: const EdgeInsets.only(
        top: 2,
        bottom: 32,
        left: 16,
        right: 16,
      ),
      content:
          subtitle != null
              ? Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(175),
                ),
              )
              : null,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        ActoinButton(
          boarderColor: color,
          textColor: color,
          onTap: onCancel,
          text: cancelText,
        ),
        ActoinButton(
          backgroundColor: color,
          textColor: onColor,
          onTap: onConfirm,
          text: confirmText,
        ),
      ],
    );
  }
}

class ActoinButton extends StatelessWidget {
  const ActoinButton({
    super.key,
    this.backgroundColor,
    this.boarderColor,
    this.textColor,
    required this.onTap,
    required this.text,
  });

  final Color? backgroundColor;
  final Color? boarderColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0.5,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side:
              boarderColor != null
                  ? BorderSide(
                    color: boarderColor ?? Colors.transparent,
                    width: 1,
                  )
                  : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      onPressed: () {
        if (onTap != null) onTap!();
      },
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}

/// عرض حوار تحذير
Future<bool?> showWarningDialog({
  required BuildContext context,
  required String title,
  String? subtitle,
  String confirmText = 'موافق',
  String cancelText = 'إلغاء',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => CustomAlertDialog(
      icon: AppIcons.warning,
      title: title,
      color: MaterialTheme.warning(context),
      onColor: MaterialTheme.onWarning(context),
      subtitle: subtitle,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    ),
  );
}

/// عرض حوار تنبيه/معلومات
Future<bool?> showInfoDialog({
  required BuildContext context,
  required String title,
  String? subtitle,
  String confirmText = 'موافق',
  String cancelText = 'إلغاء',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => CustomAlertDialog(
      icon: Icons.info_outline,
      title: title,
      color: MaterialTheme.info(context),
      onColor: MaterialTheme.onInfo(context),
      subtitle: subtitle,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    ),
  );
}

/// عرض حوار تأكيد/نجاح
Future<bool?> showSuccessDialog({
  required BuildContext context,
  required String title,
  String? subtitle,
  String confirmText = 'موافق',
  String cancelText = 'إلغاء',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => CustomAlertDialog(
      icon: Icons.check_circle_outline,
      title: title,
      color: MaterialTheme.success(context),
      onColor: MaterialTheme.onSuccess(context),
      subtitle: subtitle,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    ),
  );
}
