import 'package:flutter/material.dart';
import '../../main.dart'; // استورد الـ themeModeNotifier
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppThemeMode _themeMode = AppThemeMode.system;

  @override
  void initState() {
    super.initState();
    // مزامنة الوضع الحالي مع ValueNotifier
    final current = themeModeNotifier.value;
    if (current == ThemeMode.light) {
      _themeMode = AppThemeMode.light;
    } else if (current == ThemeMode.dark) {
      _themeMode = AppThemeMode.dark;
    } else {
      _themeMode = AppThemeMode.system;
    }
  }

  Future<void> _changeTheme(AppThemeMode? mode) async {
    if (mode == null) return;
    setState(() => _themeMode = mode);
    switch (mode) {
      case AppThemeMode.system:
        themeModeNotifier.value = ThemeMode.system;
        break;
      case AppThemeMode.light:
        themeModeNotifier.value = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        themeModeNotifier.value = ThemeMode.dark;
        break;
    }
    // حفظ الاختيار
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', mode.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'المظهر',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                RadioListTile<AppThemeMode>(
                  title: const Text('حسب النظام'),
                  value: AppThemeMode.system,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                ),
                RadioListTile<AppThemeMode>(
                  title: const Text('نهاري'),
                  value: AppThemeMode.light,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                ),
                RadioListTile<AppThemeMode>(
                  title: const Text('ليلي'),
                  value: AppThemeMode.dark,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
