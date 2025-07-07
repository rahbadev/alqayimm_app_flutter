import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/widget/dialogs/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:alqayimm_app_flutter/screens/player/audio_player_screen.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/widget/cards.dart';
import 'package:alqayimm_app_flutter/widget/icons.dart';
import 'package:alqayimm_app_flutter/widget/main_items_list.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ScreenType { books, lessons }

class LessonsBooksScreen extends StatefulWidget {
  final ScreenType screenType;
  final String title;
  final int? authorId;
  final int? materialId;
  final int? levelId;
  final int? categoryId;
  final CategorySel? categorySel;
  final BookTypeSel? bookTypeSel;

  const LessonsBooksScreen({
    super.key,
    required this.screenType,
    required this.title,
    this.authorId,
    this.materialId,
    this.levelId,
    this.categoryId,
    this.categorySel,
    this.bookTypeSel,
  });

  @override
  State<LessonsBooksScreen> createState() => _LessonsBooksScreenState();

  /// استخدم هذه الدالة للتنقل إلى الشاشة
  static void navigateToScreen({
    required BuildContext context,
    required ScreenType screenType,
    required String title,
    int? authorId,
    int? materialId,
    int? levelId,
    int? categoryId,
    CategorySel? categorySel,
    BookTypeSel? bookTypeSel,
  }) {
    Navigator.push(
      context,
      fadeSlideRoute(
        LessonsBooksScreen(
          screenType: screenType,
          title: title,
          authorId: authorId,
          materialId: materialId,
          levelId: levelId,
          categoryId: categoryId,
          categorySel: categorySel,
          bookTypeSel: bookTypeSel,
        ),
      ),
    );
  }
}

