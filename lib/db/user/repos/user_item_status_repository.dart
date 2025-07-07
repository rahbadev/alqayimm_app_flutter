import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_item_state_model.dart';
import '../user_db_helper.dart';
import '../db_constants.dart';

class UserItemStatusRepository {
  static Future<Database> get _db async => await UserDbHelper.userDatabase;
  static const String table = UserDatabaseConstants.userItemStatusTable;

  /// الدالة الرئيسية: إدراج أو تحديث حسب وجود العنصر (تحديث فقط القيم غير null)
  static Future<bool> upsert(UserItemStatusModel model) async {
    try {
      final db = await _db;
      final result = await db.query(
        table,
        where:
            '${UserItemStatusFields.itemId} = ? AND ${UserItemStatusFields.itemType} = ?',
        whereArgs: [model.itemId, model.itemType.value],
        limit: 1,
      );
      if (result.isEmpty) {
        await db.insert(table, model.toUpdateMap());
      } else {
        await db.update(
          table,
          model.toUpdateMap(),
          where:
              '${UserItemStatusFields.itemId} = ? AND ${UserItemStatusFields.itemType} = ?',
          whereArgs: [model.itemId, model.itemType.value],
        );
      }
      return true;
    } catch (e) {
      logger.e('Error upserting item status', error: e);
      return false;
    }
  }

  /// تعيين حالة المفضلة بشكل صريح
  static Future<bool> setFavorite(
    int itemId,
    ItemType itemType,
    bool value,
  ) async {
    return await upsert(
      UserItemStatusModel(
        id: 0,
        itemId: itemId,
        itemType: itemType,
        isFavorite: value,
      ),
    );
  }

  /// إضافة للمفضلة (تعني setFavorite مع value = true)
  static Future<bool> addToFavorite(int itemId, ItemType itemType) async {
    return await setFavorite(itemId, itemType, true);
  }

  /// إزالة من المفضلة (تعني setFavorite مع value = false)
  static Future<bool> removeFromFavorite(int itemId, ItemType itemType) async {
    return await setFavorite(itemId, itemType, false);
  }

  /// تبديل حالة المفضلة (toggle)
  static Future<bool> toggleFavorite(int itemId, ItemType itemType) async {
    try {
      final db = await _db;
      final result = await db.query(
        table,
        where:
            '${UserItemStatusFields.itemId} = ? AND ${UserItemStatusFields.itemType} = ?',
        whereArgs: [itemId, itemType.value],
        limit: 1,
      );
      bool newValue = true;
      if (result.isNotEmpty) {
        final current = UserItemStatusModel.fromMap(result.first);
        newValue = !(current.isFavorite ?? false);
      }
      return await setFavorite(itemId, itemType, newValue);
    } catch (e) {
      logger.e('Error toggling favorite status', error: e);
      return false;
    }
  }

  /// تعيين حالة الإكمال بشكل صريح
  static Future<bool> setCompleted(
    int itemId,
    ItemType itemType,
    bool value,
  ) async {
    return await upsert(
      UserItemStatusModel(
        id: 0,
        itemId: itemId,
        itemType: itemType,
        completedAt: value ? DateTime.now() : null,
      ),
    );
  }

  /// تعليم العنصر كمكتمل (تعني setCompleted مع value = true)
  static Future<bool> markAsCompleted(int itemId, ItemType itemType) async {
    return await setCompleted(itemId, itemType, true);
  }

  /// إزالة علامة الإكمال (تعني setCompleted مع value = false)
  static Future<bool> markAsNotCompleted(int itemId, ItemType itemType) async {
    return await setCompleted(itemId, itemType, false);
  }

  /// تبديل حالة الإكمال (toggle)
  static Future<bool> toggleCompleted(int itemId, ItemType itemType) async {
    try {
      final db = await _db;
      final result = await db.query(
        table,
        where:
            '${UserItemStatusFields.itemId} = ? AND ${UserItemStatusFields.itemType} = ?',
        whereArgs: [itemId, itemType.value],
        limit: 1,
      );
      bool newValue = true;
      if (result.isNotEmpty) {
        final current = UserItemStatusModel.fromMap(result.first);
        newValue = !(current.isCompleted);
      }
      return await setCompleted(itemId, itemType, newValue);
    } catch (e) {
      logger.e('Error toggling completed status', error: e);
      return false;
    }
  }

  /// حفظ آخر موضع
  static Future<bool> addLastPosition(
    int itemId,
    ItemType itemType,
    int position,
  ) async {
    return await upsert(
      UserItemStatusModel(
        id: 0,
        itemId: itemId,
        itemType: itemType,
        lastPosition: position,
      ),
    );
  }

  /// إزالة آخر موضع
  static Future<bool> removeLastPosition(int itemId, ItemType itemType) async {
    return await upsert(
      UserItemStatusModel(
        id: 0,
        itemId: itemId,
        itemType: itemType,
        lastPosition: null,
      ),
    );
  }

