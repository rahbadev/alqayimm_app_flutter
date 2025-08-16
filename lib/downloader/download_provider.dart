import 'dart:async';
import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/downloader/download_task_model.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/downloader/download_manager.dart';
import 'package:alqayimm_app_flutter/utils/file_utils.dart';
import 'package:alqayimm_app_flutter/utils/network_utils.dart';
import 'package:alqayimm_app_flutter/utils/preferences_utils.dart';
import 'package:alqayimm_app_flutter/widgets/toasts.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

/// Provider لإدارة حالة التنزيلات
class DownloadProvider extends ChangeNotifier {
  final DownloadManager _downloadManager = DownloadManager.instance;

  // State variables
  bool _isInitialized = false;

  // Subscriptions
  StreamSubscription<List<DownloadTaskModel>>? _downloadUpdatesSubscription;

  // ===== Getters (كلها تعتمد على DownloadManager فقط) =====
  Map<String, DownloadTaskModel> get allDownloadsMap =>
      _downloadManager.allDownloadsMap;

  List<DownloadTaskModel> get allDownloadsList =>
      _downloadManager.allDownloadsList;

  bool get hasActiveDownloads => runningDownloads.isNotEmpty;

  bool get isInitialized => _isInitialized;

  int get totalDownloads => allDownloadsList.length;

  Map<String, DownloadTaskModel> get pausedDownloads {
    return Map.fromEntries(
      allDownloadsMap.values
          .where(
            (download) => download.taskStatusUpdate.status == TaskStatus.paused,
          )
          .map((download) => MapEntry(download.taskId, download)),
    );
  }

  Map<String, DownloadTaskModel> get runningDownloads {
    return Map.fromEntries(
      allDownloadsMap.values
          .where(
            (download) =>
                download.taskStatus.isNotFinalState &&
                download.taskStatus != TaskStatus.paused,
          )
          .map((download) => MapEntry(download.taskId, download)),
    );
  }

  double runningDownloadsProgress() {
    final totalProgress = runningDownloads.values.fold<double>(
      0.0,
      (sum, download) => sum + (download.progress),
    );
    return totalProgress / runningDownloads.length;
  }

  Map<String, DownloadTaskModel> get notCompletedDownloads {
    return Map.fromEntries(
      allDownloadsMap.values
          .where((download) => download.taskStatus.isNotFinalState)
          .map((download) => MapEntry(download.taskId, download)),
    );
  }

  int get runningDownloadsCount => runningDownloads.length;

  // ===== Initialization =====
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // تهيئة DownloadManager
      await _downloadManager.initialize();

      await setGlobalRequireWiFi(PreferencesUtils.requireWiFi);

      // الاشتراك في التحديثات (تبسيط: فقط notifyListeners)
      _downloadUpdatesSubscription = _downloadManager.downloadUpdates.listen(
        (_) => notifyListeners(),
      );

      _isInitialized = true;
      notifyListeners();