class _LessonsBooksScreenState extends State<LessonsBooksScreen> {
  late Future<List<dynamic>> _itemsFuture;
  List<dynamic>? _items;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _fetchItems();
  }

  Future<List<dynamic>> _fetchItems() async {
    final db = await DbHelper.database;
    final repo = Repo(db);

    if (widget.screenType == ScreenType.books) {
      final books = await repo.fetchBooks(
        authorId: widget.authorId,
        categorySel: widget.categorySel ?? CategorySel.all(),
        bookTypeSel: widget.bookTypeSel ?? BookTypeSel.all(),
      );
      _items = books;
      return books;
    } else {
      final lessons = await repo.fetchLessons(
        materialId: widget.materialId,
        authorId: widget.authorId,
        levelId: widget.levelId,
        categoryId: widget.categoryId,
      );
      // جلب حالات المستخدم
      final userStatuses = await UserItemStatusRepository.getItems(
        itemType: ItemType.lesson,
      );
      final statusMap = {for (var s in userStatuses) s.itemId: s};
      final mergedLessons =
          lessons.map((lesson) {
            final status = statusMap[lesson.id];
            return lesson.copyWith(
              isFavorite: status?.isFavorite ?? false,
              isCompleted: status?.completedAt != null,
            );
          }).toList();
      _items = mergedLessons;
      return mergedLessons;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: MainItemsListView<dynamic>(
        itemsFuture: _itemsFuture,
        itemBuilder: (item, index) => _buildMainItem(item, index),
        titleFontSize: 20,
      ),
    );
  }

  MainItem _buildMainItem(dynamic item, int index) {
    if (widget.screenType == ScreenType.books && item is BookModel) {
      final authorName = item.authorName?.trim();
      final categoryName = item.categoryName?.trim();
      return MainItem(
        title: item.name,
        leadingContent: ImageLeading(
          imageUrl: item.bookThumbUrl,
          placeholderIcon: AppIcons.book,
        ),
        details: [
          if (authorName != null && authorName.isNotEmpty)
            MainItemDetail(
              text: 'المؤلف: $authorName',
              icon: AppIcons.author,
              iconColor: Colors.teal,
              onTap:
                  (item) => Fluttertoast.showToast(msg: 'المؤلف: $authorName'),
            ),
          if (categoryName != null && categoryName.isNotEmpty)
            MainItemDetail(
              text: 'التصنيف: $categoryName',
              icon: Icons.category,
              iconColor: Colors.blue,
              onTap:
                  (item) =>
                      Fluttertoast.showToast(msg: 'التصنيف: $categoryName'),
            ),
        ],
        onItemTap: (item) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder:
          //         (_) => PdfViewerScreen(
          //           filePath: item.name ?? '',
          //           url: item.bookUrl,
          //           title: item.name,
          //         ),
          //   ),
          // );
        },
        actions: buildActionButtons(
          item: item,
          onTapDownload: () => _downloadItem(index),
          onTapShare: () {
            Fluttertoast.showToast(msg: 'مشاركة الكتاب: ${item.name}');
          },
        ),
      );
    } else if (widget.screenType == ScreenType.lessons && item is LessonModel) {
      final authorName = item.authorName?.trim();
      final categoryName = item.categoryName?.trim();
      return MainItem(
        title: item.lessonName,
        leadingContent: IconLeading(icon: AppIcons.lessonItem),
        details: [
          if (categoryName != null && categoryName.isNotEmpty)
            MainItemDetail(
              text: 'التصنيف: $categoryName',
              icon: Icons.category,
              iconColor: Colors.blue,
              onTap:
                  (item) =>
                      Fluttertoast.showToast(msg: 'التصنيف: $categoryName'),
            ),
          if (authorName != null && authorName.isNotEmpty)
            MainItemDetail(
              text: 'المعلم: $authorName',
              icon: Icons.person,
              iconColor: Colors.teal,
              onTap:
                  (item) => Fluttertoast.showToast(msg: 'المعلم: $authorName'),
            ),
        ],
        onItemTap: (item) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AudioPlayerScreen(
                    lessons: _items?.cast<LessonModel>() ?? [],
                    initialIndex: index,
                  ),
            ),
          );
        },
        actions: buildActionButtons(
          item: item,
          onTapDownload: () => _downloadItem(index),
          onTapFavorite: () => _toggleFavorite(index),
          onTapComplete: () => _toggleComplete(index),
        ),
      );
    } else {
      return MainItem(
        title: 'عنصر غير معروف',
        leadingContent: IconLeading(icon: AppIcons.author),
      );
    }
  }

  /// دالة موحدة لتحميل الكتاب أو الدرس حسب النوع
  Future<void> _downloadItem(int? index) async {
    if (index == null ||
        _items == null ||
        index < 0 ||
        index >= _items!.length) {
      Fluttertoast.showToast(
        msg:
            widget.screenType == ScreenType.books
                ? 'خطأ في تحميل الكتاب'
                : 'خطأ في تحميل الدرس',
      );
      return;
    }

    setState(() {
      if (widget.screenType == ScreenType.books &&
          _items![index] is BookModel) {
        _items![index] = (_items![index] as BookModel).copyWith(
          downloadStatus: DownloadStatus.downloading,
        );
      } else if (widget.screenType == ScreenType.lessons &&
          _items![index] is LessonModel) {
        _items![index] = (_items![index] as LessonModel).copyWith(
          downloadStatus: DownloadStatus.downloading,
        );
      }
    });

    await Future.delayed(const Duration(seconds: 4));

    setState(() {
      if (widget.screenType == ScreenType.books &&
          _items![index] is BookModel) {
        _items![index] = (_items![index] as BookModel).copyWith(
          downloadStatus: DownloadStatus.downloaded,
        );
      } else if (widget.screenType == ScreenType.lessons &&
          _items![index] is LessonModel) {
        _items![index] = (_items![index] as LessonModel).copyWith(
          downloadStatus: DownloadStatus.downloaded,
        );
      }
    });

    Fluttertoast.showToast(
      msg:
          widget.screenType == ScreenType.books
              ? 'تم تنزيل الكتاب'
              : 'تم تنزيل الدرس',
    );
  }

  Future<void> _toggleFavorite(int index) async {
    if (_items == null || index < 0 || index >= _items!.length) return;
    final lesson = _items![index] as LessonModel;
    final newValue = !lesson.isFavorite;
    bool status = await UserItemStatusRepository.setFavorite(
      lesson.id,
      ItemType.lesson,
      newValue,
    );
    setState(() {
      _items![index] = lesson.copyWith(isFavorite: newValue);
    });
  }

  Future<void> _toggleComplete(int index) async {
    if (_items == null || index < 0 || index >= _items!.length) return;
    final lesson = _items![index] as LessonModel;
    final isCurrentlyCompleted = lesson.isCompleted;
    if (isCurrentlyCompleted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => WarningDialog(
              title: 'إلغاء الإكمال',
              subtitle: 'هل تريد فعلاً إلغاء علامة الإكمال لهذا الدرس؟',
              confirmText: 'نعم',
              cancelText: 'تراجع',
            ),
      );
      if (confirmed != true) return;
    }
    bool status = await UserItemStatusRepository.toggleCompleted(
      lesson.id,
      ItemType.lesson,
    );
    setState(() {
      _items![index] = lesson.copyWith(isCompleted: !isCurrentlyCompleted);
    });
  }
}

