class UserDbQueries {
  // بيانات وهمية لمحاكاة قاعدة بيانات المستخدم
  static Future<int> getMaterialsCountForLevel(int levelId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return levelId * 3; // مثال: كل مستوى يحتوي على 3 مواد
  }

  static Future<double> getCompletionPercentage(int levelId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return levelId * 0.25; // مثال: 25% لكل مستوى
  }

  static Future<String> getLastPlayedMaterial(int levelId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'الدرس ${levelId * 2}'; // مثال: آخر درس هو ضعف رقم المستوى
  }
}