  /// مسح كل المفضلات
  static Future<bool> clearAllFavorites() async {
    try {
      final db = await _db;
      await db.update(table, {UserItemStatusFields.isFavorite: 0});
      return true;
    } catch (e) {
      return false;
    }
  }

  /// مسح كل المكتمل
  static Future<bool> clearAllCompleted() async {
    try {
      final db = await _db;
      await db.update(table, {UserItemStatusFields.completedAt: null});
      return true;
    } catch (e) {
      return false;
    }
  }

  /// مسح كل المواضع
  static Future<bool> clearAllPositions() async {
    try {
      final db = await _db;
      await db.update(table, {UserItemStatusFields.lastPosition: null});
      return true;
    } catch (e) {
      return false;
    }
  }

  /// جلب كل العناصر
  static Future<List<UserItemStatusModel>> getAllItems() async {
    final db = await _db;
    final result = await db.query(table);
    return result.map(UserItemStatusModel.fromMap).toList();
  }

  /// جلب العناصر المفضلة (مع إمكانية التصفية)
  static Future<List<UserItemStatusModel>> getFavoriteItems({
    ItemType? itemType,
  }) async {
    return await getItems(itemType: itemType, isFavorite: true);
  }

  /// جلب العناصر المكتملة (مع إمكانية التصفية)
  static Future<List<UserItemStatusModel>> getCompletedItems({
    ItemType? itemType,
  }) async {
    return await getItems(itemType: itemType, isCompletedOnly: true);
  }

  /// جلب العناصر التي لها موضع محفوظ
  static Future<List<UserItemStatusModel>> getItemsWithPosition({
    ItemType? itemType,
  }) async {
    return await getItems(itemType: itemType, hasPositionOnly: true);
  }

  /// جلب العناصر مع تصفية عامة (أي باراميتر)
  static Future<List<UserItemStatusModel>> getItems({
    int? itemId,
    ItemType? itemType,
    bool? isFavorite,
    DateTime? completedAt,
    int? lastPosition,
    bool isCompletedOnly = false,
    bool hasPositionOnly = false,
  }) async {
    final db = await _db;
    final where = <String>[];
    final args = <dynamic>[];
    if (itemId != null) {
      where.add('${UserItemStatusFields.itemId} = ?');
      args.add(itemId);
    }
    if (itemType != null) {
      where.add('${UserItemStatusFields.itemType} = ?');
      args.add(itemType.value);
    }
    if (isFavorite != null) {
      where.add('${UserItemStatusFields.isFavorite} = ?');
      args.add(isFavorite ? 1 : 0);
    }
    if (completedAt != null) {
      where.add('${UserItemStatusFields.completedAt} = ?');
      args.add(completedAt.toIso8601String());
    }
    if (lastPosition != null) {
      where.add('${UserItemStatusFields.lastPosition} = ?');
      args.add(lastPosition);
    }
    if (isCompletedOnly) {
      where.add('${UserItemStatusFields.completedAt} IS NOT NULL');
    }
    if (hasPositionOnly) {
      where.add('${UserItemStatusFields.lastPosition} IS NOT NULL');
    }
    final result = await db.query(
      table,
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
    );
    return result.map(UserItemStatusModel.fromMap).toList();
  }

  /// دالة عامة لجلب نسبة الإنجاز لأي تصنيف (مادة، مستوى، تصنيف)
  static Future<double> getCompletionPercentage({
    int? materialId,
    int? levelId,
    int? categoryId,
  }) async {
    final dbMain = await DbHelper.database;
    final repo = Repo(dbMain);

    // جلب الدروس حسب الفلاتر المطلوبة
    final lessons = await repo.fetchLessons(
      materialId: materialId,
      levelId: levelId,
      categoryId: categoryId,
    );
    final lessonIds = lessons.map((l) => l.id).toList();

    if (lessonIds.isEmpty) return 0.0;

    final userDb = await _db;
    int completedLessons = 0;
    const maxArgs = 900;
    for (var i = 0; i < lessonIds.length; i += maxArgs) {
      final subIds = lessonIds.sublist(
        i,
        (i + maxArgs).clamp(0, lessonIds.length),
      );
      final count = Sqflite.firstIntValue(
        await userDb.rawQuery(
          '''
        SELECT COUNT(*) FROM $table
        WHERE ${UserItemStatusFields.itemType} = ?
          AND ${UserItemStatusFields.completedAt} IS NOT NULL
          AND ${UserItemStatusFields.itemId} IN (${List.filled(subIds.length, '?').join(',')})
        ''',
          [ItemType.lesson.value, ...subIds],
        ),
      );
      completedLessons += count ?? 0;
    }

    return completedLessons / lessonIds.length;
  }

  /// دوال مختصرة لكل حالة
  static Future<double> getCompletionPercentageForMaterial(
    int materialId,
  ) async {
    return getCompletionPercentage(materialId: materialId);
  }

  static Future<double> getCompletionPercentageForLevel(int levelId) async {
    return getCompletionPercentage(levelId: levelId);
  }

  static Future<double> getCompletionPercentageForCategory(
    int categoryId,
  ) async {
    return getCompletionPercentage(categoryId: categoryId);
  }
}
