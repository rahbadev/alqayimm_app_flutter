import 'package:alqayimm_app_flutter/db/main/db_constants.dart';

/// فلتر اختيار المستوى للمواد
abstract class LevelSel {
  const LevelSel();

  factory LevelSel.all() = LevelAll;
  factory LevelSel.withLevel() = LevelWith;
  factory LevelSel.withoutLevel() = LevelWithout;
  factory LevelSel.only(List<int> ids) = LevelOnly;

  void apply(WhereBuilder wb);
}

class LevelAll extends LevelSel {
  const LevelAll();
  @override
  void apply(WhereBuilder wb) {}
}

class LevelWith extends LevelSel {
  const LevelWith();
  @override
  void apply(WhereBuilder wb) {
    wb.notNull('m.${DbConstants.MATERIALS_LEVEL_ID}');
  }
}

class LevelWithout extends LevelSel {
  const LevelWithout();
  @override
  void apply(WhereBuilder wb) {
    wb.isNull('m.${DbConstants.MATERIALS_LEVEL_ID}');
  }
}

class LevelOnly extends LevelSel {
  final List<int> ids;
  const LevelOnly(this.ids);
  @override
  void apply(WhereBuilder wb) {
    if (ids.isNotEmpty) {
      wb.inList('m.${DbConstants.MATERIALS_LEVEL_ID}', ids);
    }
  }
}

/// فلتر اختيار التصنيف
abstract class CategorySel {
  const CategorySel();
  factory CategorySel.all() = CatAll;
  factory CategorySel.only(List<int> ids) = CatOnly;

  void apply(WhereBuilder wb, {required bool forBooks});
}

class CatAll extends CategorySel {
  const CatAll();
  @override
  void apply(WhereBuilder wb, {required bool forBooks}) {}
}

class CatOnly extends CategorySel {
  final List<int> ids;
  const CatOnly(this.ids);
  @override
  void apply(WhereBuilder wb, {required bool forBooks}) {
    if (ids.isNotEmpty) {
      final col =
          forBooks
              ? 'b.${DbConstants.BOOKS_CATEGORY_ID}'
              : 'm.${DbConstants.MATERIALS_CATEGORY_ID}';
      wb.inList(col, ids);
    }
  }
}

/// فلتر اختيار نوع الكتاب
abstract class BookTypeSel {
  const BookTypeSel();
  factory BookTypeSel.all() = BookTypeAll;
  factory BookTypeSel.only(List<int> ids) = BookTypeOnly;

  void apply(WhereBuilder wb);
}

class BookTypeAll extends BookTypeSel {
  const BookTypeAll();
  @override
  void apply(WhereBuilder wb) {}
}

class BookTypeOnly extends BookTypeSel {
  final List<int> ids;
  const BookTypeOnly(this.ids);
  @override
  void apply(WhereBuilder wb) {
    if (ids.isNotEmpty) {
      wb.inList('b.${DbConstants.BOOKS_TYPE_ID}', ids);
    }
  }
}

enum DownloadStatus {
  progress, // جاري التحميل
  downloaded, // تم التحميل
  none, // لم يتم تحميله
}

/// ترتيب عرض المواد
enum MaterialOrderBy { level, category }

enum LessonOrderBy { id, lessonNumber, name }

/// ترتيب عرض الكتب
enum BooksOrderBy { name, author, category, type }

/// ترتيب عرض التصنيفات
enum TypeOrder {
  id, // حسب الـ ID
  name, // حسب الاسم
  count, // حسب عدد العناصر (المواد/الكتب)
}

/// لبناء شروط WHERE بشكل آمن
class WhereBuilder {
  final List<String> _clauses = [];
  final List<dynamic> _args = [];

  void eq(String col, dynamic val) {
    _clauses.add('$col = ?');
    _args.add(val);
  }

  void isNull(String col) => _clauses.add('$col IS NULL');

  void notNull(String col) => _clauses.add('$col IS NOT NULL');

  void inList(String col, List<dynamic> vals) {
    if (vals.isEmpty) return;
    _clauses.add('$col IN (${vals.map((_) => '?').join(',')})');
    _args.addAll(vals);
  }

  String sql() => _clauses.isEmpty ? '' : 'WHERE ${_clauses.join(' AND ')}';

  List<dynamic> get args => _args;
}
