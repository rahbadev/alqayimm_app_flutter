/// كلاس لمحاكاة استعلامات قاعدة بيانات المستخدم (وهمية لأغراض العرض)
class UserDbQueries {
  /// جلب عدد المواد لمستوى معين (محاكاة)
  static Future<int> getMaterialsCountForLevel(int levelId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return levelId * 3; // مثال: كل مستوى يحتوي على 3 مواد
  }

  /// جلب نسبة الإنجاز لمستوى معين (محاكاة)
  static Future<double> getCompletionPercentage(int levelId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return levelId * 0.25; // مثال: 25% لكل مستوى
  }

  /// جلب آخر مادة تم تشغيلها في مستوى معين (محاكاة)
  static Future<String> getLastPlayedMaterial(int levelId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'الدرس ${levelId * 2}'; // مثال: آخر درس هو ضعف رقم المستوى
  }
}
