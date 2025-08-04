import 'dart:async';
import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/downloader/download_task_model.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/utils/file_utils.dart';
import 'package:background_downloader/background_downloader.dart';

/// مدير التنزيلات الرئيسي
class DownloadManager {
  static DownloadManager? _instance;
  static DownloadManager get instance => _instance ??= DownloadManager._();

  DownloadManager._();

  /// Stream للاستماع إلى التنزيلات النشطة
  final StreamController<List<DownloadTaskModel>> _downloadUpdatesController =
      StreamController<List<DownloadTaskModel>>.broadcast();

  /// قائمة التنزيلات النشطة
  final Map<String, DownloadTaskModel> _allDownloadsMap = {};

  bool _isInitialized = false;

  /// تهيئة مدير التنزيلات
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // تهيئة FileDownloader
      await FileDownloader().trackTasks();
      await _resumeFromBackground();
      // تسجيل callbacks للتحديثات
      FileDownloader().registerCallbacks(
        taskStatusCallback: (TaskStatusUpdate taskStatusUpdate) {
          _onDownloadTaskUpdate(taskStatusUpdate, null);
        },
        taskProgressCallback: (TaskProgressUpdate taskProgressUpdate) {
          _onDownloadTaskUpdate(null, taskProgressUpdate);
        },
      );

      // استرداد التنزيلات المتوقفة
      await FileDownloader().resumeFromBackground();

