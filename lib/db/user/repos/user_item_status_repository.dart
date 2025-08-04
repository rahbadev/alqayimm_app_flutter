import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_item_state_model.dart';
import '../user_db_helper.dart';
import '../db_constants.dart';

class UserItemStatusRepository {
  static Future<Database> get _db async => await UserDbHelper.userDatabase;
  static const String _table = UserDatabaseConstants.userItemStatusTable;
  static const int _maxSqliteArgs = 900;

  // ==================== Core Operations ====================

  static Future<bool> upsert(UserItemStatusModel model) async {
    final db = await _db;
    try {
      // جلب السطر الحالي (إن وجد)
      final existing = await _getExistingItem(db, model.itemId, model.itemType);
      logger.d(
        'Upserting item status: ${model.itemId}, existing: ${existing?.toMap()}',
      );

      // دمج القيم: إذا القيمة مرسلة نستخدمها، إذا null نستخدم القديمة (إن وجدت)
      final merged = UserItemStatusModel(
        id: existing?.id ?? 0,
        itemId: model.itemId,
        itemType: model.itemType,
        isFavorite: model.isFavorite ?? existing?.isFavorite,
        completedAt: model.completedString ?? existing?.completedString,
        lastPosition: model.lastPosition ?? existing?.lastPosition,
      );
      logger.d('Merged item status: ${merged.toMap()}');

      final map = merged.toMap();
      map.remove(UserItemStatusFields.id); // إذا كان id تلقائي

      await db.insert(
        _table,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      logger.e('Error upserting item status', error: e);
      return false;
    }
  }

  /// جلب عنصر واحد بالمعرف والنوع
  static Future<UserItemStatusModel?> getItem(
    int itemId,
    ItemType itemType,
  ) async {
    try {
      final db = await _db;
      return await _getExistingItem(db, itemId, itemType);
    } catch (e) {
      logger.e('Error getting item status', error: e);
      return null;
    }
  }

  // ==================== Favorite Operations ====================

  /// تعيين حالة المفضلة
  static Future<bool> _setFavorite(
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

  /// إضافة للمفضلة
  static Future<bool> addToFavorite(int itemId, ItemType itemType) =>
      _setFavorite(itemId, itemType, true);

  /// إزالة من المفضلة
  static Future<bool> removeFromFavorite(int itemId, ItemType itemType) =>
      _setFavorite(itemId, itemType, false);

  /// تبديل حالة المفضلة
  static Future<bool> toggleFavorite(int itemId, ItemType itemType) async {
    try {
      final current = await getItem(itemId, itemType);
      final newValue = !(current?.isFavorite ?? false);
      return await _setFavorite(itemId, itemType, newValue);
    } catch (e) {
      logger.e('Error toggling favorite status', error: e);
      return false;
    }
  }

  // ==================== Completion Operations ====================

  /// تعيين حالة الإكمال
  static Future<bool> _setCompleted(
    int itemId,
    ItemType itemType,
    bool value,
  ) async {
    return await upsert(
      UserItemStatusModel(
        id: 0,
        itemId: itemId,
        itemType: itemType,
        completedAt: value ? DateTime.now().toIso8601String() : '',
      ),
    );
  }

  /// تعليم العنصر كمكتمل
  static Future<bool> markAsCompleted(int itemId, ItemType itemType) =>
      _setCompleted(itemId, itemType, true);

  /// إزالة علامة الإكمال
  static Future<bool> markAsNotCompleted(int itemId, ItemType itemType) =>
      _setCompleted(itemId, itemType, false);

  /// تبديل حالة الإكمال
  static Future<bool> toggleCompleted(int itemId, ItemType itemType) async {
    try {
      final current = await getItem(itemId, itemType);
      final newValue = !(current?.isCompleted ?? false);
      logger.d(
        'Toggling completed status for itemId: $itemId, current: ${current?.isCompleted}, newValue: $newValue',
      );
      return await _setCompleted(itemId, itemType, newValue);
    } catch (e) {
      logger.e('Error toggling completed status', error: e);
      return false;
    }
  }

  // ==================== Position Operations ====================

  /// حفظ آخر موضع
  static Future<bool> saveLastPosition(
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

  /// جلب آخر موضع محفوظ للعنصر
  static Future<int?> getLastPosition(int itemId, ItemType itemType) async {
    try {
      final item = await getItem(itemId, itemType);
      return item?.lastPosition;
    } catch (e) {
      logger.e('Error getting last position', error: e);
      return null;
    }
  }
  // ==================== Bulk Operations ====================

  /// مسح كل المفضلات
  static Future<bool> clearAllFavorites() =>
      _bulkUpdate({UserItemStatusFields.isFavorite: 0});

  /// مسح كل العناصر المكتملة
  static Future<bool> clearAllCompleted() =>
      _bulkUpdate({UserItemStatusFields.completedAt: null});

  /// مسح كل المواضع
  static Future<bool> clearAllPositions() =>
      _bulkUpdate({UserItemStatusFields.lastPosition: null});

  // ==================== Query Operations ====================

  /// جلب كل العناصر
  static Future<List<UserItemStatusModel>> getAllItems() async {
    final db = await _db;
    final result = await db.query(_table);
    return result.map(UserItemStatusModel.fromMap).toList();
  }

  /// جلب العناصر المفضلة
  static Future<List<UserItemStatusModel>> getFavoriteItems({
    ItemType? itemType,
  }) => getItems(itemType: itemType, isFavorite: true);

  /// جلب العناصر المكتملة
  static Future<List<UserItemStatusModel>> getCompletedItems({
    ItemType? itemType,
  }) => getItems(itemType: itemType, isCompletedOnly: true);

  /// جلب العناصر التي لها موضع محفوظ
  static Future<List<UserItemStatusModel>> getItemsWithPosition({
    ItemType? itemType,
  }) => getItems(itemType: itemType, hasPositionOnly: true);

  /// جلب العناصر مع تصفية متقدمة
  static Future<List<UserItemStatusModel>> getItems({
    int? itemId,
    ItemType? itemType,
    bool? isFavorite,
    DateTime? completedAt,
    int? lastPosition,
    bool isCompletedOnly = false,
    bool hasPositionOnly = false,
  }) async {
    try {
      final db = await _db;
      final query = _buildQuery(
        itemId: itemId,
        itemType: itemType,
        isFavorite: isFavorite,
        completedAt: completedAt,
        lastPosition: lastPosition,
        isCompletedOnly: isCompletedOnly,
        hasPositionOnly: hasPositionOnly,
      );

      final result = await db.query(
        _table,
        where: query.where,
        whereArgs: query.args,
      );

      return result.map(UserItemStatusModel.fromMap).toList();
    } catch (e) {
      logger.e('Error fetching items', error: e);
      return [];
    }
  }

  // ==================== Statistics Operations ====================

  /// حساب نسبة الإنجاز العامة
  static Future<double> getCompletionPercentage({
    int? materialId,
    int? levelId,
    int? categoryId,
  }) async {
    try {
      final lessons = await _fetchLessons(
        materialId: materialId,
        levelId: levelId,
        categoryId: categoryId,
      );

      if (lessons.isEmpty) return 0.0;

      final completedCount = await _countCompletedLessons(lessons);
      return completedCount / lessons.length;
    } catch (e) {
      logger.e('Error calculating completion percentage', error: e);
      return 0.0;
    }
  }

  /// دوال مختصرة للإحصائيات
  static Future<double> getCompletionPercentageForMaterial(int materialId) =>
      getCompletionPercentage(materialId: materialId);

  static Future<double> getCompletionPercentageForLevel(int levelId) =>
      getCompletionPercentage(levelId: levelId);

  static Future<double> getCompletionPercentageForCategory(int categoryId) =>
      getCompletionPercentage(categoryId: categoryId);

  // ==================== Private Helper Methods ====================

  /// جلب عنصر موجود من قاعدة البيانات
  static Future<UserItemStatusModel?> _getExistingItem(
    Database db,
    int itemId,
    ItemType itemType,
  ) async {
    final result = await db.query(
      _table,
      where:
          '${UserItemStatusFields.itemId} = ? AND ${UserItemStatusFields.itemType} = ?',
      whereArgs: [itemId, itemType.value],
      limit: 1,
    );

    return result.isNotEmpty ? UserItemStatusModel.fromMap(result.first) : null;
  }

  /// تحديث مجمع لكل الجدول
  static Future<bool> _bulkUpdate(Map<String, dynamic> values) async {
    try {
      final db = await _db;
      await db.update(_table, values);
      return true;
    } catch (e) {
      logger.e('Error in bulk update', error: e);
      return false;
    }
  }

  /// بناء استعلام SQL
  static ({String? where, List<dynamic> args}) _buildQuery({
    int? itemId,
    ItemType? itemType,
    bool? isFavorite,
    DateTime? completedAt,
    int? lastPosition,
    bool isCompletedOnly = false,
    bool hasPositionOnly = false,
  }) {
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

    return (where: where.isNotEmpty ? where.join(' AND ') : null, args: args);
  }

  /// جلب الدروس من قاعدة البيانات الرئيسية
  static Future<List<dynamic>> _fetchLessons({
    int? materialId,
    int? levelId,
    int? categoryId,
  }) async {
    final dbMain = await DbHelper.database;
    final repo = Repo(dbMain);
    return await repo.fetchLessons(
      materialId: materialId,
      levelId: levelId,
      categoryId: categoryId,
    );
  }

  /// عد الدروس المكتملة
  static Future<int> _countCompletedLessons(List<dynamic> lessons) async {
    final lessonIds = lessons.map((l) => l.id).toList();
    final db = await _db;
    int completedCount = 0;

    // تقسيم المعرفات لتجنب حد SQLite
    for (var i = 0; i < lessonIds.length; i += _maxSqliteArgs) {
      final subIds = lessonIds.sublist(
        i,
        (i + _maxSqliteArgs).clamp(0, lessonIds.length),
      );

      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          '''
          SELECT COUNT(*) FROM $_table
          WHERE ${UserItemStatusFields.itemType} = ?
            AND ${UserItemStatusFields.completedAt} IS NOT NULL
            AND ${UserItemStatusFields.itemId} IN (${List.filled(subIds.length, '?').join(',')})
          ''',
          [ItemType.lesson.value, ...subIds],
        ),
      );

      completedCount += count ?? 0;
    }

    return completedCount;
  }
}
