import 'package:alqayimm_app_flutter/downloader/download_provider.dart';
import 'package:alqayimm_app_flutter/screens/downloads/downloads_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';

class DownloadProgressIndicator extends StatelessWidget {
  const DownloadProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(
      builder: (context, downloadProvider, child) {
        final activeDownloads = downloadProvider.runningDownloadsCount;
        if (activeDownloads == 0) return const SizedBox.shrink();

        final totalProgress = downloadProvider.runningDownloadsProgress();
        return Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: InkWell(
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DownloadsScreen()),
                ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Ionicons.arrow_down,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Theme.of(context).colorScheme.onSurface,
                      backgroundColor:
                          Theme.of(context).colorScheme.outlineVariant,
                      value: totalProgress > 0.01 ? totalProgress : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
