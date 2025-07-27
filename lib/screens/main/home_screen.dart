import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/downloader/download_provider.dart';
import 'package:alqayimm_app_flutter/screens/bookmarks/all_notes_page.dart';
import 'package:alqayimm_app_flutter/screens/bookmarks/bookmarks_screen.dart';
import 'package:alqayimm_app_flutter/screens/downloads/downloads_screen.dart';
import 'package:alqayimm_app_flutter/screens/main/institute_screen.dart';
import 'package:alqayimm_app_flutter/screens/main/search_screen.dart';
import 'package:alqayimm_app_flutter/screens/main/shik_screen.dart';
import 'package:alqayimm_app_flutter/screens/main/website_screen.dart';
import 'package:alqayimm_app_flutter/screens/settings/settings_screen.dart';
import 'package:alqayimm_app_flutter/screens/user/favorites_screen.dart';
import 'package:alqayimm_app_flutter/screens/user/user_settings_screen.dart';
import 'package:alqayimm_app_flutter/theme/util.dart' as util;
import 'package:alqayimm_app_flutter/widgets/main_bottom_nav_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

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
    logger.i('تم اختيار الصفحة: $index');
    if (_selectedIndex == index) return; // لا تفعل شيء إذا كانت الصفحة هي نفسها
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.note),
                title: const Text('العلامات المرجعية'),
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('المفضلة'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('إعدادات المستخدم'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserSettingsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('التفضيلات'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
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
          leading: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'المزيد',
            onPressed: () {
              _showMoreOptions(context);
            },
          ),
          title: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            // زر التنزيلات مع badge
            Consumer<DownloadProvider>(
              builder: (context, downloadProvider, child) {
                final activeDownloads = downloadProvider.runningDownloadsCount;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DownloadsScreen(),
                          ),
                        );
                      },
                      tooltip: 'التنزيلات',
                    ),
                    if (activeDownloads > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$activeDownloads',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (_selectedIndex == 1)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  siteScreenKey.currentState?.reloadWebView();
                },
              ),
            if (kDebugMode)
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
            AllNotesPage(),
            SiteScreen(key: siteScreenKey),
            InstituteScreen(),
            SearchScreen(),
            ShikScreen(),
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
