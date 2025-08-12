import 'package:alqayimm_app_flutter/downloader/download_provider.dart';
import 'package:alqayimm_app_flutter/downloader/download_task_model.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:background_downloader/background_downloader.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التنزيلات'), centerTitle: true),
      body: Consumer<DownloadProvider>(
        builder: (context, downloadProvider, child) {
          logger.d(
            'all downloads ${downloadProvider.notCompletedDownloads.length}',
          );
          final downloads =
              downloadProvider.notCompletedDownloads.values.toList();

          if (downloads.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد تنزيلات',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final download = downloads[index];
              return _DownloadItem(
                downloadModel: download,
                downloadProvider: downloadProvider,
              );
            },
          );
        },
      ),
    );
  }
}

class _DownloadItem extends StatelessWidget {
  final DownloadTaskModel downloadModel;
  final DownloadProvider downloadProvider;

  const _DownloadItem({
    required this.downloadModel,
    required this.downloadProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان الملف
            Text(
              downloadModel.itemName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // تفاصيل التنزيل
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التقدم: ${downloadModel.progressPercentage}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (downloadModel.networkSpeedFormatted.isNotEmpty)
                        Text(
                          'السرعة: ${downloadModel.networkSpeedFormatted}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      if (downloadModel.timeRemainingFormatted.isNotEmpty)
                        Text(
                          'الوقت المتبقي: ${downloadModel.timeRemainingFormatted}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusIcon(),
              ],
            ),
            const SizedBox(height: 8),

            // شريط التقدم
            LinearProgressIndicator(
              value: downloadModel.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
            const SizedBox(height: 8),

            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (downloadModel.taskStatusUpdate.status) {
      case TaskStatus.running:
        icon = Icons.download;
        color = Colors.blue;
        break;
      case TaskStatus.paused:
        icon = Icons.pause;
        color = Colors.orange;
        break;
      case TaskStatus.complete:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case TaskStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      default:
        icon = Icons.hourglass_empty;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 24);
  }

  Color _getProgressColor() {
    switch (downloadModel.taskStatusUpdate.status) {
      case TaskStatus.running:
        return Colors.blue;
      case TaskStatus.paused:
        return Colors.orange;
      case TaskStatus.complete:
        return Colors.green;
      case TaskStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    switch (downloadModel.taskStatusUpdate.status) {
      case TaskStatus.running:
        buttons.add(
          TextButton.icon(
            onPressed: () => downloadProvider.pauseDownload(downloadModel),
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('إيقاف'),
          ),
        );
        break;
      case TaskStatus.paused:
        buttons.add(
          TextButton.icon(
            onPressed: () => downloadProvider.resumeDownload(downloadModel),
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('استئناف'),
          ),
        );
        break;
      //todo fix remvoeDownload
      case TaskStatus.complete:
        buttons.add(
          TextButton.icon(
            onPressed: null,
            // () => downloadProvider.removeDownload(downloadModel),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('حذف'),
          ),
        );
        break;
      default:
        break;
    }

    buttons.add(
      TextButton.icon(
        onPressed: null,
        // () => downloadProvider.removeDownload(downloadModel),
        icon: const Icon(Icons.close, size: 16),
        label: const Text('إلغاء'),
        style: TextButton.styleFrom(foregroundColor: Colors.red),
      ),
    );

    return buttons;
  }
}
