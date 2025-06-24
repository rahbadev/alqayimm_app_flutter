import 'package:flutter/material.dart';

class AnimatedIconSwitcher extends StatelessWidget {
  final Widget icon;
  final Duration duration;
  final Curve curve;

  const AnimatedIconSwitcher({
    super.key,
    required this.icon,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder:
          (child, animation) => ScaleTransition(scale: animation, child: child),
      child: icon,
    );
  }
}
