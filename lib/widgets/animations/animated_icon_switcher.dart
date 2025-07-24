import 'package:flutter/cupertino.dart';

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
