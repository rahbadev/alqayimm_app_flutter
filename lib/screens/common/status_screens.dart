import 'package:flutter/material.dart';

class Status extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onTapButton;

  const Status._({
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onTapButton,
  });

  /// حالة التحميل (Progress)
  factory Status.showProgress({
    String? title,
    String? subtitle,
    int? progress,
  }) {
    Widget progressWidget = CircularProgressIndicator(
      strokeWidth: 6,
      value: progress != null ? progress / 100 : null,
    );

    return Status._(
      icon: progressWidget,
      title: title ?? "جاري التحميل...",
      subtitle: subtitle ?? "تم تنزيل $progress%",
      buttonText: "$progress%",
    );
  }

  /// حالة الخطأ (Error)
  factory Status.showError({
    required String text,
    String? subtext,
    IconData? icon,
    VoidCallback? onTap,
    String? buttonText,
  }) {
    return Status._(
      icon: Icon(icon ?? Icons.error_outline, color: Colors.red, size: 60),
      title: text,
      subtitle: subtext,
      buttonText: buttonText,
      onTapButton: onTap,
    );
  }

  /// حالة الإعلام (Info)
  factory Status.showInfo({
    required String text,
    String? subtext,
    IconData? icon,
    VoidCallback? onTap,
    String? buttonText,
  }) {
    return Status._(
      icon: Icon(icon ?? Icons.info_outline, color: Colors.blue, size: 60),
      title: text,
      subtitle: subtext,
      buttonText: buttonText,
      onTapButton: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 16),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onTapButton != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onTapButton, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}
