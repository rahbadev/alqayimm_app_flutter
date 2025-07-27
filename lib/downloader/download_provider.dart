import 'dart:async';
import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/downloader/download_task_info.dart';
import 'package:alqayimm_app_flutter/downloader/download_task_update.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/downloader/download_manager.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/wifi_warning_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/toasts.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

/// Provider لإدارة حالة التنزيلات
class DownloadProvider extends ChangeNotifier {
  final DownloadManager _downloadManager = DownloadManager.instance;

  // State variables
  final Map<String, DownloadStatus> _itemDownloadStatus = {};
  bool _isInitialized = false;

  // Subscriptions
  StreamSubscription<List<DownloadTaskInfo>>? _activeDownloadsSubscription;
  StreamSubscription<DownloadTaskUpdate>? _downloadUpdatesSubscription;

  Map<String, DownloadTaskInfo> get allDownloads {
    // تحويل القائمة إلى خريطة للتوافق مع الكود الموجود
    final allDownloads = _downloadManager.getAllDownloads();
    return Map.fromEntries(
      allDownloads.map((download) => MapEntry(download.taskId, download)),
    );
  }

  bool get hasActiveDownloads => allDownloads.isNotEmpty;
  bool get isInitialized => _isInitialized;

  int get totalDownloads => allDownloads.length;

  Map<String, DownloadTaskInfo> get runningDownloads {
    return Map.fromEntries(
      allDownloads.values
          .where(
            (download) =>
                download.status.isNotFinalState ||
                download.status != TaskStatus.paused,
          )
          .map((download) => MapEntry(download.taskId, download)),
    );
  }

  int get runningDownloadsCount =>
      allDownloads.values
          .where((download) => download.status == TaskStatus.running)
          .length;
  Map<String, DownloadTaskInfo> get completedDownloads {
    return Map.fromEntries(
      allDownloads.values
          .where((download) => download.status == TaskStatus.complete)
          .map((download) => MapEntry(download.taskId, download)),
    );
  }

  int get completedDownloadsCount =>
      allDownloads.values
          .where((download) => download.status == TaskStatus.complete)
          .length;

  /// تهيئة Provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // تهيئة DownloadManager
      await _downloadManager.initialize();

      // الاشتراك في التحديثات
      _activeDownloadsSubscription = _downloadManager.activeDownloads.listen(
        _onActiveDownloadsChanged,
      );

      _downloadUpdatesSubscription = _downloadManager.downloadUpdates.listen(
        _onDownloadUpdate,
      );

      _isInitialized = true;
      notifyListeners();

