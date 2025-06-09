import 'package:alqayimm_app_flutter/db/db_helper.dart';
import 'package:alqayimm_app_flutter/screens/main/site_screen.dart';
import 'package:alqayimm_app_flutter/app_strings.dart';
import 'package:alqayimm_app_flutter/theme/theme.dart';
import 'package:alqayimm_app_flutter/theme/util.dart';
import 'package:alqayimm_app_flutter/theme/util.dart' as util;
import 'package:alqayimm_app_flutter/widget/main_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/screens/main/bookmarks_screen.dart';
import 'package:alqayimm_app_flutter/screens/main/home_screen.dart';
import 'package:alqayimm_app_flutter/screens/main/search_screen.dart';
import 'package:alqayimm_app_flutter/screens/main/shik_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logging/logging.dart';
import 'package:alqayimm_app_flutter/screens/main/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
final Logger logger = Logger('alqayimm_app');
final GlobalKey<SiteScreenState> siteScreenKey = GlobalKey<SiteScreenState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.database; // فتح القاعدة هنا
  // استرجاع اختيار المستخدم
  final prefs = await SharedPreferences.getInstance();
  final savedMode = prefs.getInt('themeMode');
  if (savedMode != null) {
    themeModeNotifier.value = ThemeMode.values[savedMode];
  }
  // إعدادات logger: أظهر فقط الرسائل من نوع info وما فوق
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('[${record.level.name}] ${record.loggerName}: ${record.message}');
  });
  runApp(const MyApp());
  logger.info('تطبيق الدين القيم بدأ التشغيل');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(
      context,
      "IBM Plex Sans Arabic",
      "IBM Plex Sans Arabic",
    );
    MaterialTheme theme = MaterialTheme(textTheme);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          theme: theme.light(),
          darkTheme: theme.dark(),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 2;
  late final PageController _pageController;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    logger.info('تم اختيار الصفحة: $index');
    if (_selectedIndex == index) return; // لا تفعل شيء إذا كانت الصفحة هي نفسها
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // حتى تتحكم أنت في السلوك
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // إذا كنت في صفحة الموقع
        if (_selectedIndex == 3) {
          final canGoBack =
              await siteScreenKey.currentState?.controller.canGoBack() ?? false;
          if (canGoBack) {
            siteScreenKey.currentState?.controller.goBack();
            return;
          }
        }
        // إذا لم تكن في الصفحة الرئيسية
        if (_selectedIndex != 2) {
          setState(() {
            _selectedIndex = 2;
            _pageController.jumpToPage(2);
          });
          return;
        }
        // إذا كنت في الصفحة الرئيسية
        DateTime now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          Fluttertoast.showToast(
            msg: "إضغط مرة أخرى للخروج من التطبيق",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          return;
        }
        await SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            if (_selectedIndex == 3)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  siteScreenKey.currentState?.reloadWebView();
                },
              ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              tooltip: 'الإعدادات',
            ),
            IconButton(
              icon: const Icon(Icons.nightlight),
              onPressed: () {
                util.toggleThemeMode();
              },
              tooltip: 'الإعدادات',
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // يمنع السحب باليد
          children: [
            ShikScreen(),
            SiteScreen(key: siteScreenKey),
            HomeScreen(),
            SearchScreen(),
            BookmarksScreen(),
          ],
        ),
        bottomNavigationBar: MainBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
