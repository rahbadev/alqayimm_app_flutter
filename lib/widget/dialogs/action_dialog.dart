import 'package:alqayimm_app_flutter/widget/buttons.dart';
import 'package:alqayimm_app_flutter/widget/containers.dart';
import 'package:alqayimm_app_flutter/widget/headers.dart';
import 'package:flutter/material.dart';

/// ويدجت حوار عام موحد للتطبيق
class ActionDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final List<Widget> children;
  final String? cancelText;
  final String? confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final IconData? confirmIcon;
  final bool isLoading;
  final ActionButtonType confirmButtonType;
  final bool showActions;

  const ActionDialog({
    super.key,
    required this.headerIcon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.cancelText,
    this.confirmText,
    this.onCancel,
    this.onConfirm,
    this.confirmIcon,
    this.isLoading = false,
    this.confirmButtonType = ActionButtonType.filled,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.8; // 80% من الشاشة
    return DialogContainer(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              DialogHeader(icon: headerIcon, title: title, subtitle: subtitle),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ),
              // Action Buttons
              if (showActions) _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          ActionButton(
            text: cancelText ?? 'إلغاء',
            onPressed:
                isLoading
                    ? null
                    : (onCancel ?? () => Navigator.of(context).pop()),
            type: ActionButtonType.outlined,
            icon: Icons.close_rounded,
            isExpanded: true,
          ),
          const SizedBox(width: 16),
          ActionButton(
            text: confirmText ?? 'تأكيد',
            onPressed: isLoading ? null : onConfirm,
            type: confirmButtonType,
            icon: confirmIcon ?? Icons.check_rounded,
            isLoading: isLoading,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
