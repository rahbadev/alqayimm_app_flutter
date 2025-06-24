import 'package:alqayimm_app_flutter/db/main/enums.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/models/main_db/lesson_model.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/utils/app_icons.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';
import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:alqayimm_app_flutter/widget/lists/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:alqayimm_app_flutter/widget/icons/animated_icon.dart';

class LessonsListScreen extends StatefulWidget {
  final String title;
  final int? materialId;
  final int? authorId;
  final int? levelId;
  final int? categoryId;

  const LessonsListScreen({
    super.key,
    required this.title,
    this.materialId,
    this.authorId,
    this.levelId,
    this.categoryId,
  });

  @override
  State<LessonsListScreen> createState() => _LessonsListScreenState();

  static void navigateToScreen({
    required BuildContext context,
    required String title,
    int? materialId,
    int? authorId,
    int? levelId,
    int? categoryId,
  }) {
    Navigator.push(
      context,
      fadeSlideRoute(
        LessonsListScreen(
          title: title,
          materialId: materialId,
          authorId: authorId,
          levelId: levelId,
          categoryId: categoryId,
        ),
      ),
    );
  }
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  late Future<List<LessonModel>> _lessonsFuture;
  List<LessonModel>? _lessons;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = _fetchLessons();
  }

  Future<List<LessonModel>> _fetchLessons() async {
    final db = await DbHelper.database;
    final repo = Repo(db);
    final lessons = await repo.fetchLessons(
      materialId: widget.materialId,
      authorId: widget.authorId,
      levelId: widget.levelId,
      categoryId: widget.categoryId,
    );
    _lessons = lessons;
    print('تم جلب ${lessons.length} دروس من قاعدة البيانات');
    return lessons;
  }

  MainItem _buildLessonItem(LessonModel lesson, int index) {
    final authorName = lesson.authorName?.trim();
    final categoryName = lesson.categoryName?.trim();
    return MainItem(
      title: lesson.name,
      leadingContent: IconLeading(icon: AppIcons.lessonItem),
      details: [
        if (categoryName != null && categoryName.isNotEmpty)
          MainItemDetail(
            text: 'التصنيف: $categoryName',
            icon: Icons.category,
            iconColor: Colors.blue,
            onTap:
                (item) => Fluttertoast.showToast(msg: 'التصنيف: $categoryName'),
          ),
        if (authorName != null && authorName.isNotEmpty)
          MainItemDetail(
            text: 'المعلم: $authorName',
            icon: Icons.person,
            iconColor: Colors.teal,
            onTap: (item) => Fluttertoast.showToast(msg: 'المعلم: $authorName'),
          ),
      ],
      onItemTap: (item) {
        Fluttertoast.showToast(msg: lesson.name);
      },
      actions: _buildActionButtons(lesson, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: MainItemsListView<LessonModel>(
        itemsFuture: _lessonsFuture,
        itemBuilder: (lesson, index) => _buildLessonItem(lesson, index),
        titleFontSize: 20,
      ),
    );
  }

  Future<void> _downloadLesson(int? index) async {
    if (index == null ||
        _lessons == null ||
        index < 0 ||
        index >= _lessons!.length) {
      Fluttertoast.showToast(msg: 'خطأ في تحميل الدرس');
      return;
    }
    setState(() {
      _lessons![index] = _lessons![index].copyWith(
        downloadStatus: DownloadStatus.downloading,
      );
    });
    await Future.delayed(const Duration(seconds: 4)); // محاكاة التنزيل
    setState(() {
      _lessons![index] = _lessons![index].copyWith(
        downloadStatus: DownloadStatus.downloaded,
      );
    });
    Fluttertoast.showToast(msg: 'تم التنزيل');
  }

  Future<void> _deleteLesson(int? index) async {
    if (index == null ||
        _lessons == null ||
        index < 0 ||
        index >= _lessons!.length) {
      Fluttertoast.showToast(msg: 'خطأ في حذف الدرس');
      return;
    }
    setState(() {
      _lessons![index] = _lessons![index].copyWith(
        downloadStatus: DownloadStatus.notDownloaded,
      );
    });
    Fluttertoast.showToast(msg: 'تم الحذف');
  }

  Future<void> _toggleComplete(int? index) async {
    if (index == null ||
        _lessons == null ||
        index < 0 ||
        index >= _lessons!.length)
      return;
    setState(() {
      _lessons![index] = _lessons![index].copyWith(
        isCompleted: !_lessons![index].isCompleted,
      );
    });
    Fluttertoast.showToast(
      msg: _lessons![index].isCompleted ? 'تم الإكمال' : 'لم يتم الإكمال',
    );
  }

  Future<void> _toggleFavorite(int? index) async {
    if (index == null ||
        _lessons == null ||
        index < 0 ||
        index >= _lessons!.length)
      return;
    setState(() {
      _lessons![index] = _lessons![index].copyWith(
        isFavorite: !_lessons![index].isFavorite,
      );
    });
    Fluttertoast.showToast(
      msg:
          _lessons![index].isFavorite
              ? 'تمت الإضافة للمفضلة'
              : 'تمت الإزالة من المفضلة',
    );
  }

  List<ActionButton> _buildActionButtons(LessonModel lesson, int? index) {
    List<ActionButton> actions = [];

    // زر التنزيل/التحميل/الحذف مع حركة AnimatedIconSwitcher
    actions.add(
      ActionButton(
        buttonWidget: AnimatedIconSwitcher(
          icon: () {
            switch (lesson.downloadStatus) {
              case DownloadStatus.notDownloaded:
                return Icon(AppIcons.download, key: const ValueKey('download'));
              case DownloadStatus.downloading:
                return SizedBox(
                  key: const ValueKey('progress'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.teal,
                    ),
                  ),
                );
              case DownloadStatus.downloaded:
                return Icon(AppIcons.delete, key: const ValueKey('delete'));
              default:
                return Icon(AppIcons.download, key: const ValueKey('download'));
            }
          }(),
        ),
        tooltip: () {
          switch (lesson.downloadStatus) {
            case DownloadStatus.notDownloaded:
              return 'تنزيل';
            case DownloadStatus.downloading:
              return 'جار التنزيل';
            case DownloadStatus.downloaded:
              return 'حذف';
            default:
              return '';
          }
        }(),
        onTap: (item) {
          switch (lesson.downloadStatus) {
            case DownloadStatus.notDownloaded:
              _downloadLesson(index);
              break;
            case DownloadStatus.downloading:
              // لا شيء أو يمكنك إضافة إلغاء التنزيل
              break;
            case DownloadStatus.downloaded:
              _deleteLesson(index);
              break;
            default:
              break;
          }
        },
      ),
    );

    // مشاركة
    actions.add(
      ActionButton(
        buttonWidget: const Icon(AppIcons.share),
        tooltip: 'مشاركة',
        onTap: (item) {
          Fluttertoast.showToast(msg: 'تم المشاركة');
        },
      ),
    );

    // فتح باستخدام
    actions.add(
      ActionButton(
        buttonWidget: const Icon(AppIcons.openInNew),
        tooltip: 'فتح باستخدام',
        onTap: (item) {
          Fluttertoast.showToast(msg: 'فتح باستخدام...');
        },
      ),
    );

    // تم الإكمال ولم يتم الإكمال (AnimatedIconSwitcher)
    actions.add(
      ActionButton(
        buttonWidget: AnimatedIconSwitcher(
          icon: Icon(
            lesson.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            key: ValueKey(lesson.isCompleted),
            color: lesson.isCompleted ? Colors.green : null,
          ),
        ),
        tooltip: lesson.isCompleted ? 'تم الإكمال' : 'لم يتم الإكمال',
        onTap: (item) => _toggleComplete(index),
      ),
    );

    // أكشن المفضلة (AnimatedIconSwitcher)
    actions.add(
      ActionButton(
        buttonWidget: AnimatedIconSwitcher(
          icon: Icon(
            lesson.isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(lesson.isFavorite),
            color: lesson.isFavorite ? Colors.red : null,
          ),
        ),
        tooltip: lesson.isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
        onTap: (item) => _toggleFavorite(index),
      ),
    );

    // عناصر مرتبطة
    actions.add(
      ActionButton(
        buttonWidget: const Icon(Icons.link),
        tooltip: 'عناصر مرتبطة',
        onTap: (item) {
          Fluttertoast.showToast(msg: 'عرض العناصر المرتبطة');
        },
      ),
    );

    return actions;
  }
}
