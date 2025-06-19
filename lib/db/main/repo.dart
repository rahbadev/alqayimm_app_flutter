import 'package:alqayimm_app_flutter/db/main/db_constants.dart';
import 'package:alqayimm_app_flutter/db/main/enmus.dart';
import 'package:alqayimm_app_flutter/models/main_db/book_model.dart';
import 'package:alqayimm_app_flutter/models/main_db/material_model.dart';
import 'package:alqayimm_app_flutter/models/main_db/type_model.dart';
import 'package:sqflite/sqflite.dart';

class Repo {
  final Database _db;
  Repo(this._db) {
    if (!_db.isOpen) {
      throw Exception('Database is not open');
    }
  }

  /*──────────────────── 1. جلب المستويات (Levels) ────────────────────*/
  Future<List<LevelModel>> fetchLevels({
    int? authorId,
    LevelSel levelSel = const LevelAll(),
    TypeOrder order = TypeOrder.id,
    bool excludeEmpty = true,
  }) async {
    final wb = WhereBuilder();
    if (authorId != null) {
      wb.eq('m.${DbConstants.MATERIALS_AUTHOR_ID}', authorId);
    }
    levelSel.apply(wb);

    final having = excludeEmpty ? 'HAVING COUNT(*) > 0' : '';
    String orderBy;
    switch (order) {
      case TypeOrder.id:
        orderBy = 'l.${DbConstants.CATEGORIES_ID}';
        break;
      case TypeOrder.count:
        orderBy = 'child_count DESC'; // تنازلي حسب العدد
        break;
      case TypeOrder.name:
        orderBy = 'l.${DbConstants.CATEGORIES_NAME} COLLATE NOCASE';
    }
    final sql = '''
SELECT 
  l.${DbConstants.LEVELS_ID} AS id,
  l.${DbConstants.LEVELS_NAME} AS name,
  COUNT(1) AS child_count
FROM ${DbConstants.MATERIALS_TABLE} m
JOIN ${DbConstants.LEVELS_TABLE} l 
  ON m.${DbConstants.MATERIALS_LEVEL_ID} = l.${DbConstants.LEVELS_ID}
${wb.sql()}
GROUP BY l.${DbConstants.LEVELS_ID}
$having
ORDER BY $orderBy;
''';
    final rows = await _db.rawQuery(sql, wb.args);
    return rows.map(LevelModel.fromMap).toList();
  }

  /*─────────────────── 2. جلب التصنيفات (Categories) ───────────────────*/
  Future<List<CategoryModel>> fetchCategories({
    int? authorId,
    bool forBooks = false,
    LevelSel levelSel = const LevelAll(),
    CategorySel categorySel = const CatAll(),
    TypeOrder order = TypeOrder.name,
    bool excludeEmpty = true,
  }) async {
    final alias = forBooks ? 'b' : 'm';
    final tableName =
        forBooks ? DbConstants.BOOKS_TABLE : DbConstants.MATERIALS_TABLE;

    final wb = WhereBuilder();
    if (authorId != null) {
      final col =
          forBooks
              ? 'b.${DbConstants.BOOKS_AUTHOR_ID}'
              : 'm.${DbConstants.MATERIALS_AUTHOR_ID}';
      wb.eq(col, authorId);
    }

    if (!forBooks) levelSel.apply(wb);
    categorySel.apply(wb, forBooks: forBooks);

    final having = excludeEmpty ? 'HAVING COUNT(1) > 0' : '';

    String orderBy;
    switch (order) {
      case TypeOrder.id:
        orderBy = 'c.${DbConstants.CATEGORIES_ID}';
        break;
      case TypeOrder.count:
        orderBy = 'child_count DESC'; // تنازلي حسب العدد
        break;
      case TypeOrder.name:
        orderBy = 'c.${DbConstants.CATEGORIES_NAME} COLLATE NOCASE';
    }

    final sql = '''
SELECT 
  c.${DbConstants.CATEGORIES_ID} AS id,
  c.${DbConstants.CATEGORIES_NAME} AS name,
  COUNT(1) AS child_count
FROM $tableName $alias
JOIN ${DbConstants.CATEGORIES_TABLE} c 
  ON $alias.${forBooks ? DbConstants.BOOKS_CATEGORY_ID : DbConstants.MATERIALS_CATEGORY_ID} = c.${DbConstants.CATEGORIES_ID}
${wb.sql()}
GROUP BY c.${DbConstants.CATEGORIES_ID}
$having
ORDER BY $orderBy;
''';
    final rows = await _db.rawQuery(sql, wb.args);
    return rows.map(CategoryModel.fromMap).toList();
  }

