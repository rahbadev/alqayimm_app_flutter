import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:background_downloader/background_downloader.dart';

/// تحديث مهمة التنزيل
class DownloadTaskUpdate {
  final String taskId;
  final BaseContentModel? item;
  final TaskStatus status;
  final double progress;
  final double? networkSpeed;
  final Duration? timeRemaining;

  const DownloadTaskUpdate({
    required this.taskId,
    this.item,
    required this.status,
    required this.progress,
    this.networkSpeed,
    this.timeRemaining,
  });
}
