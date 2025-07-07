import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/screens/main/home_screen.dart';
import 'package:alqayimm_app_flutter/screens/main/website_screen.dart';
import 'package:alqayimm_app_flutter/utils/app_strings.dart';
import 'package:alqayimm_app_flutter/theme/theme.dart';
import 'package:alqayimm_app_flutter/theme/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTime,
  ),
);
final GlobalKey<SiteScreenState> siteScreenKey = GlobalKey<SiteScreenState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DbHelper.database; // فتح القاعدة هنا
  // استرجاع اختيار المستخدم
  final prefs = await SharedPreferences.getInstance();
  final savedMode = prefs.getInt('themeMode');
  if (savedMode != null) {
    themeModeNotifier.value = ThemeMode.values[savedMode];
  }
  runApp(const MyApp());
  logger.i('تطبيق الدين القيم بدأ التشغيل');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String fontName = "Tajawal";
    TextTheme textTheme = createTextTheme(context, fontName, fontName);
    MaterialTheme theme = MaterialTheme(textTheme);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          theme: theme.light(),
          darkTheme: theme.dark(),
          navigatorObservers: [routeObserver],
          themeMode: mode, // هنا الربط الفعلي
          debugShowCheckedModeBanner: false,
          home: const MyHomePage(title: AppStrings.appTitle),
          locale: const Locale('ar'), // اجعل اللغة الافتراضية عربية
          supportedLocales: const [
            Locale('ar'), // يمكنك إضافة لغات أخرى إذا أردت
          ],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        );
      },
    );
  }
}