      logger.i('DownloadProvider initialized successfully');
    } catch (e) {
      logger.e('Error initializing DownloadProvider: $e');
      rethrow;
    }
  }

  // ===== Core Methods (كلها تعتمد على DownloadManager) =====

  DownloadStatus getDownloadStatus(BaseContentModel item) {
    final downloadInfo = _downloadManager.getItemTaskInfo(item);
    return downloadInfo?.downloadStatus ?? DownloadStatus.none;
  }

  /// الحصول على معلومات التنزيل لعنصر معين
  DownloadTaskModel? getDownloadInfo(BaseContentModel item) =>
      _downloadManager.getItemTaskInfo(item);

  /// بدء تنزيل عنصر
  Future<bool> startDownload(
    BaseContentModel item, {
    bool forceDownload = false,
  }) async {
    try {
      // التأكد من التهيئة
      if (!_isInitialized) {
        await initialize();
      }

      // التعامل مع حالة التنزيل القسري
      // إذا كان forceDownload صحيحًا، نقوم بإزالة التنزيل الحالي
      if (forceDownload) {
        logger.d('Force download for item: ${item.id}');
        await removeDownload(item);
      }
      // إذا لم يكن forceDownload صحيحًا
      // نقوم بالتحقق مما إذا كان الملف موجودًا بالفعل
      // وإذا كان التنزيل في حالة مكتملة
      // نعود مباشرة بدون بدء التنزيل مرة أخرى
      else {
        final fileExists = await FileUtils.isItemFileExists(item);
        final taskInfo = getDownloadInfo(item);
        final taskStatus = taskInfo?.taskStatusUpdate.status;
        logger.d(
          'File exists: $fileExists, Task status: $taskStatus for item: ${item.id}',
        );

        if (fileExists && taskStatus == TaskStatus.complete) {
          logger.d('File already exists and is complete for item: ${item.id}');
          return true;
        }
      }

      // ignore: use_build_context_synchronously
      final canProceed = await _canDownloadProceed(item);
      logger.d('Can proceed with download: $canProceed');
      if (!canProceed) return false;

      // إذا كان التنزيل في حالة إيقاف مؤقت، نقوم باستئنافه
      final taskInfo = getDownloadInfo(item);
      if (taskInfo != null &&
          taskInfo.taskStatusUpdate.status == TaskStatus.paused) {
        final result = await resumeDownload(taskInfo);
        if (result) {
          logger.d('Resumed download for item: ${item.id}');
          return true;
        }
        logger.e('Failed to resume download for item: ${item.id}');
        await removeDownload(item);
      }

      // إذا لم يكن في حالة إيقاف مؤقت، نقوم ببدء التنزيل
      return await _downloadManager.startDownload(item: item);
    } catch (e) {
      AppToasts.showError(title: 'خطأ في بدء التنزيل', description: '$e');
      logger.e('Error starting download: $e');
      return false;
    }
  }

  Future<bool> _canDownloadProceed(BaseContentModel item) async {
    // التحقق من نوع الاتصال
    final canProceed = await _checkConnectionAndWarn();

    return canProceed;
  }

  /// التحقق من نوع الاتصال قبل بدء التنزيل
  Future<bool> _checkConnectionAndWarn() async {
    final isWifiOnly = PreferencesUtils.requireWiFi;
    final connectionResult = await NetworkUtils.checkConnectionType(
      isWifiOnly: isWifiOnly,
    );

    if (!connectionResult.canProceed) {
      AppToasts.showError(
        description: connectionResult.message ?? 'لا يوجد اتصال بالإنترنت',
      );
      return false;
    }

    return true;
  }

  /// تغيير متطلب الواي فاي لجميع التنزيلات
  Future<void> setGlobalRequireWiFi(
    bool requireWiFi, {
    bool rescheduleRunningTasks = true,
  }) async {
    PreferencesUtils.setRequireWiFi(requireWiFi);
    _downloadManager.setGlobalRequireWiFi(
      requireWiFi,
      rescheduleRunningTasks: rescheduleRunningTasks,
    );
  }

  /// استئناف تنزيل
  Future<bool> resumeDownload(DownloadTaskModel task) =>
      _downloadManager.resumeDownload(task);

  /// إيقاف تنزيل مؤقتاً
  Future<bool> pauseDownload(DownloadTaskModel task) async =>
      _downloadManager.pauseDownload(task);

  /// إلغاء تنزيل
  Future<bool> removeDownload(
    BaseContentModel item, {
    bool removeFile = true,
    bool trueIfNotExists = true,
  }) async {
    final task = _downloadManager.getItemTaskInfo(item);
    if (task != null) {
      _downloadManager.removeDownload(task);
    }
    if (!removeFile) {
      return true;
    }
    return FileUtils.deleteItemFile(item, trueIfNotExists: true);
  }

  @override
  void dispose() {
    _downloadUpdatesSubscription?.cancel();
    super.dispose();
  }
}