      _isInitialized = true;
      logger.i('DownloadManager initialized successfully');
    } catch (e) {
      logger.e('Error initializing DownloadManager: $e');
      rethrow;
    }
  }

  /// الحصول على جميع التنزيلات (للعرض في UI)
  List<DownloadTaskModel> get allDownloadsList =>
      _allDownloadsMap.values.toList();

  Map<String, DownloadTaskModel> get allDownloadsMap =>
      Map.unmodifiable(_allDownloadsMap);

  /// Stream التحديثات
  Stream<List<DownloadTaskModel>> get downloadUpdates =>
      _downloadUpdatesController.stream;

  void _onDownloadTaskUpdate(
    TaskStatusUpdate? taskStatusUpdate,
    TaskProgressUpdate? taskProgressUpdate,
  ) {
    final taskId =
        taskStatusUpdate?.task.taskId ?? taskProgressUpdate?.task.taskId;
    logger.d(
      'Download task update received for taskId: $taskId, status: ${taskStatusUpdate?.status}, progress: ${taskProgressUpdate?.progress}',
    );
    if (taskId == null) return;

    // إذا كان taskId غير موجود في الخرائط، لا نقوم بأي شيء
    // هذا يمنع التحديثات على المهام التي لم يتم إنشاؤها بعد
    final taskInfo = getTaskInfo(taskId);
    if (taskInfo == null) return;

    final taskStatus = taskStatusUpdate?.status;

    if (taskStatus != null &&
        taskStatus.isFinalState &&
        taskStatus != TaskStatus.complete) {
      // إذا كانت الحالة النهائية، نقوم بحذف السجل من قاعدة البيانات
      FileDownloader().database.deleteRecordWithId(taskId);
      _unregisterDownload(taskInfo);
      return;
    }

    final updatedInfo = taskInfo.copyWith(
      taskStatusUpdate: taskStatusUpdate,
      taskProgressUpdate: taskProgressUpdate,
    );
    _upsertDownload(updatedInfo);
  }

  void _notifyActiveDownloadsChanged() {
    _downloadUpdatesController.add(_allDownloadsMap.values.toList());
  }

  Future<void> _resumeFromBackground() async {
    try {
      logger.i('Resuming downloads from background...');

      await FileDownloader().resumeFromBackground();

      final records = await FileDownloader().database.allRecords();

      for (final record in records) {
        // محاولة استرداد معلومات العنصر من metadata
        var metaData = _parseItemMetadata(record.task.metaData);
        if (metaData == null ||
            (record.status.isFinalState &&
                record.status != TaskStatus.complete)) {
          await FileDownloader().database.deleteRecordWithId(
            record.task.taskId,
          );
          continue;
        }

        final downloadInfo = DownloadTaskModel(
          itemId: metaData.itemId,
          itemType: metaData.itemType,
          taskStatusUpdate: TaskStatusUpdate(record.task, record.status),
          taskProgressUpdate: TaskProgressUpdate(record.task, record.progress),
        );

        _upsertDownload(downloadInfo);
      }
    } catch (e) {
      logger.e('Error resuming from background: $e');
    }
  }

  /// بدء تنزيل عنصر
  Future<bool> startDownload({required BaseContentModel item}) async {
    logger.d(
      'Starting download for item: ${item.id}'
      ' (${item.runtimeType})',
    );
    try {
      // التحقق من التهيئة
      if (!_isInitialized) {
        await initialize();
      }

      // إنشاء DownloadTask
      final task = await _createDownloadTask(item);
      if (task == null) {
        logger.w('Failed to create download task for item: ${item.id}');
        return false;
      }

      // بدء التنزيل
      final success = await FileDownloader().enqueue(task);
      if (!success) {
        logger.w('Failed to enqueue download task for item: ${item.id}');
        return false;
      }

      // إضافة إلى قائمة التنزيلات النشطة
      final downloadInfo = DownloadTaskModel(
        itemId: item.id,
        itemType: item.itemType,
        taskStatusUpdate: TaskStatusUpdate(task, TaskStatus.enqueued),
        taskProgressUpdate: TaskProgressUpdate(task, 0.0),
      );

      _upsertDownload(downloadInfo);

      logger.i('Started download for ${item.runtimeType} with ID: ${item.id}');
      return true;
    } catch (e) {
      logger.e('Error starting download: $e');
      return false;
    }
  }

  /// تغيير متطلب الواي فاي لجميع التنزيلات
  Future<void> setGlobalRequireWiFi(
    bool requireWiFi, {
    bool rescheduleRunningTasks = true,
  }) async {
    await FileDownloader().requireWiFi(
      requireWiFi ? RequireWiFi.forAllTasks : RequireWiFi.forNoTasks,
      rescheduleRunningTasks: rescheduleRunningTasks,
    );
  }

  // الغاء تنزيل الملف مع خيار مسح الملف في حال كان موجوداً
  Future<bool> removeDownload(DownloadTaskModel downloadInfo) async {
    try {
      final taskId = downloadInfo.taskId;
      logger.d('Removing download for taskId: $taskId');
      // cancel file download => معالجة باقي الأمور تكون في _updateDownload
      await FileDownloader().cancelTaskWithId(taskId);

      // remove from database
      await FileDownloader().database.deleteRecordWithId(taskId);
      return true;
    } catch (e) {
      logger.e('Error canceling download: $e');
      return false;
    }
  }

  /// إيقاف تنزيل مؤقت إذا كان taskId null فيعني إيقاف الجميع عبر FileDownloader().pauseAll();
  Future<bool> pauseDownload(DownloadTaskModel downloadInfo) async {
    try {
      return await FileDownloader().pause(downloadInfo.task as DownloadTask);
    } catch (e) {
      logger.e('Error pausing download: $e');
      return false;
    }
  }

  /// استئناف تنزيل
  Future<bool> resumeDownload(DownloadTaskModel downloadInfo) async {
    try {
      return await FileDownloader().resume(downloadInfo.task as DownloadTask);
    } catch (e) {
      logger.e('Error resuming download: $e');
      return false;
    }
  }

  /// إضافة تنزيل جديد للخرائط
  void _upsertDownload(DownloadTaskModel info) {
    _allDownloadsMap[info.taskId] = info;
    _notifyActiveDownloadsChanged();
  }

  /// إزالة تنزيل من الخرائط
  void _unregisterDownload(DownloadTaskModel updatedInfo) {
    final taskId = updatedInfo.taskId;
    logger.d('Unregistering download for taskId: $taskId');
    final result = _allDownloadsMap.remove(taskId);
    if (result == null) {
      logger.w('No download found for taskId: $taskId');
      return;
    }
    _notifyActiveDownloadsChanged();
  }

  DownloadTaskModel? getTaskInfo(String taskId) {
    return _allDownloadsMap[taskId];
  }

  DownloadTaskModel? getItemTaskInfo(BaseContentModel item) {
    return getTaskInfo(_getItemTaskId(item));
  }

  Future<DownloadTask?> _createDownloadTask(
    BaseContentModel item, {
    bool requiresWiFi = true,
  }) async {
    try {
      final String? url =
          item is LessonModel
              ? item.url
              : (item is BookModel ? item.bookUrl : null);

      final fileName = FileUtils.getItemFileName(item);
      final displayName = FileUtils.getItemTitle(item);
      final directory = await FileUtils.getItemFileDir(item, false);
      logger.d(
        'Creating download task for ${item.runtimeType} with ID: ${item.id}, URL: $url, Directory: $directory, FileName: $fileName',
      );

      if (url == null || url.isEmpty) {
        logger.w('Invalid URL for item: ${item.id}');
        return null;
      }

      if (directory == null || directory.isEmpty) {
        logger.w('Invalid directory for item: ${item.id}');
        return null;
      }

      // إنشاء metadata للتعرف على العنصر لاحقاً
      final metadata = _createItemMetadata(item);

      return DownloadTask(
        taskId: _getItemTaskId(item),
        url: url,
        filename: fileName,
        directory: directory,
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
        allowPause: true,
        metaData: metadata,
        displayName: displayName,
        requiresWiFi: requiresWiFi,
      );
    } catch (e) {
      logger.e('Error creating download task: $e');
      return null;
    }
  }

  /// إنشاء taskId ثابت لكل عنصر (إصلاح المشكلة الأساسية)
  String _getItemTaskId(BaseContentModel item) {
    return 'download_${item.runtimeType}_${item.id}';
  }

  String _createItemMetadata(BaseContentModel item) {
    if (item is LessonModel) {
      return '${ItemType.lesson.value}:${item.id}';
    } else if (item is BookModel) {
      return '${ItemType.book.value}:${item.id}';
    }
    return 'unknown:${item.id}';
  }

  ({ItemType itemType, int itemId})? _parseItemMetadata(String metaData) {
    final parts = metaData.split(':');
    if (parts.length != 2) return null;
    final itemId = int.tryParse(parts[1]);
    if (itemId == null) return null;
    final itemType =
        parts[0] == ItemType.lesson.value
            ? ItemType.lesson
            : (parts[0] == ItemType.book.value ? ItemType.book : null);
    if (itemType == null) return null;

    return (itemType: itemType, itemId: itemId);
  }

  /// تنظيف الموارد
  void dispose() {
    _downloadUpdatesController.close();
    FileDownloader().unregisterCallbacks();
  }
}