List<ActionButton> buildActionButtons({
  required dynamic item, // BookModel أو LessonModel
  VoidCallback? onTapDownload,
  VoidCallback? onTapShare,
  VoidCallback? onTapOpenWith,
  VoidCallback? onTapComplete,
  VoidCallback? onTapFavorite,
  VoidCallback? onTapLinked,
}) {
  final List<ActionButton> actions = [];

  // زر التنزيل/الحذف/إيقاف التنزيل (زر واحد فقط)
  if (onTapDownload != null) {
    actions.add(
      ActionButton(
        buttonWidget: AnimatedIconSwitcher(
          icon: () {
            final status = item.downloadStatus ?? DownloadStatus.notDownloaded;
            switch (status) {
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
          final status = item.downloadStatus ?? DownloadStatus.notDownloaded;
          switch (status) {
            case DownloadStatus.notDownloaded:
              return 'تنزيل';
            case DownloadStatus.downloading:
              return 'إيقاف التنزيل';
            case DownloadStatus.downloaded:
              return 'حذف';
            default:
              return '';
          }
        }(),
        onTap: (_) => onTapDownload(),
      ),
    );
  }

  // زر المشاركة
  if (onTapShare != null) {
    actions.add(
      ActionButton(
        buttonWidget: const Icon(AppIcons.share),
        tooltip: 'مشاركة',
        onTap: (_) => onTapShare(),
      ),
    );
  }

  // زر فتح باستخدام
  if (onTapOpenWith != null) {
    actions.add(
      ActionButton(
        buttonWidget: const Icon(AppIcons.openInNew),
        tooltip: 'فتح باستخدام',
        onTap: (_) => onTapOpenWith(),
      ),
    );
  }

  // زر الإكمال
  if (onTapComplete != null) {
    actions.add(
      ActionButton(
        buttonWidget: AnimatedIconSwitcher(
          icon: Icon(
            item.isCompleted == true
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            key: ValueKey(item.isCompleted == true),
            color: item.isCompleted == true ? Colors.green : null,
          ),
        ),
        tooltip: item.isCompleted == true ? 'تم الإكمال' : 'لم يتم الإكمال',
        onTap: (_) => onTapComplete(),
      ),
    );
  }

  // زر المفضلة
  if (onTapFavorite != null) {
    actions.add(
      ActionButton(
        buttonWidget: FavIconButton(
          isFavorite: item.isFavorite == true,
          onTap: onTapFavorite,
        ),
        tooltip:
            item.isFavorite == true ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
        onTap: (_) => onTapFavorite(),
      ),
    );
  }

  // زر العناصر المرتبطة
  if (onTapLinked != null) {
    actions.add(
      ActionButton(
        buttonWidget: const Icon(Icons.link),
        tooltip: 'عناصر مرتبطة',
        onTap: (_) => onTapLinked(),
      ),
    );
  }

  return actions;
}
