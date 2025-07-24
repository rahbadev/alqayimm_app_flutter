import 'package:flutter/material.dart';

/// ويدجت حاوية محتوى موحدة
class ContentContainer extends StatelessWidget {
  final Widget child;

  const ContentContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(50),
        ),
      ),
      child: child,
    );
  }
}

/// ويدجت حاوية Dialog موحدة (بديلة للدالة buildDialogContainer)
class DialogContainer extends StatelessWidget {
  final Widget child;

  const DialogContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              spreadRadius: 1,
              color: Theme.of(context).colorScheme.shadow.withAlpha(100),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// ويدجت عنوان قسم موحد
class SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionTitle({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        if (icon != null) const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }
}

/// ويدجت قسم موحد مع إمكانية إضافة عنوان اختياري
class SectionContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;

  const SectionContainer({
    super.key,
    required this.child,
    this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty)
            SectionTitle(title: title!, icon: icon),
          if (title != null && title!.isNotEmpty) const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
