/// نتيجة عملية التنزيل
class DownloadResult {
  final bool success;
  final String? message;
  final String? taskId;
  final String? filePath;

  const DownloadResult({
    required this.success,
    this.message,
    this.taskId,
    this.filePath,
  });

  factory DownloadResult.started(String taskId) =>
      DownloadResult(success: true, taskId: taskId);

  factory DownloadResult.alreadyExists() =>
      DownloadResult(success: true, message: 'الملف موجود بالفعل');

  factory DownloadResult.error(String message) =>
      DownloadResult(success: false, message: message);
}
