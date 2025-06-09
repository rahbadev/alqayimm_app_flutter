import 'package:flutter/material.dart';

class NavBarIcon extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final bool isActive;

  const NavBarIcon({
    super.key,
    this.icon,
    this.assetPath,
    this.isActive = false,
  }) : assert(icon != null || assetPath != null, 'يجب تحديد أيقونة أو صورة');

  @override
  Widget build(BuildContext context) {
    final color =
        isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withAlpha(160);

    if (icon != null) {
      return Icon(icon, color: color, size: 28);
    } else {
      return Image.asset(
        assetPath!,
        width: 32,
        height: 32,
        color: isActive ? null : Colors.grey, // لون باهت عند عدم التفعيل
      );
    }
  }
}
