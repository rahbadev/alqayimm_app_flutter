import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum IconTransitionType { fade, scale, rotate, slide, bounce, flip, pulse }

class AnimatedIconButtonToggle extends StatelessWidget {
  final bool isOn;
  final IconData iconOn;
  final IconData iconOff;
  final void Function() onPressed;
  final double iconSize;
  final Color colorOn;
  final Color colorOff;
  final Duration duration;
  final IconTransitionType transitionType;
  final bool isLoading;
  final bool enableHapticFeedback;
  final Widget? loadingWidget;
  final String? tooltip;

  const AnimatedIconButtonToggle({
    super.key,
    required this.isOn,
    required this.iconOn,
    required this.iconOff,
    required this.onPressed,
    this.iconSize = 24.0,
    this.colorOn = Colors.red,
    this.colorOff = Colors.grey,
    this.duration = const Duration(milliseconds: 250),
    this.transitionType = IconTransitionType.scale,
    this.isLoading = false,
    this.enableHapticFeedback = true,
    this.loadingWidget,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      iconSize: iconSize,
      onPressed:
          isLoading
              ? null
              : () {
                // Haptic Feedback
                if (enableHapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                onPressed();
              },
      icon: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (child, animation) {
          switch (transitionType) {
            case IconTransitionType.fade:
              return FadeTransition(opacity: animation, child: child);

            case IconTransitionType.scale:
              return ScaleTransition(scale: animation, child: child);

            case IconTransitionType.rotate:
              return RotationTransition(turns: animation, child: child);

            case IconTransitionType.slide:
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );

            case IconTransitionType.bounce:
              return ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0)
                    .chain(CurveTween(curve: Curves.elasticOut))
                    .animate(animation),
                child: child,
              );

            case IconTransitionType.flip:
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final isShowingFront = animation.value < 0.5;
                  return Transform(
                    alignment: Alignment.center,
                    transform:
                        Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(animation.value * 3.14159),
                    child:
                        isShowingFront
                            ? Icon(iconOff, color: colorOff, size: iconSize)
                            : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: child,
                            ),
                  );
                },
                child: child,
              );

            case IconTransitionType.pulse:
              return ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeOutBack))
                    .animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
          }
        },
        child: _buildIconChild(),
      ),
    );
  }

  Widget _buildIconChild() {
    // إذا كان في حالة تحميل
    if (isLoading) {
      return loadingWidget ??
          SizedBox(
            width: iconSize * 0.6,
            height: iconSize * 0.6,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOn ? colorOn : colorOff,
              ),
            ),
          );
    }

    // الأيقونة العادية
    return Icon(
      isOn ? iconOn : iconOff,
      key: ValueKey('${isOn}_$isLoading'),
      color: isOn ? colorOn : colorOff,
      size: iconSize,
    );
  }
}
