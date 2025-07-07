import 'package:sqflite/sqflite.dart';
import '../models/user_bookmark_model.dart';
import '../user_db_helper.dart';
import '../db_constants.dart';

class BookmarksRepository {
  /// إضافة علامة مرجعية جديدة
  static Future<int?> addBookmark(UserBookmarkModel bookmark) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final id = await db.insert(
        UserDatabaseConstants.bookmarksTable,
        bookmark.toMap()
          ..remove('id'), // إزالة المعرف للسماح بإنشاء معرف تلقائي
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      return null;
    }
  }

  /// تحديث علامة مرجعية موجودة
  static Future<bool> updateBookmark(UserBookmarkModel bookmark) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final updatedBookmark = bookmark.copyWith(updatedAt: DateTime.now());
      await db.update(
        UserDatabaseConstants.bookmarksTable,
        updatedBookmark.toMap(),
        where: '${UserBookmarkFields.id} = ?',
        whereArgs: [bookmark.id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف علامة مرجعية
  static Future<bool> deleteBookmark(int bookmarkId) async {
    try {
      final db = await UserDbHelper.userDatabase;
      await db.delete(
        UserDatabaseConstants.bookmarksTable,
        where: '${UserBookmarkFields.id} = ?',
        whereArgs: [bookmarkId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// جلب علامة مرجعية بالمعرف
  static Future<UserBookmarkModel?> getBookmarkById(int bookmarkId) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final result = await db.query(
        UserDatabaseConstants.bookmarksTable,
        where: '${UserBookmarkFields.id} = ?',
        whereArgs: [bookmarkId],
      );

      if (result.isNotEmpty) {
        return UserBookmarkModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// جلب جميع العلامات المرجعية
  static Future<List<UserBookmarkModel>> getAllBookmarks({
    String? searchQuery,
    ItemType? itemTypeFilter,
    String? orderBy = '${UserBookmarkFields.createdAt} DESC',
  }) async {
    try {
      final db = await UserDbHelper.userDatabase;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      // تطبيق فلتر نوع العنصر
      if (itemTypeFilter != null) {
        whereClause += '${UserBookmarkFields.itemType} = ?';
        whereArgs.add(itemTypeFilter.value);
      }

      // تطبيق فلتر البحث
      if (searchQuery != null && searchQuery.isNotEmpty) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += '${UserBookmarkFields.title} LIKE ?';
        whereArgs.add('%$searchQuery%');
      }

      final result = await db.query(
        UserDatabaseConstants.bookmarksTable,
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: orderBy,
      );

      return result.map((map) => UserBookmarkModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// جلب العلامات المرجعية لعنصر معين
  static Future<List<UserBookmarkModel>> getBookmarksForItem({
    required int itemId,
    required ItemType itemType,
  }) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final result = await db.query(
        UserDatabaseConstants.bookmarksTable,
        where:
            '${UserBookmarkFields.itemId} = ? AND ${UserBookmarkFields.itemType} = ?',
        whereArgs: [itemId, itemType.value],
        orderBy: '${UserBookmarkFields.createdAt} DESC',
      );

      return result.map((map) => UserBookmarkModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// حذف جميع العلامات المرجعية لعنصر معين
  static Future<bool> deleteBookmarksForItem({
    required int itemId,
    required ItemType itemType,
  }) async {
    try {
      final db = await UserDbHelper.userDatabase;
      await db.delete(
        UserDatabaseConstants.bookmarksTable,
        where:
            '${UserBookmarkFields.itemId} = ? AND ${UserBookmarkFields.itemType} = ?',
        whereArgs: [itemId, itemType.value],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
