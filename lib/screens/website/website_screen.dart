import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';
// أنشئ logger خاص بك

class SiteScreen extends StatefulWidget {
  const SiteScreen({super.key});

  @override
  State<SiteScreen> createState() => SiteScreenState();
}

class SiteScreenState extends State<SiteScreen>
    with AutomaticKeepAliveClientMixin {
  late final WebViewController controller;
  double _progress = 0.0;
  bool _hasError = false;

  void reloadWebView() {
    setState(() {
      _hasError = false;
    });
    controller.reload();
  }

  @override
  void initState() {
    super.initState();
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (progress) {
                setState(() {
                  _progress = progress / 100.0;
                });
              },
              onPageStarted: (url) {
                // setState(() {
                //   _hasError = false;
                // });
                // logger.info('بدأ تحميل الصفحة: $url');
              },
              onPageFinished: (url) {
                // setState(() {
                //   _hasError = false;
                // });
                // logger.info('تم تحميل الصفحة: $url');
              },
              onWebResourceError: (error) {
                // setState(() {
                //   _hasError = true;
                // });
                // logger.severe('خطأ في تحميل المورد: ${error.toString()}');
              },
            ),
          )
          ..loadRequest(Uri.parse('https://www.alqayim.org/'));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        if (_progress < 1.0)
          LinearProgressIndicator(value: _progress, minHeight: 3),
        Expanded(
          child:
              _hasError
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/lottie/no_network.json',
                          width: 300,
                          repeat: true,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'لا يوجد اتصال بالإنترنت',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                          onPressed: reloadWebView,
                        ),
                      ],
                    ),
                  )
                  : WebViewWidget(controller: controller),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