      logger.i('DownloadProvider initialized successfully');
    } catch (e) {
      logger.e('Error initializing DownloadProvider: $e');
      rethrow;
    }
  }

  /// الحصول على حالة التنزيل لعنصر معين
  DownloadStatus getDownloadStatus(BaseContentModel item) {
    final key = _getItemKey(item);
    return _itemDownloadStatus[key] ?? DownloadStatus.none;
  }

  /// الحصول على معلومات التنزيل لعنصر معين
  DownloadTaskInfo? getDownloadInfo(BaseContentModel item) {
    // استخدام البحث السريع من DownloadManager مباشرة
    return _downloadManager.getItemTaskInfo(item);
  }

  /// بدء تنزيل عنصر
  Future<void> startDownload(
    BuildContext context,
    BaseContentModel item, {
    bool forceDownload = false,
  }) async {
    try {
      // التأكد من التهيئة
      if (!_isInitialized) {
        await initialize();
      }

      // تحديث الحالة مؤقتاً
      _updateItemStatus(item, DownloadStatus.progress);

      final result = await _downloadManager.startDownload(
        item: item,
        forceDownload: forceDownload,
      );

      switch (result) {
        case DownloadResult.alreadyExists:
          _updateItemStatus(item, DownloadStatus.downloaded);
          return;
      }

      if (!result.success) {
        // إذا كان السبب تحذير الواي فاي
        if (result.message?.contains('تحذير') == true) {
          _updateItemStatus(item, DownloadStatus.none);
          if (context.mounted) {
            AppToasts.showError(context, description: result.message!);
            final shouldProceed = await showWifiWarningDialog(context);
            if (shouldProceed == true && context.mounted) {
              // إعادة المحاولة مع تجاهل تحذير الواي فاي
              return startDownload(context, item, forceDownload: true);
            }
          }

          return;
        }

        // خطأ آخر
        _updateItemStatus(item, DownloadStatus.none);
        if (context.mounted) {
          AppToasts.showError(
            context,
            description: result.message ?? 'فشل في بدء التنزيل',
          );
        }
        return;
      }

      // نجح بدء التنزيل
      if (result.filePath != null) {
        // الملف موجود بالفعل
        _updateItemStatus(item, DownloadStatus.downloaded);
        if (context.mounted) {
          AppToasts.showSuccess(context, description: 'الملف موجود بالفعل');
        }
      }
    } catch (e) {
      _updateItemStatus(item, DownloadStatus.none);
      if (context.mounted) {
        AppToasts.showError(context, description: 'خطأ في بدء التنزيل: $e');
      }
      logger.e('Error starting download: $e');
    }
  }

  /// استئناف تنزيل
  Future<void> resumeDownload(String taskId) async {
    try {
      final success = await _downloadManager.resumeDownload(taskId);
      if (!success) {
        logger.w('Failed to resume download: $taskId');
      }
    } catch (e) {
      logger.e('Error resuming download: $e');
    }
  }

  /// إيقاف تنزيل مؤقت
  Future<void> pauseDownload(String taskId) async {
    try {
      final success = await _downloadManager.pauseDownload(taskId);
      if (!success) {
        logger.w('Failed to pause download: $taskId');
      }
    } catch (e) {
      logger.e('Error pausing download: $e');
    }
  }

  /// إلغاء تنزيل
  Future<void> cancelDownload(
    BuildContext context,
    String taskId, {
    bool deleteFile = false,
  }) async {
    try {
      final success = await _downloadManager.cancelDownload(
        taskId,
        deleteFile: deleteFile,
      );

      if (context.mounted) {
        if (success) {
          AppToasts.showSuccess(context, description: 'تم إلغاء التنزيل');
        } else {
          AppToasts.showError(context, description: 'فشل في إلغاء التنزيل');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToasts.showError(context, description: 'خطأ في إلغاء التنزيل');
      }
      logger.e('Error canceling download: $e');
    }
  }

  /// حذف ملف منزل
  Future<void> deleteDownloadedFile(
    BuildContext context,
    BaseContentModel item,
  ) async {
    try {
      final success = await _downloadManager.deleteDownloadedFile(item);

      if (context.mounted) {
        if (success) {
          AppToasts.showInfo(context, description: 'تم حذف الملف');
        } else {
          AppToasts.showError(context, description: 'فشل في حذف الملف');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToasts.showError(context, description: 'خطأ في حذف الملف');
      }
      logger.e('Error deleting file: $e');
    }
  }

  /// تحديث حالة جميع العناصر من النظام
  Future<void> refreshAllDownloadStatuses(List<BaseContentModel> items) async {
    try {
      for (final item in items) {
        final status = await _downloadManager.getDownloadStatus(item);
        _updateItemStatus(item, status, notifyUi: false);
      }
    } catch (e) {
      logger.e('Error refreshing download statuses: $e');
    }
    notifyListeners();
  }

  // ==================== Private Methods ====================

  void _onActiveDownloadsChanged(List<DownloadTaskInfo> downloads) {
    // تحديث حالات العناصر من التنزيلات الواردة
    for (final download in downloads) {
      final status = _mapTaskStatusToDownloadStatus(download.status);
      _updateItemStatus(download.item, status, notifyUi: false);
    }

    notifyListeners();
  }

  void _onDownloadUpdate(DownloadTaskUpdate update) {
    if (update.item != null) {
      final status = _mapTaskStatusToDownloadStatus(update.status);
      _updateItemStatus(update.item!, status);
    }
  }

  void _updateItemStatus(
    BaseContentModel item,
    DownloadStatus status, {
    bool notifyUi = true,
  }) {
    final key = _getItemKey(item);
    _itemDownloadStatus[key] = status;
    if (notifyUi) {
      notifyListeners();
    }
  }

  String _getItemKey(BaseContentModel item) {
    return '${item.runtimeType}_${item.id}';
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

  @override
  void dispose() {
    _activeDownloadsSubscription?.cancel();
    _downloadUpdatesSubscription?.cancel();
    super.dispose();
  }
}
