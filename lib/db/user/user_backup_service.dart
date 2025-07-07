import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'user_db_helper.dart';
import 'repos/user_profile_repository.dart';

/// خدمة النسخ الاحتياطي والاستعادة لقاعدة بيانات المستخدم
class UserBackupService {
  /// إنشاء نسخة احتياطية من قاعدة بيانات المستخدم
  static Future<Map<String, dynamic>?> createBackup() async {
    try {
      final db = await UserDbHelper.userDatabase;

      // جلب البيانات من جميع الجداول
      final profile = await db.query('user_profile');
      final favorites = await db.query('user_favorites');
      final notes = await db.query('user_notes');
      final completions = await db.query('user_completions');

      final backup = {
        'version': '1.0',
        'created_at': DateTime.now().toIso8601String(),
        'data': {
          'user_profile': profile,
          'user_favorites': favorites,
          'user_notes': notes,
          'user_completions': completions,
        },
      };

      return backup;
    } catch (e) {
      return null;
    }
  }

  /// حفظ النسخة الاحتياطية في ملف محلي
  static Future<File?> saveBackupToFile() async {
    try {
      final backup = await createBackup();
      if (backup == null) return null;

      final documentsDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File(
        '${documentsDir.path}/alqayimm_backup_$timestamp.json',
      );

      await backupFile.writeAsString(jsonEncode(backup));
      return backupFile;
    } catch (e) {
      return null;
    }
  }

  /// استعادة البيانات من نسخة احتياطية
  static Future<bool> restoreFromBackup(Map<String, dynamic> backupData) async {
    try {
      final db = await UserDbHelper.userDatabase;

      // التحقق من إصدار النسخة الاحتياطية
      final version = backupData['version'] as String?;
      if (version != '1.0') {
        throw Exception('إصدار النسخة الاحتياطية غير مدعوم');
      }

      final data = backupData['data'] as Map<String, dynamic>;

      // بدء معاملة لضمان سلامة البيانات
      await db.transaction((txn) async {
        // مسح البيانات الموجودة
        await txn.delete('user_profile');
        await txn.delete('user_favorites');
        await txn.delete('user_notes');
        await txn.delete('user_completions');

        // استعادة البيانات
        if (data['user_profile'] != null) {
          for (final row in data['user_profile'] as List) {
            await txn.insert('user_profile', row as Map<String, dynamic>);
          }
        }

        if (data['user_favorites'] != null) {
          for (final row in data['user_favorites'] as List) {
            await txn.insert('user_favorites', row as Map<String, dynamic>);
          }
        }

        if (data['user_notes'] != null) {
          for (final row in data['user_notes'] as List) {
            await txn.insert('user_notes', row as Map<String, dynamic>);
          }
        }

        if (data['user_completions'] != null) {
          for (final row in data['user_completions'] as List) {
            await txn.insert('user_completions', row as Map<String, dynamic>);
          }
        }
      });

      // تحديث تاريخ آخر استعادة
      await UserProfileRepository.updateLastRestoreDate();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// استعادة البيانات من ملف
  static Future<bool> restoreFromFile(File backupFile) async {
    try {
      final content = await backupFile.readAsString();
      final backupData = jsonDecode(content) as Map<String, dynamic>;
      return await restoreFromBackup(backupData);
    } catch (e) {
      return false;
    }
  }

  /// تصدير البيانات لـ Google Drive (تحتاج إلى تنفيذ خدمة Google Drive منفصلة)
  static Future<bool> uploadToGoogleDrive() async {
    try {
      final backup = await createBackup();
      if (backup == null) return false;

      // TODO: تنفيذ رفع البيانات إلى Google Drive
      // يحتاج إلى إضافة Google Drive API

      // تحديث تاريخ آخر نسخة احتياطية
      await UserProfileRepository.updateLastBackupDate();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// تحميل البيانات من Google Drive (تحتاج إلى تنفيذ خدمة Google Drive منفصلة)
  static Future<bool> downloadFromGoogleDrive() async {
    try {
      // TODO: تنفيذ تحميل البيانات من Google Drive
      // يحتاج إلى إضافة Google Drive API

      return true;
    } catch (e) {
      return false;
    }
  }

  /// جلب معلومات آخر نسخة احتياطية
  static Future<Map<String, String?>> getBackupInfo() async {
    try {
      final profile = await UserProfileRepository.getUserProfile();
      return {
        'last_backup': profile?.lastBackupDate?.toString(),
        'last_restore': profile?.lastRestoreDate?.toString(),
        'email': profile?.email,
        'is_signed_in': profile?.isSignedIn.toString(),
      };
    } catch (e) {
      return {};
    }
  }

  /// التحقق من صحة النسخة الاحتياطية
  static bool validateBackup(Map<String, dynamic> backupData) {
    try {
      // التحقق من وجود الحقول المطلوبة
      if (!backupData.containsKey('version') ||
          !backupData.containsKey('created_at') ||
          !backupData.containsKey('data')) {
        return false;
      }

      final data = backupData['data'] as Map<String, dynamic>?;
      if (data == null) return false;

      // التحقق من وجود الجداول الأساسية
      return data.containsKey('user_profile') &&
          data.containsKey('user_favorites') &&
          data.containsKey('user_notes') &&
          data.containsKey('user_completions');
    } catch (e) {
      return false;
    }
  }
}
