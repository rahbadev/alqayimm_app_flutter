import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:background_downloader/background_downloader.dart';

/// معلومات مهمة التنزيل
class DownloadTaskInfo {
  final String taskId;
  final BaseContentModel item;
  final Task task;
  final TaskStatus status;
  final double progress;
  final DateTime startTime;
  final double? networkSpeed;
  final Duration? timeRemaining;

  const DownloadTaskInfo({
    required this.taskId,
    required this.item,
    required this.task,
    required this.status,
    required this.progress,
    required this.startTime,
    this.networkSpeed,
    this.timeRemaining,
  });

  DownloadTaskInfo copyWith({
    String? taskId,
    BaseContentModel? item,
    Task? task,
    TaskStatus? status,
    double? progress,
    DateTime? startTime,
    double? networkSpeed,
    Duration? timeRemaining,
  }) {
    return DownloadTaskInfo(
      taskId: taskId ?? this.taskId,
      item: item ?? this.item,
      task: task ?? this.task,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      startTime: startTime ?? this.startTime,
      networkSpeed: networkSpeed ?? this.networkSpeed,
      timeRemaining: timeRemaining ?? this.timeRemaining,
    );
  }

  Duration get elapsed => DateTime.now().difference(startTime);

  String get progressPercentage => '${(progress * 100).toStringAsFixed(1)}%';

  String get networkSpeedFormatted {
    if (networkSpeed == null) return '--';
    if (networkSpeed! < 1024) return '${networkSpeed!.toStringAsFixed(1)} B/s';
    if (networkSpeed! < 1024 * 1024) {
      return '${(networkSpeed! / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(networkSpeed! / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  String get timeRemainingFormatted {
    if (timeRemaining == null) return '--';
    final minutes = timeRemaining!.inMinutes;
    final seconds = timeRemaining!.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
