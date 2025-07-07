import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user_profile_model.dart';
import '../user_db_helper.dart';

class UserProfileRepository {
  static Future<UserProfileModel?> getUserProfile() async {
    try {
      final db = await UserDbHelper.userDatabase;
      final result = await db.query('user_profile', limit: 1);
      if (result.isNotEmpty) {
        return UserProfileModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, int>> getUserStats() async {
    try {
      final db = await UserDbHelper.userDatabase;

      // عدد المفضلة
      final favCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${UserDatabaseConstants.userItemStatusTable} WHERE ${UserItemStatusFields.isFavorite} = 1',
            ),
          ) ??
          0;

      // عدد الملاحظات
      final notesCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${UserDatabaseConstants.userNotesTable}',
            ),
          ) ??
          0;

      // عدد المكتمل
      final completedCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${UserDatabaseConstants.userItemStatusTable} WHERE ${UserItemStatusFields.completedAt} IS NOT NULL',
            ),
          ) ??
          0;

      return {
        'favorites': favCount,
        'notes': notesCount,
        'completions': completedCount,
      };
    } catch (e) {
      return {'favorites': 0, 'notes': 0, 'completions': 0};
    }
  }

  /// تحديث الملف الشخصي
  static Future<bool> updateUserProfile(UserProfileModel profile) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      await db.update(
        'user_profile',
        updatedProfile.toMap(),
        where: 'id = ?',
        whereArgs: [profile.id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// تسجيل دخول المستخدم
  static Future<bool> signInUser({
    required String email,
    String? fullName,
    String? googleDriveId,
  }) async {
    try {
      final profile = await getUserProfile();
      if (profile != null) {
        final updatedProfile = profile.copyWith(
          email: email,
          fullName: fullName ?? profile.fullName,
          googleDriveId: googleDriveId ?? profile.googleDriveId,
          isSignedIn: true,
          updatedAt: DateTime.now(),
        );
        return await updateUserProfile(updatedProfile);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// تسجيل خروج المستخدم
  static Future<bool> signOutUser() async {
    try {
      final profile = await getUserProfile();
      if (profile != null) {
        final updatedProfile = profile.copyWith(
          isSignedIn: false,
          updatedAt: DateTime.now(),
        );
        return await updateUserProfile(updatedProfile);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// تحديث تاريخ آخر نسخة احتياطية
  static Future<bool> updateLastBackupDate() async {
    try {
      final profile = await getUserProfile();
      if (profile != null) {
        final updatedProfile = profile.copyWith(
          lastBackupDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return await updateUserProfile(updatedProfile);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// تحديث تاريخ آخر استعادة
  static Future<bool> updateLastRestoreDate() async {
    try {
      final profile = await getUserProfile();
      if (profile != null) {
        final updatedProfile = profile.copyWith(
          lastRestoreDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return await updateUserProfile(updatedProfile);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// التحقق من حالة تسجيل الدخول
  static Future<bool> isUserSignedIn() async {
    try {
      final profile = await getUserProfile();
      return profile?.isSignedIn ?? false;
    } catch (e) {
      return false;
    }
  }

  /// جلب بريد المستخدم الإلكتروني
  static Future<String?> getUserEmail() async {
    try {
      final profile = await getUserProfile();
      return profile?.email;
    } catch (e) {
      return null;
    }
  }

  /// إعادة تعيين الملف الشخصي
  static Future<bool> resetUserProfile() async {
    try {
      final db = await UserDbHelper.userDatabase;
      await db.delete('user_profile');
      await db.insert('user_profile', {
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
