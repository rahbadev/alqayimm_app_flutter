import 'package:flutter/material.dart';

class AnimatedIconSwitcher extends StatelessWidget {
  final Widget icon;
  final Duration duration;
  final Curve curve;
  const AnimatedIconSwitcher({
    super.key,
    required this.icon,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: duration,
    switchInCurve: curve,
    switchOutCurve: curve,
    transitionBuilder:
        (child, animation) => ScaleTransition(scale: animation, child: child),
    child: icon,
  );
}

class CompleteIconButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onTap;
  final double? size;
  final bool outlined;

  const CompleteIconButton({
    super.key,
    required this.isCompleted,
    this.onTap,
    this.size,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = AnimatedIconSwitcher(
      icon: Icon(
        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        key: ValueKey(isCompleted),
        color: isCompleted ? Colors.green : null,
        size: size,
      ),
    );

    if (outlined) {
      return IconButton.outlined(
        icon: iconWidget,
        tooltip: isCompleted ? 'تم الإكمال' : 'لم يتم الإكمال',
        onPressed: onTap,
      );
    } else {
      return IconButton(
        icon: iconWidget,
        tooltip: isCompleted ? 'تم الإكمال' : 'لم يتم الإكمال',
        onPressed: onTap,
      );
    }
  }
}

class FavIconButton extends StatelessWidget {
  final bool isFavorite;
  final Color? iconColor;
  final VoidCallback? onTap;
  final double? size;
  final bool outlined; // جديد

  const FavIconButton({
    super.key,
    required this.isFavorite,
    this.iconColor,
    this.onTap,
    this.size,
    this.outlined = false, // افتراضي false
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = AnimatedIconSwitcher(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        key: ValueKey(isFavorite),
        color: isFavorite ? Colors.red : iconColor,
        size: size,
      ),
    );

    if (outlined) {
      return IconButton.outlined(
        icon: iconWidget,
        tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
        onPressed: onTap,
      );
    } else {
      return IconButton(
        icon: iconWidget,
        tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
        onPressed: onTap,
      );
    }
  }
}
