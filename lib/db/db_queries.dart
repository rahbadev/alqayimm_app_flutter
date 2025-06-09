import 'package:alqayimm_app_flutter/db/models/type_model.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:sqflite/sqflite.dart';
import 'db_constants.dart';

class DbQueries {
  final Database db;

  DbQueries(this.db);

  // جلب جميع المستويات (levels)
  Future<List<Map<String, dynamic>>> getLevels() async {
    final result = await db.rawQuery(
      "SELECT id, name, group_name FROM ${DbConstants.TYPES_TABLE} WHERE group_name = ?",
      ['المستويات'], // أو القيمة المناسبة في قاعدة بياناتك
    );
    return result;
  }

  // جلب جميع الأنواع حسب المجموعة (مستوى أو تصنيف)
  Future<List<TypeModel>> getTypesByGroup(String groupName) async {
    final result = await db.rawQuery(
      "SELECT id, name, group_name FROM ${DbConstants.TYPES_TABLE} WHERE group_name = ?",
      [groupName],
    );
    return result.map((e) => TypeModel.fromMap(e)).toList();
  }

  // جلب عدد المواد المرتبطة بنوع (type) معيّن
  Future<int> getSubjectsCountForType(int typeId) async {
    logger.info('Fetching subjects count for type ID: $typeId');
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM subjects_types_table
      WHERE type_id = ?
      ''',
      [typeId],
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    logger.info('Count of subjects for type ID $typeId: $count');
    return count;
  }

  // جلب آخر مادة أو عنصر تم تشغيله (تعديل لاحقًا حسب قاعدة المستخدم)
  Future<String?> getLastPlayedForType(int typeId) async {
    // هنا من المفترض أن تربط مع جدول history أو progress لاحقًا
    // الآن فقط بيانات شكلية
    return null;
  }

  // جلب عدد المواد المنتهية (تعديل لاحقًا حسب قاعدة المستخدم)
  Future<int> getFinishedSubjectsForType(int typeId) async {
    // هنا من المفترض أن تربط مع جدول progress لاحقًا
    // الآن فقط بيانات شكلية
    return 0;
  }
}
