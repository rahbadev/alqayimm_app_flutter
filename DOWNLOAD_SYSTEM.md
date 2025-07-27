# نظام التنزيل باستخدام Background Downloader

## نظرة عامة

تم تطوير نظام تنزيل متكامل للتطبيق باستخدام مكتبة `background_downloader` مع ميزات متقدمة لإدارة التنزيلات.

## الميزات المطورة

### 1. إدارة التنزيلات المتقدمة
- **تنزيل في الخلفية**: التنزيلات تستمر حتى لو أغلق المستخدم التطبيق
- **استئناف التنزيل**: إمكانية استئناف التنزيلات المنقطعة
- **إيقاف مؤقت**: إيقاف وتشغيل التنزيلات حسب الحاجة
- **إعادة المحاولة**: إعادة المحاولة التلقائية في حالة الفشل

### 2. واجهات مستخدم محسنة
- **مؤشرات تقدم مرئية**: عرض نسبة التقدم والوقت المتبقي
- **تنبيهات دائمة**: عرض التنزيلات النشطة في أسفل الشاشة
- **شاشة إدارة منفصلة**: شاشة مخصصة لعرض وإدارة جميع التنزيلات

### 3. إدارة الملفات الذكية
- **هيكل منظم**: تنظيم الملفات في مجلدات محددة
- **فحص التكرار**: منع تنزيل الملفات المكررة
- **إدارة المساحة**: فحص المساحة المتاحة قبل التنزيل

### 4. إعدادات شبكة ذكية
- **تحذير البيانات**: تحذير المستخدم عند استخدام بيانات الجوال
- **خيارات المتابعة**: إمكانية تجاهل التحذيرات للمرة القادمة

## بنية الملفات

```
lib/
├── utils/
│   ├── download_manager.dart          # مدير التنزيلات الأساسي
│   └── preferences_utils.dart         # إدارة إعدادات المستخدم
├── providers/
│   └── download_provider.dart         # Provider لإدارة حالة التنزيلات
├── widgets/
│   ├── download/
│   │   ├── download_status_widgets.dart    # widgets لعرض حالة التنزيل
│   │   └── global_download_indicator.dart  # مؤشر التنزيلات العام
│   └── dialogs/
│       └── wifi_warning_dialog.dart    # حوار تحذير الواي فاي
└── screens/
    └── downloads/
        └── downloads_management_screen.dart  # شاشة إدارة التنزيلات
```

## كيفية الاستخدام

### إعداد البيئة

```dart
// في main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => DownloadProvider()),
  ],
  child: MaterialApp(
    home: GlobalDownloadIndicator(
      child: YourHomeScreen(),
    ),
  ),
)
```

### بدء تنزيل

```dart
// في أي شاشة
final downloadProvider = context.read<DownloadProvider>();
await downloadProvider.startDownload(context, item);
```

### مراقبة التنزيلات

```dart
// استخدام Consumer للمراقبة المباشرة
Consumer<DownloadProvider>(
  builder: (context, downloadProvider, child) {
    final status = downloadProvider.getDownloadStatus(item);
    return DownloadStatusWidget(status: status);
  },
)
```

### إدارة التنزيلات

```dart
// إيقاف مؤقت
await downloadProvider.pauseDownload(taskId);

// استئناف
await downloadProvider.resumeDownload(taskId);

// إلغاء
await downloadProvider.cancelDownload(context, taskId);
```

## هيكل تخزين الملفات

```
Documents/downloaded_files/
├── lessons/
│   └── [material_name]/
│       └── [material_name]_[lesson_number].mp3
└── books/
    └── [book_title].pdf
```

## الكلاسات الرئيسية

### 1. DownloadManager
- **المسؤولية**: إدارة التنزيلات على مستوى النظام
- **الميزات**: 
  - تهيئة background_downloader
  - إدارة callbacks
  - فحص الاتصال والمساحة
  - إنشاء مهام التنزيل

### 2. DownloadProvider
- **المسؤولية**: إدارة حالة التنزيلات في UI
- **الميزات**:
  - ربط UI بـ DownloadManager
  - إدارة حالة التنزيلات
  - عرض الرسائل والحوارات

### 3. DownloadTaskInfo
- **المسؤولية**: تخزين معلومات مهمة التنزيل
- **البيانات**: التقدم، السرعة، الوقت المتبقي، حالة المهمة

## الاستخدام المتقدم

### تخصيص إعدادات التنزيل

```dart
final task = DownloadTask(
  url: fileUrl,
  filename: fileName,
  directory: customDirectory,
  allowPause: true,
  retries: 3,
  requiresWiFi: false,
);
```

### مراقبة التقدم

```dart
downloadProvider.downloadUpdates.listen((update) {
  print('Progress: ${update.progress}');
  print('Speed: ${update.networkSpeed}');
  print('Time remaining: ${update.timeRemaining}');
});
```

### إدارة الأخطاء

```dart
final result = await downloadProvider.startDownload(context, item);
if (!result.success) {
  // التعامل مع الخطأ
  showErrorDialog(result.message);
}
```

## التحسينات المستقبلية

1. **تنزيل متوازي**: دعم تنزيل أجزاء متعددة من ملف واحد
2. **ضغط الملفات**: ضغط الملفات المنزلة لتوفير المساحة
3. **مزامنة السحابة**: مزامنة التنزيلات مع خدمات السحابة
4. **جدولة التنزيل**: تحديد أوقات معينة للتنزيل
5. **تنزيل بالدفعات**: تنزيل مجموعات من الملفات معاً

## ملاحظات مهمة

- تأكد من إضافة الصلاحيات المطلوبة في `AndroidManifest.xml`
- اختبر التنزيلات على شبكات مختلفة
- راقب استهلاك البطارية والذاكرة
- احرص على معالجة جميع حالات الخطأ

## الدعم والمساعدة

للمزيد من المعلومات حول `background_downloader`:
- [التوثيق الرسمي](https://pub.dev/packages/background_downloader)
- [أمثلة الاستخدام](https://github.com/781flyingdutchman/background_downloader/tree/main/example)
