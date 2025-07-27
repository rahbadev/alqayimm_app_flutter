import 'package:flutter_test/flutter_test.dart';
import 'package:alqayimm_app_flutter/downloader/download_manager.dart';
import 'package:alqayimm_app_flutter/downloader/download_provider.dart';

void main() {
  group('Download System Tests', () {
    test('DownloadManager singleton should work', () {
      final manager1 = DownloadManager.instance;
      final manager2 = DownloadManager.instance;
      expect(identical(manager1, manager2), isTrue);
    });

    test('DownloadProvider should initialize correctly', () {
      final provider = DownloadProvider();
      expect(provider, isNotNull);
    });

    testWidgets('DownloadProvider should exist and be testable', (
      WidgetTester tester,
    ) async {
      final provider = DownloadProvider();
      expect(provider, isNotNull);
    });
  });
}
