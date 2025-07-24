import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtils {
  static SharedPreferences? _prefs;

  /// key لتفضيلات عدم الإظهار مرة أخرى للواي فاي
  static const String _wifiWarningKey = 'wifi_warning_dont_show_again';

  /// تهيئة الـ preferences مرة واحدة فقط
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// getter عام للوصول للـ prefs
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('PreferencesUtils not initialized. Call init() first.');
    }
    return _prefs!;
  }

  /// مثال: حفظ قيمة
  static Future<void> _setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  /// مثال: قراءة قيمة
  static bool _getBool(String key, {bool defaultValue = false}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  /// حفظ اختيار عدم إظهار تحذير الواي فاي مرة أخرى
  static Future<void> setWifiWarningDontShowAgain(bool value) async {
    await _setBool(_wifiWarningKey, value);
  }
}
