import 'package:sqflite/sqflite.dart';
import '../models/user_note_model.dart';
import '../user_db_helper.dart';
import '../db_constants.dart';

/// مستودع إدارة ملاحظات المستخدم (يدعم البحث، التصفية، الوسوم، العدّ)
class UserNotesRepository {
  /// إضافة ملاحظة جديدة
  static Future<int?> addNote(UserNoteModel note) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final id = await db.insert(
        UserDatabaseConstants.userNotesTable,
        note.toMap()..remove(UserNoteFields.id),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      return null;
    }
  }

  /// تحديث ملاحظة موجودة
  static Future<bool> updateNote(UserNoteModel note) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await db.update(
        UserDatabaseConstants.userNotesTable,
        updatedNote.toMap(),
        where: '${UserNoteFields.id} = ?',
        whereArgs: [note.id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف ملاحظة
  static Future<bool> deleteNote(int noteId) async {
    try {
      final db = await UserDbHelper.userDatabase;
      await db.delete(
        UserDatabaseConstants.userNotesTable,
        where: '${UserNoteFields.id} = ?',
        whereArgs: [noteId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// جلب ملاحظة بالمعرف
  static Future<UserNoteModel?> getNoteById(int noteId) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final result = await db.query(
        UserDatabaseConstants.userNotesTable,
        where: '${UserNoteFields.id} = ?',
        whereArgs: [noteId],
        limit: 1,
      );
      if (result.isNotEmpty) {
        return UserNoteModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// جلب جميع الملاحظات مع دعم البحث والتصفية بالوسم والترتيب
  static Future<List<UserNoteModel>> getAllNotes({
    String? searchQuery,
    String? tagFilter,
    String orderBy = '${UserNoteFields.createdAt} DESC',
  }) async {
    try {
      final db = await UserDbHelper.userDatabase;
      String whereClause = '';
      List<dynamic> whereArgs = [];

      // فلتر البحث بالنص
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause +=
            '(${UserNoteFields.title} LIKE ? OR ${UserNoteFields.content} LIKE ?)';
        whereArgs.addAll(['%$searchQuery%', '%$searchQuery%']);
      }

      // فلتر الوسم
      if (tagFilter != null && tagFilter.isNotEmpty) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += '${UserNoteFields.tags} LIKE ?';
        whereArgs.add('%$tagFilter%');
      }

      final result = await db.query(
        UserDatabaseConstants.userNotesTable,
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: orderBy,
      );
      return result.map((map) => UserNoteModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// جلب ملاحظات عنصر معين
  static Future<List<UserNoteModel>> getNotesForItem(
    int itemId,
    String itemType,
  ) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final result = await db.query(
        UserDatabaseConstants.userNotesTable,
        where: 'item_id = ? AND item_type = ?',
        whereArgs: [itemId, itemType],
        orderBy: 'position_seconds ASC, ${UserNoteFields.createdAt} ASC',
      );
      return result.map((map) => UserNoteModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// البحث في الملاحظات بالنص الكامل (العنوان/المحتوى/الوسوم)
  static Future<List<UserNoteModel>> searchNotes(String query) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final result = await db.query(
        UserDatabaseConstants.userNotesTable,
        where:
            '${UserNoteFields.title} LIKE ? OR ${UserNoteFields.content} LIKE ? OR ${UserNoteFields.tags} LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: '${UserNoteFields.createdAt} DESC',
      );
      return result.map((map) => UserNoteModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// جلب الملاحظات حسب العلامة
  static Future<List<UserNoteModel>> getNotesByTag(String tag) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final result = await db.query(
        UserDatabaseConstants.userNotesTable,
        where: '${UserNoteFields.tags} LIKE ?',
        whereArgs: ['%$tag%'],
        orderBy: '${UserNoteFields.createdAt} DESC',
      );
      return result.map((map) => UserNoteModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// جلب جميع الوسوم المستخدمة
  static Future<List<String>> getAllTags() async {
    try {
      final db = await UserDbHelper.userDatabase;
      final result = await db.query(
        UserDatabaseConstants.userNotesTable,
        columns: [UserNoteFields.tags],
        where:
            '${UserNoteFields.tags} IS NOT NULL AND ${UserNoteFields.tags} != ""',
      );

      final allTags = <String>{};
      for (final row in result) {
        final tagsString = row[UserNoteFields.tags] as String?;
        if (tagsString != null && tagsString.isNotEmpty) {
          final tags = tagsString
              .split(',')
              .where((tag) => tag.trim().isNotEmpty);
          allTags.addAll(tags.map((tag) => tag.trim()));
        }
      }

      return allTags.toList()..sort();
    } catch (e) {
      return [];
    }
  }

  /// عدد الملاحظات
  static Future<int> getNotesCount() async {
    try {
      final db = await UserDbHelper.userDatabase;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${UserDatabaseConstants.userNotesTable}',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// عدد الملاحظات لعنصر معين
  static Future<int> getNotesCountForItem(int itemId, String itemType) async {
    try {
      final db = await UserDbHelper.userDatabase;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${UserDatabaseConstants.userNotesTable} WHERE item_id = ? AND item_type = ?',
        [itemId, itemType],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// حذف جميع الملاحظات لعنصر معين
  static Future<bool> deleteAllNotesForItem(int itemId, String itemType) async {
    try {
      final db = await UserDbHelper.userDatabase;
      await db.delete(
        UserDatabaseConstants.userNotesTable,
        where: 'item_id = ? AND item_type = ?',
        whereArgs: [itemId, itemType],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
