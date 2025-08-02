import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtils {
  static SharedPreferences? _prefs;

  // Keys
  static const String _wifiWarningKey = 'wifi_warning_dont_show_again';
  static const String _appThemeModeKey = 'app_theme_mode';
  static const String _requireWiFiKey = 'require_wifi_for_downloads';

  /// تهيئة الـ SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// الحصول على instance الـ SharedPreferences
  static SharedPreferences get instance {
    assert(
      _prefs != null,
      'PreferencesUtils not initialized. Call init() first.',
    );
    return _prefs!;
  }

  // WiFi Settings
  static Future<void> setRequireWiFi(bool value) =>
      instance.setBool(_requireWiFiKey, value);

  static bool get requireWiFi => instance.getBool(_requireWiFiKey) ?? true;

  // WiFi Warning
  static Future<void> setWifiWarningDontShowAgain(bool value) =>
      instance.setBool(_wifiWarningKey, value);

  static bool get wifiWarningDontShowAgain =>
      instance.getBool(_wifiWarningKey) ?? false;

  // Theme Mode
  static Future<void> setAppThemeMode(int modeIndex) =>
      instance.setInt(_appThemeModeKey, modeIndex);

  static int get appThemeMode => instance.getInt(_appThemeModeKey) ?? 0;
}
