import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIcon extends StatelessWidget {
  final String assetPath; // اسم الملف أو المسار الكامل
  final double size;
  final Color? color;
  final BoxFit fit;
  final String? semanticLabel;

  const CustomIcon({
    super.key,
    required this.assetPath,
    this.size = 32,
    this.color,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  String get _fullPath {
    if (assetPath.startsWith('assets/')) {
      return assetPath;
    } else {
      return 'assets/icons/$assetPath';
    }
  }

  bool get _isSvg => _fullPath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return SvgPicture.asset(
        _fullPath,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(
          color ?? Colors.transparent,
          BlendMode.srcIn,
        ),
        fit: fit,
        semanticsLabel: semanticLabel,
      );
    } else {
      return Image.asset(
        _fullPath,
        width: size,
        height: size,
        color: color,
        fit: fit,
        semanticLabel: semanticLabel,
      );
    }
  }
}
