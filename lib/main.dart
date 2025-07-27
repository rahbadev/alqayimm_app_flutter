import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/downloader/download_provider.dart';
import 'package:alqayimm_app_flutter/screens/main/home_screen.dart';
import 'package:alqayimm_app_flutter/screens/main/website_screen.dart';
import 'package:alqayimm_app_flutter/tests/test_downloader_screen.dart';
import 'package:alqayimm_app_flutter/utils/app_strings.dart';
import 'package:alqayimm_app_flutter/theme/theme.dart';
import 'package:alqayimm_app_flutter/theme/util.dart';
import 'package:alqayimm_app_flutter/utils/preferences_utils.dart';
import 'package:alqayimm_app_flutter/widgets/download/global_download_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

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

  await DbHelper.database;

  final downloadProvider = DownloadProvider();
  await downloadProvider.initialize();

  await PreferencesUtils.init();

  // استرجاع اختيار المستخدم
  final savedMode = PreferencesUtils.getAppThemeMode();
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

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          theme: theme.light(),
          darkTheme: theme.dark(),
          navigatorObservers: [routeObserver],
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          home: GlobalDownloadIndicator(
            child: const MyHomePage(title: AppStrings.appTitle),
            // child: const TestDownloaderScreen(),
          ),
          locale: const Locale('ar'),
          supportedLocales: const [
            Locale('ar'), // يمكنك إضافة لغات أخرى إذا أردت
          ],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        );
      },
    );
  }
}
