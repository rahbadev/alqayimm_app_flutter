import 'package:flutter/material.dart';

/// ودجيت مخصص لحاوية الفلاتر والبحث
/// يوفر تصميم موحد لحاويات الفلاتر في واجهات مختلفة
class FilterContainer extends StatelessWidget {
  /// المحتوى المراد عرضه
  final Widget child;

  /// لون الخلفية (اختياري)
  final Color? backgroundColor;

  /// الحشو الداخلي
  final EdgeInsets padding;

  /// شعاع الحدود
  final BorderRadius? borderRadius;

  /// إظهار الظل
  final bool showShadow;

  /// ارتفاع الظل
  final double elevation;

  /// لون الحدود (اختياري)
  final Color? borderColor;

  /// عرض الحدود
  final double borderWidth;

  const FilterContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.showShadow = false,
    this.elevation = 2.0,
    this.borderColor,
    this.borderWidth = 0.0,
  });

  /// مُنشئ لحاوية فلاتر عادية
  const FilterContainer.standard({super.key, required this.child})
    : backgroundColor = null,
      padding = const EdgeInsets.all(16),
      borderRadius = null,
      showShadow = false,
      elevation = 2.0,
      borderColor = null,
      borderWidth = 0.0;

  /// مُنشئ لحاوية فلاتر مع زاوية منحنية سفلية
  const FilterContainer.bottomRounded({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
  }) : borderRadius = const BorderRadius.only(
         bottomLeft: Radius.circular(20),
         bottomRight: Radius.circular(20),
       ),
       showShadow = false,
       elevation = 2.0,
       borderColor = null,
       borderWidth = 0.0;

  /// مُنشئ لحاوية فلاتر مع زاوية منحنية علوية
  const FilterContainer.topRounded({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
  }) : borderRadius = const BorderRadius.only(
         topLeft: Radius.circular(20),
         topRight: Radius.circular(20),
       ),
       showShadow = false,
       elevation = 2.0,
       borderColor = null,
       borderWidth = 0.0;

  /// مُنشئ لحاوية فلاتر مرتفعة (مع ظل)
  const FilterContainer.elevated({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 4.0,
  }) : borderRadius = const BorderRadius.all(Radius.circular(12)),
       showShadow = true,
       borderColor = null,
       borderWidth = 0.0;

  /// مُنشئ لحاوية فلاتر مع حدود
  const FilterContainer.bordered({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.all(16),
  }) : borderRadius = const BorderRadius.all(Radius.circular(12)),
       showShadow = false,
       elevation = 2.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerLow,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(12)),
        border:
            borderWidth > 0
                ? Border.all(
                  color: borderColor ?? colorScheme.outline.withOpacity(0.2),
                  width: borderWidth,
                )
                : null,
      ),
      child: child,
    );

    if (showShadow) {
      return Material(
        elevation: elevation,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(12)),
        color: backgroundColor ?? colorScheme.surfaceContainerLow,
        child: Container(padding: padding, child: child),
      );
    }

    return container;
  }
}
