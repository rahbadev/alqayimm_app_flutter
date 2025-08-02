import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/downloader/download_provider.dart';
import 'package:alqayimm_app_flutter/screens/main/home_screen.dart';
import 'package:alqayimm_app_flutter/screens/main/website_screen.dart';
import 'package:alqayimm_app_flutter/test/downloader_test_screen.dart';
import 'package:alqayimm_app_flutter/utils/app_strings.dart';
import 'package:alqayimm_app_flutter/theme/theme.dart';
import 'package:alqayimm_app_flutter/theme/util.dart';
import 'package:alqayimm_app_flutter/utils/preferences_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

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
final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PreferencesUtils.init();

  await DbHelper.database;

  final downloadProvider = DownloadProvider();
  await downloadProvider.initialize();

  // استرجاع اختيار المستخدم
  final savedMode = PreferencesUtils.appThemeMode;
  themeModeNotifier.value = ThemeMode.values[savedMode];
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: downloadProvider)],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String fontName = "Tajawal";
    TextTheme textTheme = createTextTheme(context, fontName, fontName);
    MaterialTheme theme = MaterialTheme(textTheme);

    return ToastificationWrapper(
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) {
          return MaterialApp(
            theme: theme.light(),
            darkTheme: theme.dark(),
            navigatorObservers: [routeObserver],
            themeMode: mode,
            debugShowCheckedModeBanner: false,
            navigatorKey: globalNavigatorKey,
            home: const MyHomePage(title: AppStrings.appTitle),
            // home: const DownloaderTestScreen(),
            locale: const Locale('ar'),
            supportedLocales: const [
              Locale('ar'), // يمكنك إضافة لغات أخرى إذا أردت
            ],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          );
        },
      ),
    );
  }
}
