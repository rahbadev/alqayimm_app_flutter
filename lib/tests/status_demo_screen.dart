import 'package:alqayimm_app_flutter/screens/common/status_screens.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class StatusDemoScreen extends StatefulWidget {
  const StatusDemoScreen({super.key});

  @override
  State<StatusDemoScreen> createState() => _StatusDemoScreenState();
}

class _StatusDemoScreenState extends State<StatusDemoScreen> {
  int _selected = 0;
  int _progress = 0;
  Timer? _timer;

  void _startFakeDownload() {
    _timer?.cancel();
    setState(() => _progress = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_progress >= 100) {
        timer.cancel();
      } else {
        setState(() => _progress += 5);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget statusWidget;
    switch (_selected) {
      case 0:
        statusWidget = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Status.showProgress(progress: _progress),
            const SizedBox(height: 24),
            if (_progress == 0 || _progress == 100)
              ElevatedButton(
                onPressed: _startFakeDownload,
                child: const Text("بدء التنزيل الوهمي"),
              ),
          ],
        );
        break;
      case 1:
        statusWidget = Status.showError(
          text: "حدث خطأ أثناء الاتصال",
          subtext: "تأكد من اتصالك بالإنترنت",
          buttonText: "إعادة المحاولة",
          onTap:
              () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("إعادة المحاولة"))),
        );
        break;
      case 2:
        statusWidget = Status.showInfo(
          text: "لا توجد بيانات بعد",
          subtext: "ابدأ بإضافة أول عنصر الآن",
        );
        break;
      default:
        statusWidget = const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("تجربة Status Widget")),
      body: Center(child: statusWidget),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selected,
        onTap: (i) => setState(() => _selected = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_empty),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.error_outline),
            label: 'Error',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}
