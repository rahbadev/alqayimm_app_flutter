import 'package:alqayimm_app_flutter/downloader/download_provider.dart';
import 'package:alqayimm_app_flutter/downloader/download_task_info.dart';
import 'package:alqayimm_app_flutter/screens/downloads/downloads_screen.dart';
import 'package:alqayimm_app_flutter/downloader/download_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Widget لعرض التنبيه الدائم للتنزيلات النشطة
/// يظهر فقط في الشاشات المحددة وعند وجود تنزيلات نشطة
class GlobalDownloadIndicator extends StatelessWidget {
  final Widget child;

  const GlobalDownloadIndicator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Consumer<DownloadProvider>(
            builder: (context, downloadProvider, child) {
              // إظهار المؤشر فقط إذا كان هناك تنزيلات نشطة
              if (!downloadProvider.hasActiveDownloads) {
                return const SizedBox.shrink();
              }

              return _ActiveDownloadsBanner(downloadProvider: downloadProvider);
            },
          ),
        ),
      ],
    );
  }
}

class _ActiveDownloadsBanner extends StatelessWidget {
  final DownloadProvider downloadProvider;

  const _ActiveDownloadsBanner({required this.downloadProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final runningDownloads = downloadProvider.runningDownloadsCount;
    final totalDownloads = downloadProvider.totalDownloads;

    if (totalDownloads == 0) return const SizedBox.shrink();

    return Material(
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withOpacity(0.8),
            ],
          ),
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // أيقونة ومؤشر التقدم
              SizedBox(
                width: 24,
                height: 24,
                child:
                    runningDownloads > 0
                        ? CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        )
                        : Icon(
                          Icons.download_done,
                          color: theme.colorScheme.primary,
                        ),
              ),

              const SizedBox(width: 12),

              // النص الرئيسي
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getMainText(runningDownloads, totalDownloads),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (runningDownloads > 0)
                      Text(
                        _getSubText(runningDownloads),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                      ),
                    // شريط التقدم للتنزيلات النشطة
                    if (runningDownloads > 0) ...[
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: _getOverallProgress(),
                        backgroundColor: theme.colorScheme.onPrimaryContainer
                            .withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // زر العرض بدون السهم
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DownloadsScreen()),
                  );
                },
                child: Text(
                  'عرض',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// حساب التقدم الإجمالي لجميع التنزيلات النشطة
  double _getOverallProgress() {
    final activeDownloads = downloadProvider.runningDownloads.values;

    if (activeDownloads.isEmpty) return 0.0;

    final totalProgress = activeDownloads
        .map((d) => d.progress)
        .reduce((a, b) => a + b);

    return totalProgress / activeDownloads.length;
  }

  String _getMainText(int runningDownloads, int totalDownloads) {
    if (runningDownloads > 0) {
      return runningDownloads == 1
          ? 'جاري تنزيل ملف واحد'
          : 'جاري تنزيل $runningDownloads ملفات';
    } else {
      return totalDownloads == 1
          ? 'تم إكمال تنزيل واحد'
          : 'تم إكمال $totalDownloads تنزيلات';
    }
  }

  String _getSubText(int runningDownloads) {
    final downloads = downloadProvider.runningDownloads.values.take(2);

    if (downloads.isEmpty) return '';

    final names =
        downloads.map((d) {
          if (d.item.runtimeType.toString() == 'LessonModel') {
            return (d.item as dynamic).lessonName ?? 'درس صوتي';
          } else {
            return (d.item as dynamic).name ?? 'كتاب';
          }
        }).toList();

    if (names.length == 1) {
      return names.first;
    } else if (names.length == 2) {
      return '${names[0]} و ${names[1]}';
    }

    return '';
  }
}

/// Widget مضغوط لعرض تقدم تنزيل واحد
class CompactDownloadProgress extends StatelessWidget {
  final DownloadTaskInfo downloadInfo;
  final VoidCallback? onTap;

  const CompactDownloadProgress({
    super.key,
    required this.downloadInfo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                value: downloadInfo.progress,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(downloadInfo.progress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget لعرض ملخص سريع للتنزيلات
class DownloadsSummaryCard extends StatelessWidget {
  final DownloadProvider downloadProvider;

  const DownloadsSummaryCard({super.key, required this.downloadProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final runningDownloads = downloadProvider.runningDownloads;
    final completedDownloads = downloadProvider.completedDownloads;
    final totalDownloads = downloadProvider.totalDownloads;

    if (totalDownloads == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.download_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'التنزيلات',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DownloadsScreen(),
                      ),
                    );
                  },
                  child: const Text('عرض الكل'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.play_circle_outline,
                    label: 'جارية',
                    value: runningDownloads.toString(),
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.check_circle_outline,
                    label: 'مكتملة',
                    value: completedDownloads.toString(),
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.download_outlined,
                    label: 'الإجمالي',
                    value: totalDownloads.toString(),
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
