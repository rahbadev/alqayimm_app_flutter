import 'dart:async';
import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/downloader/download_task_info.dart';
import 'package:alqayimm_app_flutter/downloader/download_task_update.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/utils/file_utils.dart';
import 'package:alqayimm_app_flutter/utils/network_utils.dart';
import 'package:background_downloader/background_downloader.dart';

/// مدير التنزيلات الرئيسي
class DownloadManager {
  static DownloadManager? _instance;
  static DownloadManager get instance => _instance ??= DownloadManager._();

  DownloadManager._();

  /// Stream للاستماع إلى تحديثات التنزيل
  final StreamController<DownloadTaskUpdate> _downloadUpdatesController =
      StreamController<DownloadTaskUpdate>.broadcast();

  /// Stream للاستماع إلى التنزيلات النشطة
  final StreamController<List<DownloadTaskInfo>> _activeDownloadsController =
      StreamController<List<DownloadTaskInfo>>.broadcast();

  /// قائمة التنزيلات النشطة (بـ taskId)
  final Map<String, DownloadTaskInfo> _allDownloads = {};

  /// خريطة للبحث السريع بـ item.id
  final Map<String, DownloadTaskInfo> _downloadsMap = {};

  bool _isInitialized = false;

  /// تهيئة مدير التنزيلات
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // تهيئة FileDownloader
      await FileDownloader().trackTasks();

      // تسجيل callbacks للتحديثات
      FileDownloader().registerCallbacks(
        taskStatusCallback: _onTaskStatusUpdate,
        taskProgressCallback: _onTaskProgressUpdate,
      );

      // استرداد التنزيلات المتوقفة
      await _resumeFromBackground();

