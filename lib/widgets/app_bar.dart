import 'package:alqayimm_app_flutter/theme/util.dart' as util;
import 'package:alqayimm_app_flutter/widgets/download_progress_indicator.dart';
import 'package:flutter/material.dart';

enum ShowDownloadProgress { always, onDownloading, never }

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextAlign titleAlign;
  final VoidCallback? onPressMoreLeadingIcon;
  final ShowDownloadProgress showDownloadIndicator;
  final bool showNightLightIcon;
  final List<Widget> actions;
  const AppBarWidget({
    super.key,
    required this.title,
    this.titleAlign = TextAlign.center,
    this.onPressMoreLeadingIcon,
    this.showDownloadIndicator = ShowDownloadProgress.never,
    this.showNightLightIcon = false,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading:
          onPressMoreLeadingIcon != null
              ? IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'المزيد',
                onPressed: onPressMoreLeadingIcon,
              )
              : null,
      title: Text(
        title,
        textAlign: titleAlign,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        if (showDownloadIndicator != ShowDownloadProgress.never)
          DownloadProgressIndicator(),
        if (showNightLightIcon)
          IconButton(
            icon: const Icon(Icons.nightlight),
            onPressed: () {
              util.toggleThemeMode();
            },
            tooltip: 'الإعدادات',
          ),
        ...actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
