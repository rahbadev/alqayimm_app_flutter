import 'package:flutter/material.dart';

/// أنواع الأزرار المختلفة
enum ActionButtonType { filled, outlined, elevated }

/// ويدجت زر العمل الموحد للتطبيق
class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ActionButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;

  const ActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ActionButtonType.filled,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding =
        padding ?? const EdgeInsets.symmetric(vertical: 14, horizontal: 20);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    Widget buttonWidget;

    switch (type) {
      case ActionButtonType.filled:
        buttonWidget =
            icon != null
                ? FilledButton.icon(
                  onPressed: isLoading ? null : onPressed,
                  icon: _buildIcon(context),
                  label: Text(text),
                  style: FilledButton.styleFrom(
                    padding: defaultPadding,
                    shape: shape,
                  ),
                )
                : FilledButton(
                  onPressed: isLoading ? null : onPressed,
                  style: FilledButton.styleFrom(
                    padding: defaultPadding,
                    shape: shape,
                  ),
                  child: _buildContent(),
                );
        break;

      case ActionButtonType.outlined:
        buttonWidget =
            icon != null
                ? OutlinedButton.icon(
                  onPressed: isLoading ? null : onPressed,
                  icon: _buildIcon(context),
                  label: Text(text),
                  style: OutlinedButton.styleFrom(
                    padding: defaultPadding,
                    shape: shape,
                  ),
                )
                : OutlinedButton(
                  onPressed: isLoading ? null : onPressed,
                  style: OutlinedButton.styleFrom(
                    padding: defaultPadding,
                    shape: shape,
                  ),
                  child: _buildContent(),
                );
        break;

      case ActionButtonType.elevated:
        buttonWidget =
            icon != null
                ? ElevatedButton.icon(
                  onPressed: isLoading ? null : onPressed,
                  icon: _buildIcon(context),
                  label: Text(text),
                  style: ElevatedButton.styleFrom(
                    padding: defaultPadding,
                    shape: shape,
                  ),
                )
                : ElevatedButton(
                  onPressed: isLoading ? null : onPressed,
                  style: ElevatedButton.styleFrom(
                    padding: defaultPadding,
                    shape: shape,
                  ),
                  child: _buildContent(),
                );
        break;
    }

    return isExpanded ? Expanded(child: buttonWidget) : buttonWidget;
  }

  Widget _buildIcon(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color:
              type == ActionButtonType.filled
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return Icon(icon);
  }

  Widget _buildContent() {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    return Text(text);
  }
}
