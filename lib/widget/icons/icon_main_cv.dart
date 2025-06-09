import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconWidget extends StatelessWidget {
  final IconData? iconData;
  final String? assetName;
  final double size;
  final Color? color;

  const IconWidget({
    super.key,
    this.iconData,
    this.assetName,
    this.size = 30,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color defaultColor =
        Theme.of(context).colorScheme.primary; // اللون الافتراضي

    if (iconData != null) {
      return Icon(iconData, size: size, color: color ?? defaultColor);
    } else if (assetName != null) {
      return SvgPicture.asset(
        assetName!,
        width: size,
        height: size,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        fit: BoxFit.contain,
      );
    } else {
      // في حال لم يتم تمرير أيقونة أو SVG
      return Icon(Icons.help_outline, size: size, color: defaultColor);
    }
  }
}
