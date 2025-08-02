import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/utils/preferences_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alqayimm_app_flutter/downloader/download_provider.dart';
import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/utils/file_utils.dart';

class DownloaderTestScreen extends StatefulWidget {
  const DownloaderTestScreen({super.key});

  @override
  State<DownloaderTestScreen> createState() => _DownloaderTestScreenState();
}

class _DownloaderTestScreenState extends State<DownloaderTestScreen> {
  // استخدم عنصر وهمي للاختبار (مثلاً كتاب أو درس)
  BaseContentModel? testItem;
  bool isLoading = true;

  String fileStatus = '';
  String dbStatus = '';

  bool wifiOnly = PreferencesUtils.requireWiFi;

  @override
  void initState() {
    super.initState();
    _initItem();
  }

  Future<void> _initItem() async {
    final db = await DbHelper.database;
    final repo = Repo(db);
    final lesson = await repo.getLessonById(2);
    setState(() {
      testItem = lesson?.copyWith(
        url:
            'https://mmatechnical.com/Download/Download-Test-File/(MMA)-50GB.zip',
      );
      isLoading = false;
    });
  }

  Future<void> _downloadFile(BuildContext context) async {
    await Provider.of<DownloadProvider>(
      context,
      listen: false,
    ).startDownload(context, testItem!);
  }

  Future<void> _checkFileExists() async {
    final exists = await FileUtils.isItemFileExists(testItem!);
    setState(() {
      fileStatus = exists ? 'الملف موجود في الذاكرة' : 'الملف غير موجود';
    });
  }

  Future<void> _checkDbStatus(BuildContext context) async {
    final info = Provider.of<DownloadProvider>(
      context,
      listen: false,
    ).getDownloadInfo(testItem!);
    setState(() {
      dbStatus =
          info == null
              ? 'لا يوجد سجل في قاعدة البيانات'
              : (info.taskStatusUpdate.status.isFinalState
                  ? 'مكتمل'
                  : 'غير مكتمل (${info.taskStatusUpdate.status.name})');
    });
  }

  Future<void> _removeFromDb(BuildContext context) async {
    final info = Provider.of<DownloadProvider>(
      context,
      listen: false,
    ).getDownloadInfo(testItem!);
    if (info != null) {
      await Provider.of<DownloadProvider>(
        context,
        listen: false,
      ).removeDownload(testItem!, removeFile: false);
      setState(() {
        dbStatus = 'تم الحذف من قاعدة البيانات';
      });
    }
  }

  Future<void> _removeFileOnly() async {
    final success = await FileUtils.deleteItemFile(testItem!);
    setState(() {
      fileStatus = success ? 'تم حذف الملف من الذاكرة' : 'فشل في حذف الملف';
    });
  }

  Future<void> _forceDownload(BuildContext context) async {
    await Provider.of<DownloadProvider>(
      context,
      listen: false,
    ).startDownload(context, testItem!, forceDownload: true);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || testItem == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار التنزيل'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Switch WiFi Only
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'التنزيل عبر الوايفاي فقط',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: wifiOnly,
                  onChanged: (value) async {
                    setState(() => wifiOnly = value);
                    await PreferencesUtils.setRequireWiFi(value);
                    await Provider.of<DownloadProvider>(
                      context,
                      listen: false,
                    ).setGlobalRequireWiFi(value);
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Status Cards
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'حالة الملف:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(fileStatus.isEmpty ? 'غير محدد' : fileStatus),
                  ],
                ),
              ),
            ),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.storage_outlined,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'حالة قاعدة البيانات:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(dbStatus.isEmpty ? 'غير محدد' : dbStatus),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  Consumer<DownloadProvider>(
                    builder: (context, downloadProvider, child) {
                      downloadProvider.getDownloadInfo(testItem!);
                      final downloadInfo = downloadProvider.getDownloadInfo(
                        testItem!,
                      );
                      final downloadStatus = downloadInfo?.downloadStatus;

                      return _buildActionButton(
                        icon:
                            downloadStatus == DownloadStatus.progress
                                ? Icons.pause
                                : Icons.download,
                        label:
                            downloadStatus == DownloadStatus.progress
                                ? 'إيقاف التنزيل'
                                : 'تنزيل',
                        color: Colors.blue,
                        onPressed:
                            () =>
                                downloadStatus == DownloadStatus.progress
                                    ? downloadProvider.pauseDownload(
                                      downloadInfo!,
                                    )
                                    : _downloadFile(context),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'تحديث الحالة',
                    color: Colors.orange,
                    onPressed: () {
                      _checkFileExists();
                      _checkDbStatus(context);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.download_for_offline,
                    label: 'إعادة تنزيل',
                    color: Colors.green,
                    onPressed: () => _forceDownload(context),
                  ),
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    label: 'حذف من الذاكرة',
                    color: Colors.red,
                    onPressed: _removeFileOnly,
                  ),
                  _buildActionButton(
                    icon: Icons.clear_all,
                    label: 'حذف من قاعدة البيانات',
                    color: Colors.purple,
                    onPressed: () => _removeFromDb(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
