import 'package:alqayimm_app_flutter/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'db_constants.dart';

class UserDbHelper {
  static Database? _userDb;

  static Future<Database> get userDatabase async {
    if (_userDb != null) return _userDb!;

    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = '${documentsDir.path}/${UserDatabaseConstants.dbName}';

    _userDb = await openDatabase(
      dbPath,
      version: UserDatabaseConstants.dbVersion,
      onCreate: _createDb,
    );
    return _userDb!;
  }

  static Future<void> _createDb(Database db, int version) async {
    logger.i('Creating user database with version $version');
    // جدول الملف الشخصي للمستخدم
    await db.execute('''
      CREATE TABLE ${UserDatabaseConstants.userProfileTable} (
        ${UserProfileFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${UserProfileFields.fullName} TEXT,
        ${UserProfileFields.email} TEXT,
        ${UserProfileFields.googleDriveId} TEXT,
        ${UserProfileFields.lastBackupDate} TEXT,
        ${UserProfileFields.lastRestoreDate} TEXT,
        ${UserProfileFields.isSignedIn} INTEGER DEFAULT 0,
        ${UserProfileFields.createdAt} TEXT NOT NULL,
        ${UserProfileFields.updatedAt} TEXT NOT NULL
      )
    ''');

    // جدول الملاحظات القديم
    await db.execute('''
      CREATE TABLE ${UserDatabaseConstants.userNotesTable} (
        ${UserNoteFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${UserNoteFields.title} TEXT NOT NULL,
        ${UserNoteFields.content} TEXT NOT NULL,
        ${UserNoteFields.tags} TEXT,
        ${UserNoteFields.createdAt} TEXT NOT NULL
      )
    ''');

    // جدول العلامات المرجعية
    await db.execute('''
      CREATE TABLE ${UserDatabaseConstants.bookmarksTable} (
        ${UserBookmarkFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${UserBookmarkFields.itemId} INTEGER NOT NULL,
        ${UserBookmarkFields.itemType} TEXT NOT NULL CHECK (${UserBookmarkFields.itemType} IN ${ItemType.allowedForNotesCheck()}),
        ${UserBookmarkFields.position} INTEGER,
        ${UserBookmarkFields.title} TEXT NOT NULL,
        ${UserBookmarkFields.createdAt} TEXT NOT NULL
      )
    ''');

    // جدول حالة العناصر
    await db.execute('''
      CREATE TABLE ${UserDatabaseConstants.userItemStatusTable} (
        ${UserItemStatusFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${UserItemStatusFields.itemId} INTEGER NOT NULL,
        ${UserItemStatusFields.itemType} TEXT NOT NULL CHECK (${UserItemStatusFields.itemType} IN ${ItemType.allowedForNotesCheck()}),
        ${UserItemStatusFields.isFavorite} INTEGER DEFAULT 0,
        ${UserItemStatusFields.completedAt} TEXT,
        ${UserItemStatusFields.lastPosition} INTEGER,
        UNIQUE(${UserItemStatusFields.itemId}, ${UserItemStatusFields.itemType})
      )
    ''');

    // فهارس لتحسين الأداء
    await db.execute(
      'CREATE INDEX idx_status_item ON ${UserDatabaseConstants.userItemStatusTable}(${UserItemStatusFields.itemId}, ${UserItemStatusFields.itemType})',
    );
    await db.execute(
      'CREATE INDEX idx_notes_tags ON ${UserDatabaseConstants.userNotesTable}(${UserNoteFields.tags})',
    );
    await db.execute(
      'CREATE INDEX idx_bookmarks_item ON ${UserDatabaseConstants.bookmarksTable}(${UserBookmarkFields.itemId}, ${UserBookmarkFields.itemType})',
    );
    await db.execute(
      'CREATE INDEX idx_notes_item ON ${UserDatabaseConstants.userNotesTable}(${UserNoteFields.tags})',
    );

    // إنشاء ملف شخصي افتراضي
    await db.insert(UserDatabaseConstants.userProfileTable, {
      UserProfileFields.createdAt: DateTime.now().toIso8601String(),
      UserProfileFields.updatedAt: DateTime.now().toIso8601String(),
    });
  }

  static Future<void> closeDatabase() async {
    if (_userDb != null) {
      await _userDb!.close();
      _userDb = null;
    }
  }

  /// حذف قاعدة بيانات المستخدم وإرجاع true إذا تم الحذف فعلاً
  static Future<bool> deleteDatabase() async {
    logger.i('Deleting user database');
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = '${documentsDir.path}/${UserDatabaseConstants.dbName}';
    final file = File(dbPath);
    if (await file.exists()) {
      await file.delete();
      logger.i('User database deleted at $dbPath');
      _userDb = null;
      return true;
    } else {
      logger.w('User database file not found at $dbPath');
      _userDb = null;
      return false;
    }
  }
}
