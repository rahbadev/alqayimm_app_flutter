import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:background_downloader/background_downloader.dart';

/// معلومات مهمة التنزيل
class DownloadTaskModel {
  final int itemId;
  final ItemType itemType;
  TaskStatusUpdate taskStatusUpdate;
  TaskProgressUpdate taskProgressUpdate;

  DownloadTaskModel({
    required this.itemId,
    required this.itemType,
    required this.taskStatusUpdate,
    required this.taskProgressUpdate,
  });

  DownloadTaskModel copyWith({
    TaskStatusUpdate? taskStatusUpdate,
    TaskProgressUpdate? taskProgressUpdate,
  }) {
    return DownloadTaskModel(
      itemId: itemId,
      itemType: itemType,
      taskStatusUpdate: taskStatusUpdate ?? this.taskStatusUpdate,
      taskProgressUpdate: taskProgressUpdate ?? this.taskProgressUpdate,
    );
  }

  Task get task => taskStatusUpdate.task;

  String get taskId => task.taskId;

  TaskStatus get taskStatus => taskStatusUpdate.status;

  String get progressPercentage =>
      '${(taskProgressUpdate.progress * 100).toStringAsFixed(1)}%';

  double get progress => taskProgressUpdate.progress;

  String get networkSpeedFormatted => taskProgressUpdate.networkSpeedAsString;

  String get timeRemainingFormatted => taskProgressUpdate.timeRemainingAsString;

  String get itemName => task.displayName;

  DownloadStatus get downloadStatus {
    switch (taskStatus) {
      case TaskStatus.running:
      case TaskStatus.enqueued:
      case TaskStatus.waitingToRetry:
        return DownloadStatus.progress;
      case TaskStatus.complete:
        return DownloadStatus.downloaded;
      default:
        return DownloadStatus.none;
    }
  }
}