      _isInitialized = true;
      logger.i('DownloadManager initialized successfully');
    } catch (e) {
      logger.e('Error initializing DownloadManager: $e');
      rethrow;
    }
  }

  /// Stream التحديثات
  Stream<DownloadTaskUpdate> get downloadUpdates =>
      _downloadUpdatesController.stream;

  /// Stream التنزيلات النشطة
  Stream<List<DownloadTaskInfo>> get activeDownloads =>
      _activeDownloadsController.stream;

  /// بدء تنزيل عنصر
  Future<DownloadResult> startDownload({
    required BaseContentModel item,
    bool forceDownload = false,
  }) async {
    logger.d(
      'Starting download for item: ${item.id}'
      ' (${item.runtimeType}) with forceDownload: $forceDownload',
    );
    try {
      // التحقق من التهيئة
      if (!_isInitialized) {
        await initialize();
      }

      final fileExists = await FileUtils.isItemFileExists(item);
      final itemTaskInfo = await getItemTaskInfo(item);
      final itemTaskStatus = itemTaskInfo?.status;

      logger.d('File exists: $fileExists');
      // الحالة 1: إذا كان forceDownload
      if (forceDownload) {
        if (itemTaskInfo != null) {
          await cancelDownload(itemTaskInfo.taskId, deleteFile: fileExists);
        } else {
          if (fileExists) {
            await deleteDownloadedFile(item);
          }
        }
      } else {
        if (fileExists) {
          if (itemTaskInfo != null) {
            if (itemTaskStatus == TaskStatus.complete) {
              logger.d('File already exists and is complete');
              return DownloadResult.alreadyExists();
            } else if (itemTaskStatus!.isNotFinalState &&
                itemTaskStatus != TaskStatus.paused) {
              return DownloadResult.started(itemTaskInfo.taskId);
            }
          }
        }
      }

      // التحقق من نوع الاتصال
      final connectionResult = await NetworkUtils.checkConnectionType();
      if (!connectionResult.canProceed) {
        return DownloadResult.error(connectionResult.message!);
      }

      // التحقق من المساحة
      final spaceResult = await FileUtils.checkAvailableSpace(item);
      if (!spaceResult.hasEnoughSpace) {
        return DownloadResult.error('مساحة تخزين غير كافية');
      }

      if (fileExists &&
          itemTaskStatus != null &&
          itemTaskStatus == TaskStatus.paused) {
        resumeDownload(itemTaskInfo!.taskId);
        logger.d('Resuming download for item: ${item.id}');
        return DownloadResult.started(itemTaskInfo.taskId);
      }

      // إنشاء DownloadTask
      final task = await _createDownloadTask(item);
      if (task == null) {
        return DownloadResult.error(
          'لا يمكن إنشاء مهمة التنزيل - رابط غير صالح',
        );
      }

      // بدء التنزيل
      final success = await FileDownloader().enqueue(task);
      if (!success) {
        return DownloadResult.error('فشل في بدء التنزيل');
      }

      // إضافة إلى قائمة التنزيلات النشطة
      final downloadInfo = DownloadTaskInfo(
        taskId: task.taskId,
        item: item,
        task: task,
        status: TaskStatus.enqueued,
        progress: 0.0,
        startTime: DateTime.now(),
      );

      _registerDownload(downloadInfo);

      logger.i('Started download for ${item.runtimeType} with ID: ${item.id}');
      return DownloadResult.started(task.taskId);
    } catch (e) {
      logger.e('Error starting download: $e');
      return DownloadResult.error('خطأ في بدء التنزيل: $e');
    }
  }

  // الغاء تنزيل الملف مع خيار مسح الملف في حال كان موجوداً
  Future<bool> cancelDownload(
    String taskId, {
    bool removeFromDb = true,
    bool deleteFile = false,
  }) async {
    try {
      final success = await FileDownloader().cancelTaskWithId(taskId);
      if (success) {
        final downloadInfo = _allDownloads[taskId];

        if (deleteFile && downloadInfo != null) {
          await deleteDownloadedFile(downloadInfo.item);
        }

        if (removeFromDb) {
          _unregisterDownload(taskId);
        } else {
          _notifyActiveDownloadsChanged();
        }

        // إرسال تحديث الحالة
        if (downloadInfo != null) {
          _downloadUpdatesController.add(
            DownloadTaskUpdate(
              taskId: taskId,
              item: downloadInfo.item,
              status: TaskStatus.canceled,
              progress: downloadInfo.progress,
            ),
          );
        }

        return true;
      } else {
        throw Exception('Failed to cancel download');
      }
    } catch (e) {
      logger.e('Error canceling download: $e');
      return false;
    }
  }

  /// إيقاف تنزيل مؤقت إذا كان taskId null فيعني إيقاف الجميع عبر FileDownloader().pauseAll();
  Future<bool> pauseDownload(String taskId) async {
    try {
      final downloadInfo = _allDownloads[taskId];
      if (downloadInfo == null) return false;

      final success = await FileDownloader().pause(
        downloadInfo.task as DownloadTask,
      );
      if (success) {
        final updatedInfo = downloadInfo.copyWith(status: TaskStatus.paused);
        _updateDownload(taskId, updatedInfo);

        // إرسال تحديث الحالة
        _downloadUpdatesController.add(
          DownloadTaskUpdate(
            taskId: taskId,
            item: downloadInfo.item,
            status: TaskStatus.paused,
            progress: downloadInfo.progress,
          ),
        );
      }
      return success;
    } catch (e) {
      logger.e('Error pausing download: $e');
      return false;
    }
  }

  /// استئناف تنزيل
  Future<bool> resumeDownload(String taskId) async {
    try {
      final downloadInfo = _allDownloads[taskId];
      if (downloadInfo == null) return false;

      final success = await FileDownloader().resume(
        downloadInfo.task as DownloadTask,
      );
      if (success) {
        final updatedInfo = downloadInfo.copyWith(status: TaskStatus.running);
        _updateDownload(taskId, updatedInfo);

        // إرسال تحديث الحالة
        _downloadUpdatesController.add(
          DownloadTaskUpdate(
            taskId: taskId,
            item: downloadInfo.item,
            status: TaskStatus.running,
            progress: downloadInfo.progress,
          ),
        );
      }
      return success;
    } catch (e) {
      logger.e('Error resuming download: $e');
      return false;
    }
  }

  /// التحقق من حالة التنزيل لعنصر معين
  // يتم إرجاع حالة التنزيل للعنصر بغض النظر عن وجود العنصر في التخزين
  DownloadStatus getDownloadStatus(BaseContentModel item) {
    final downloadInfo = _downloadsMap[_getItemKey(item)];
    if (downloadInfo != null) {
      return _mapTaskStatusToDownloadStatus(downloadInfo.status);
    }
    return DownloadStatus.none;
  }

  DownloadTaskInfo? getItemTaskInfo(BaseContentModel item) {
    return _downloadsMap[_getItemKey(item)];
  }

  List<DownloadTaskInfo> getActiveDownloads() {
    return _allDownloads.values
        .where(
          (download) =>
              download.status.isNotFinalState &&
              download.status != TaskStatus.paused,
        )
        .toList();
  }

  /// الحصول على جميع التنزيلات (للعرض في UI)
  List<DownloadTaskInfo> getAllDownloads() {
    return _allDownloads.values.toList();
  }

  /// إضافة تنزيل جديد للخرائط
  void _registerDownload(DownloadTaskInfo info) {
    _allDownloads[info.taskId] = info;
    _downloadsMap[_getItemKey(info.item)] = info;
    _notifyActiveDownloadsChanged();
  }

  /// إزالة تنزيل من الخرائط
  void _unregisterDownload(String taskId) {
    final downloadInfo = _allDownloads[taskId];
    if (downloadInfo != null) {
      _allDownloads.remove(taskId);
      _downloadsMap.remove(_getItemKey(downloadInfo.item));
      _notifyActiveDownloadsChanged();
    }
  }

  /// تحديث تنزيل في الخرائط
  void _updateDownload(String taskId, DownloadTaskInfo updatedInfo) {
    _allDownloads[taskId] = updatedInfo;
    _downloadsMap[_getItemKey(updatedInfo.item)] = updatedInfo;
    _notifyActiveDownloadsChanged();
  }

  /// الحصول على مفتاح العنصر للبحث السريع
  String _getItemKey(BaseContentModel item) {
    return '${item.runtimeType}_${item.id}';
  }

  // ==================== Private Methods ====================

  Future<void> _resumeFromBackground() async {
    try {
      await FileDownloader().resumeFromBackground();

      final records = await FileDownloader().database.allRecords();

      for (final record in records) {
        final status = record.status;
        if (status.isFinalState && status != TaskStatus.complete) {
          continue;
        }
        // محاولة استرداد معلومات العنصر من metadata
        final item = _parseItemFromMetadata(record.task.metaData);
        if (item != null) {
          final downloadInfo = DownloadTaskInfo(
            taskId: record.taskId,
            item: item,
            task: record.task,
            status: record.status,
            progress: record.progress,
            startTime: DateTime.now(),
          );

          _registerDownload(downloadInfo);
        }
      }

      // لا نحتاج _notifyActiveDownloadsChanged هنا لأن _registerDownload تتولى ذلك
    } catch (e) {
      logger.e('Error resuming from background: $e');
    }
  }

  void _onTaskStatusUpdate(TaskStatusUpdate update) {
    logger.d(
      'Task status update: ${update.task.taskId}, status: ${update.status}',
    );
    final taskId = update.task.taskId;

    if (_allDownloads.containsKey(taskId)) {
      final updatedInfo = _allDownloads[taskId]!.copyWith(
        status: update.status,
      );
      _updateDownload(taskId, updatedInfo);
    }

    // إرسال التحديث
    _downloadUpdatesController.add(
      DownloadTaskUpdate(
        taskId: taskId,
        item: _allDownloads[taskId]?.item,
        status: update.status,
        progress: _allDownloads[taskId]?.progress ?? 0.0,
      ),
    );
  }

  void _onTaskProgressUpdate(TaskProgressUpdate update) {
    logger.d(
      'Task progress update: ${update.task.taskId}, progress: ${update.progress}',
    );
    final taskId = update.task.taskId;

    if (_allDownloads.containsKey(taskId)) {
      final updatedInfo = _allDownloads[taskId]!.copyWith(
        progress: update.progress,
        networkSpeed: update.networkSpeed,
        timeRemaining: update.timeRemaining,
      );
      _updateDownload(taskId, updatedInfo);
    }

    // إرسال التحديث
    _downloadUpdatesController.add(
      DownloadTaskUpdate(
        taskId: taskId,
        item: _allDownloads[taskId]?.item,
        status: _allDownloads[taskId]?.status ?? TaskStatus.enqueued,
        progress: update.progress,
        networkSpeed: update.networkSpeed,
        timeRemaining: update.timeRemaining,
      ),
    );
  }

  void _notifyActiveDownloadsChanged() {
    _activeDownloadsController.add(_allDownloads.values.toList());
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
      final directory = await FileUtils.getItemFileDir(item);
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
        taskId:
            'download_${item.runtimeType}_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
        url: url,
        filename: fileName,
        directory: directory,
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
        allowPause: true,
        metaData: metadata,
        displayName: fileName,
        requiresWiFi: requiresWiFi,
      );
    } catch (e) {
      logger.e('Error creating download task: $e');
      return null;
    }
  }

  String _createItemMetadata(BaseContentModel item) {
    if (item is LessonModel) {
      return 'lesson:${item.id}:${item.lessonName}:${item.materialId}:${item.lessonNumber ?? 0}:${item.materialName ?? ""}';
    } else if (item is BookModel) {
      return 'book:${item.id}:${item.name}';
    }
    return 'unknown:${item.id}';
  }

  BaseContentModel? _parseItemFromMetadata(String? metadata) {
    if (metadata == null || metadata.isEmpty) return null;

    final parts = metadata.split(':');
    if (parts.length < 3) return null;

    try {
      final type = parts[0];
      final id = int.parse(parts[1]);
      final name = parts[2];

      if (type == 'lesson' && parts.length >= 6) {
        final materialId = int.parse(parts[3]);
        final lessonNumber = int.parse(parts[4]);
        final materialName = parts[5];

        return LessonModel(
          id: id,
          lessonName: name,
          materialId: materialId,
          lessonNumber: lessonNumber,
          materialName: materialName,
        );
      } else if (type == 'book') {
        return BookModel(id: id, name: name);
      }
    } catch (e) {
      logger.w('Error parsing metadata: $metadata, error: $e');
    }

    return null;
  }

  Future<bool> deleteDownloadedFile(BaseContentModel item) async {
    final filePath = await FileUtils.getItemFileFullPath(item);
    logger.d('Deleting file at path: $filePath');
    if (filePath == null) return false;

    final success = await FileUtils.deleteFileSafely(filePath);

    if (success) {
      // البحث عن المهمة المرتبطة بالعنصر وإرسال تحديث
      final taskInfo = _downloadsMap[_getItemKey(item)];

      if (taskInfo != null) {
        _downloadUpdatesController.add(
          DownloadTaskUpdate(
            taskId: taskInfo.taskId,
            item: item,
            status: TaskStatus.canceled, // أو حالة أخرى مناسبة
            progress: 0.0,
          ),
        );
      }
    }

    return success;
  }

  DownloadStatus _mapTaskStatusToDownloadStatus(TaskStatus taskStatus) {
    switch (taskStatus) {
      case TaskStatus.running:
      case TaskStatus.enqueued:
      case TaskStatus.waitingToRetry:
        return DownloadStatus.progress;
      case TaskStatus.complete:
        return DownloadStatus.downloaded;
      case TaskStatus.paused:
        return DownloadStatus
            .none; // أو أضف DownloadStatus.paused إذا كنت تريد حالة منفصلة
      default:
        return DownloadStatus.none;
    }
  }

  /// تنظيف الموارد
  void dispose() {
    _downloadUpdatesController.close();
    _activeDownloadsController.close();
    FileDownloader().unregisterCallbacks();
  }
}

// ==================== Models ====================

/// نتيجة عملية التنزيل
class DownloadResult {
  final bool success;
  final String? message;
  final String? taskId;
  final String? filePath;

  const DownloadResult({
    required this.success,
    this.message,
    this.taskId,
    this.filePath,
  });

  factory DownloadResult.started(String taskId) =>
      DownloadResult(success: true, taskId: taskId);

  factory DownloadResult.alreadyExists() =>
      DownloadResult(success: true, message: 'الملف موجود بالفعل');

  factory DownloadResult.error(String message) =>
      DownloadResult(success: false, message: message);
}