  /*─────────────────── 3. جلب المواد (Materials) ───────────────────*/
  Future<List<MaterialModel>> fetchMaterials({
    int? authorId,
    LevelSel levelSel = const LevelAll(),
    CategorySel categorySel = const CatAll(),
    MaterialOrderBy order = MaterialOrderBy.level,
  }) async {
    final wb = WhereBuilder();
    if (authorId != null) {
      wb.eq('m.${DbConstants.MATERIALS_AUTHOR_ID}', authorId);
    }

    levelSel.apply(wb);
    categorySel.apply(wb, forBooks: false);

    final orderCol =
        order == MaterialOrderBy.category
            ? 'm.${DbConstants.MATERIALS_CATEGORY_ID}'
            : 'm.${DbConstants.MATERIALS_LEVEL_ID}';

    final sql = '''
SELECT m.*
FROM ${DbConstants.MATERIALS_TABLE} m
${wb.sql()}
ORDER BY $orderCol;
''';
    final rows = await _db.rawQuery(sql, wb.args);
    return rows.map(MaterialModel.fromMap).toList();
  }

  /*─────────────────── 4. جلب الكتب (Books) ───────────────────*/
  Future<List<BookModel>> fetchBooks({
    int? authorId,
    CategorySel categorySel = const CatAll(),
    BookTypeSel bookTypeSel = const BookTypeAll(),
    BooksOrderBy order = BooksOrderBy.name,
  }) async {
    final wb = WhereBuilder();
    if (authorId != null) {
      wb.eq('b.${DbConstants.BOOKS_AUTHOR_ID}', authorId);
    }

    categorySel.apply(wb, forBooks: true);
    bookTypeSel.apply(wb);

    final orderCol = switch (order) {
      BooksOrderBy.name => 'b.${DbConstants.BOOKS_NAME}',
      BooksOrderBy.author => 'b.${DbConstants.BOOKS_AUTHOR_ID}',
      BooksOrderBy.category => 'b.${DbConstants.BOOKS_CATEGORY_ID}',
      BooksOrderBy.type => 'b.${DbConstants.BOOKS_TYPE_ID}',
    };

    final sql = '''
SELECT b.*
FROM ${DbConstants.BOOKS_TABLE} b
${wb.sql()}
ORDER BY $orderCol;
''';
    final rows = await _db.rawQuery(sql, wb.args);
    return rows.map(BookModel.fromMap).toList();
  }

  /*─────────────────── 5. جلب أنواع الكتب (Book Types) ───────────────────*/
  Future<List<BookTypeModel>> fetchBookTypes({
    BookTypeSel bookTypeSel = const BookTypeAll(),
    bool withCount = true,
    bool excludeEmpty = true,
    TypeOrder order = TypeOrder.name,
  }) async {
    final wb = WhereBuilder();
    bookTypeSel.apply(wb);

    // تحديد الحقول المطلوبة
    String selectFields =
        't.${DbConstants.BOOKS_TYPES_ID} AS id, '
        't.${DbConstants.BOOKS_TYPES_NAME} AS name';

    if (withCount) {
      selectFields +=
          ', COALESCE(COUNT(b.${DbConstants.BOOKS_ID}), 0) AS book_count';
    }

    // بناء الاستعلام
    String sql = '''
SELECT $selectFields
FROM ${DbConstants.BOOKS_TYPES_TABLE} t
''';

    // إضافة JOIN فقط إذا كنا نحتاج عدد الكتب
    if (withCount) {
      sql += '''
LEFT JOIN ${DbConstants.BOOKS_TABLE} b 
  ON t.${DbConstants.BOOKS_TYPES_ID} = b.${DbConstants.BOOKS_TYPE_ID}
''';
    }

    // إضافة شروط WHERE
    sql += wb.sql();

    // التجميع إذا كنا نريد عدد الكتب
    if (withCount) {
      sql += '\nGROUP BY t.${DbConstants.BOOKS_TYPES_ID}';

      // استبعاد الأنواع الفارغة
      if (excludeEmpty) {
        sql += '\nHAVING book_count > 0';
      }
    }

    // إضافة ORDER BY
    sql += '\nORDER BY ';
    switch (order) {
      case TypeOrder.id:
        sql += 't.${DbConstants.BOOKS_TYPES_ID}';
        break;
      case TypeOrder.count:
        sql += 'book_count DESC';
        break;
      case TypeOrder.name:
        sql += 't.${DbConstants.BOOKS_TYPES_NAME}';
    }
    sql += ';';

    final rows = await _db.rawQuery(sql, wb.args);
    return rows.map(BookTypeModel.fromMap).toList();
  }
}
