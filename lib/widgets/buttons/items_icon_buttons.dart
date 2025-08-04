import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/widgets/animations/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class ActionIconButton extends StatelessWidget {
  const ActionIconButton.icon({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
    this.color,
  }) : iconWidget = null;

  const ActionIconButton.widget({
    super.key,
    required this.iconWidget,
    this.onTap,
    this.tooltip,
  }) : icon = null,
       color = null;

  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon:
          iconWidget ??
          Icon(
            icon,
            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      onPressed: onTap,
      tooltip: tooltip,
    );
  }
}

class CompleteIconButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onTap;
  final double? size;
  final Color? iconColor;

  const CompleteIconButton({
    super.key,
    required this.isCompleted,
    this.onTap,
    this.iconColor,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final String tooltip = isCompleted ? 'تم الإكمال' : 'لم يتم الإكمال';

    return AnimatedIconButtonToggle(
      isOn: isCompleted,
      iconOn: Icons.check_circle,
      iconOff: Icons.radio_button_unchecked,
      onPressed: onTap ?? () {},
      iconSize: size ?? 24,
      colorOn: Colors.green,
      colorOff: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
      transitionType: IconTransitionType.flip,
      tooltip: tooltip,
    );
  }
}

class FavIconButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  final double? size;
  final Color? iconColor;

  const FavIconButton({
    super.key,
    required this.isFavorite,
    this.onTap,
    this.iconColor,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final String tooltip = isFavorite ? 'إزالة من المفضلة' : 'الإضافة للمفضلة';

    return AnimatedIconButtonToggle(
      isOn: isFavorite,
      iconOn: Icons.favorite,
      iconOff: Icons.favorite_border,
      onPressed: onTap ?? () {},
      iconSize: size ?? 24,
      colorOn: Colors.red,
      colorOff: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
      transitionType: IconTransitionType.flip,
      tooltip: tooltip,
    );
  }
}

class DownloadButton extends StatelessWidget {
  final DownloadStatus downloadStatus;
  final double? progress;
  final VoidCallback? onTap;
  final Color? iconColor;

  const DownloadButton({
    super.key,
    required this.downloadStatus,
    this.progress,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double iconSize = 24;
    final Color color =
        iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant;

    String tooltip = switch (downloadStatus) {
      DownloadStatus.progress => 'جاري التنزيل...',
      DownloadStatus.downloaded => 'تم التنزيل',
      DownloadStatus.none => 'تنزيل',
    };

    Widget icon = switch (downloadStatus) {
      DownloadStatus.progress => SizedBox(
        key: const ValueKey('progress'),
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: color,
          value:
              (progress != null && progress! >= 0.01 && progress! <= 1.0)
                  ? progress!.clamp(0.0, 1.0)
                  : null,
          strokeCap: StrokeCap.round,
        ),
      ),
      DownloadStatus.downloaded => Icon(
        MaterialIcons.file_download_done,
        key: const ValueKey('downloaded'),
        color: color,
        size: iconSize,
      ),
      DownloadStatus.none => Icon(
        Feather.download,
        key: const ValueKey('none'),
        color: color,
        size: iconSize,
      ),
    };

    return ActionIconButton.widget(
      iconWidget: icon,
      tooltip: tooltip,
      onTap: onTap,
    );
  }
}
