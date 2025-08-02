import 'dart:io';

import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  /// حذف ملف من المسار المحدد مع معالجة جميع الحالات

  static Future<bool> deleteItemFile(
    BaseContentModel item, {
    bool trueIfNotExists = true,
  }) async {
    final filePath = await getItemFileFullPath(item, true);
    if (filePath == null) {
      logger.w('File path is null for item: ${item.id}');
      return false;
    }
    return deleteFileSafely(filePath, trueIfNotExists: trueIfNotExists);
  }

  static Future<bool> deleteFileSafely(
    String path, {
    bool trueIfNotExists = true,
  }) async {
    logger.d('Attempting to delete file at: $path');
    try {
      final file = File(path);
      final exists = await file.exists();
      logger.d('File exists: $exists at $path');
      if (!exists) {
        return trueIfNotExists;
      }
      FileSystemEntity delete = await file.delete();
      logger.d('File deleted: $delete');
      return true;
    } catch (e) {
      logger.e('Error deleting file: $e');
      return false;
    }
  }

  // Helper to sanitize file/folder names
  static String? sanitize(String? input) {
    if (input == null) return null;
    // Replace spaces with underscores and remove any non-safe characters
    return input.replaceAll(' ', '_').replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
  }

  // التحقق هل الملف موجود أو لا
  static Future<bool> isItemFileExists(BaseContentModel item) async {
    final filePath = await getItemFileFullPath(item, true);
    return filePath != null && await File(filePath).exists();
  }

  static String getItemTitle(BaseContentModel item) {
    if (item is LessonModel) {
      final materialName = item.materialName ?? 'Unknown';
      final lessonName = item.lessonNumber ?? item.id;
      return '${FileUtils.sanitize(materialName)}_$lessonName';
    } else if (item is BookModel) {
      return '${FileUtils.sanitize(item.name)}';
    }
    return 'unknown';
  }

  static String getItemFileName(BaseContentModel item) {
    if (item is LessonModel) {
      final materialName = FileUtils.sanitize(item.materialName) ?? 'Unknown';
      final lessonName = item.lessonNumber ?? item.id;
      return '${materialName}_$lessonName.mp3';
    } else if (item is BookModel) {
      return '${FileUtils.sanitize(item.name)}.pdf';
    }
    return 'unknown';
  }

  static Future<String?> getItemFileDir(
    BaseContentModel item,
    bool useFullPath,
  ) async {
    try {
      String docsDir = '';
      if (useFullPath) {
        final dir = await getApplicationDocumentsDirectory();
        docsDir = dir.absolute.path;
      }

      final itemDir = item is LessonModel ? 'lessons' : 'books';
      final parentDir =
          item is LessonModel
              ? FileUtils.sanitize(item.materialName) ?? 'Unknown'
              : '';
      final dirPath = '$docsDir/downloaded_files/$itemDir/$parentDir';
      return dirPath;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getItemFileFullPath(
    BaseContentModel item,
    bool useFullPath,
  ) async {
    try {
      final dir = await getItemFileDir(item, useFullPath);
      final itemName = getItemFileName(item);
      final filePath = '$dir/$itemName';
      return filePath;
    } catch (e) {
      logger.e('Error getting download path: $e');
      return null;
    }
  }

  static Future<SpaceCheckResult> checkAvailableSpace(
    BaseContentModel item,
  ) async {
    try {
      // تقدير حجم الملف (يمكن تحسينه لاحقاً بالاستعلام عن الخادم)
      int estimatedSize;
      if (item is LessonModel) {
        estimatedSize = 10 * 1024 * 1024; // 10 MB للدرس الصوتي
      } else if (item is BookModel) {
        estimatedSize = 5 * 1024 * 1024; // 5 MB للكتاب
      } else {
        estimatedSize = 1024 * 1024; // 1 MB افتراضي
      }

      final docsDir = await getApplicationDocumentsDirectory();
      final stat = await docsDir.stat();

      // فحص بسيط للمساحة (يمكن تحسينه)
      return SpaceCheckResult(
        hasEnoughSpace: true,
        availableBytes: stat.size,
        requiredBytes: estimatedSize,
      );
    } catch (e) {
      logger.e('Error checking space: $e');
      return SpaceCheckResult(
        hasEnoughSpace: true, // نسمح بالتنزيل في حالة الخطأ
        availableBytes: 0,
        requiredBytes: 0,
      );
    }
  }
}

/// نتيجة فحص المساحة
class SpaceCheckResult {
  final bool hasEnoughSpace;
  final int availableBytes;
  final int requiredBytes;

  const SpaceCheckResult({
    required this.hasEnoughSpace,
    required this.availableBytes,
    required this.requiredBytes,
  });
}
