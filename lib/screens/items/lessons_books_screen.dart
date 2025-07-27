import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/db/user/models/user_item_state_model.dart';
import 'package:alqayimm_app_flutter/downloader/download_task_info.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/downloader/download_provider.dart';
import 'package:alqayimm_app_flutter/screens/reader/pdf_viewer_screen_final.dart';
import 'package:alqayimm_app_flutter/widgets/buttons/items_icon_buttons.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/custom_alert_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/download/global_download_indicator.dart';
import 'package:alqayimm_app_flutter/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:alqayimm_app_flutter/screens/player/audio_player_screen.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/widgets/cards/main_item_card.dart';
import 'package:alqayimm_app_flutter/widgets/icons.dart';
import 'package:alqayimm_app_flutter/widgets/main_items_list.dart';
import 'package:provider/provider.dart';

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
    Navigator.of(context, rootNavigator: true).push(
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
  late Future<List<BaseContentModel>> _itemsFuture;
  List<BaseContentModel>? _items;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalDownloadIndicator(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: MainItemsListView<dynamic>(
          itemsFuture: _itemsFuture,
          itemBuilder: (item, index) => _buildMainItem(item, index),
          titleFontSize: 20,
        ),
      ),
    );
  }

  // ==================== Data Fetching ====================

  Future<List<BaseContentModel>> _fetchItems() async {
    final db = await DbHelper.database;
    final repo = Repo(db);

    // جلب العناصر من قاعدة البيانات الرئيسية
    final items = await _fetchMainItems(repo);

    // جلب حالات المستخدم من قاعدة بيانات المستخدم
    final userStatuses = await _fetchUserStatuses();

    // دمج الحالات مع العناصر
    final mergedItems = _mergeItemsWithStatuses(items, userStatuses);

    // تحديث حالة التنزيل لكل عنصر عند تحميل الشاشة
    try {
      if (mounted) {
        final downloadProvider = context.read<DownloadProvider>();
        await downloadProvider.refreshAllDownloadStatuses(mergedItems);
      }
    } catch (e) {
      logger.e('Error refreshing download statuses: $e');
    }

    return _items = mergedItems;
  }

  Future<List<BaseContentModel>> _fetchMainItems(Repo repo) async {
    if (widget.screenType == ScreenType.books) {
      return await repo.fetchBooks(
        authorId: widget.authorId,
        categorySel: widget.categorySel ?? CategorySel.all(),
        bookTypeSel: widget.bookTypeSel ?? BookTypeSel.all(),
      );
    } else {
      return await repo.fetchLessons(
        materialId: widget.materialId,
        authorId: widget.authorId,
        levelId: widget.levelId,
        categoryId: widget.categoryId,
      );
    }
  }

  Future<List<UserItemStatusModel>> _fetchUserStatuses() async {
    return await UserItemStatusRepository.getItems(
      itemType:
          widget.screenType == ScreenType.lessons
              ? ItemType.lesson
              : ItemType.book,
    );
  }

  List<BaseContentModel> _mergeItemsWithStatuses(
    List<BaseContentModel> items,
    List<UserItemStatusModel> userStatuses,
  ) {
    // بناء خريطة للحالات حسب معرف العنصر
    final statusMap = {for (var s in userStatuses) s.itemId: s};

    // دمج الحالات مع العناصر
    return items.map((item) {
      final status = statusMap[item.id];
      return item.copyWith(
        isFavorite: status?.isFavorite ?? false,
        isCompleted: status?.isCompleted ?? false,
      );
    }).toList();
  }

  // ==================== UI Building ====================

  MainItem _buildMainItem(BaseContentModel item, int index) {
    final itemConfig = _getItemConfiguration(item, index);

    return MainItem(
      title: itemConfig.title,
      leadingContent: itemConfig.leadingContent,
      details: _buildItemDetails(item),
      onItemTap: itemConfig.onItemTap,
      actions: _buildItemActions(item, index),
    );
  }

  _ItemConfiguration _getItemConfiguration(BaseContentModel item, int index) {
    if (item is BookModel) {
      return _ItemConfiguration(
        title: item.name,
        leadingContent: ImageLeading(
          imageUrl: item.bookThumbUrl,
          placeholderIcon: AppIcons.book,
        ),
        onItemTap: (_) => _navigateToBookViewer(item),
      );
    } else if (item is LessonModel) {
      return _ItemConfiguration(
        title: item.lessonName,
        leadingContent: IconLeading(icon: AppIcons.lessonItem),
        onItemTap: (_) => _navigateToAudioPlayer(index),
      );
    }

    throw UnimplementedError('Unsupported item type: ${item.runtimeType}');
  }

  List<MainItemDetail> _buildItemDetails(BaseContentModel item) {
    final details = <MainItemDetail>[];

    _addAuthorDetail(details, item);
    _addCategoryDetail(details, item);

    return details;
  }

  void _addAuthorDetail(List<MainItemDetail> details, BaseContentModel item) {
    final authorName = item.authorName?.trim();
    if (authorName != null && authorName.isNotEmpty) {
      details.add(
        MainItemDetail(
          text: item is BookModel ? authorName : 'المؤلف: $authorName',
          icon: AppIcons.author,
          iconColor: Colors.teal,
          onTap: (_) => {},
        ),
      );
    }
  }

  void _addCategoryDetail(List<MainItemDetail> details, BaseContentModel item) {
    final categoryName = item.categoryName?.trim();
    if (categoryName != null && categoryName.isNotEmpty) {
      details.add(
        MainItemDetail(
          text: 'التصنيف: $categoryName',
          icon: Icons.category,
          iconColor: Colors.blue,
          onTap: (_) => {},
        ),
      );
    }
  }

  List<Widget> _buildItemActions(BaseContentModel item, int index) {
    return [
      Consumer<DownloadProvider>(
        builder: (context, downloadProvider, child) {
          final downloadStatus = downloadProvider.getDownloadStatus(item);
          final info = downloadProvider.getDownloadInfo(item);
          return DownloadButton(
            downloadStatus: downloadStatus,
            progress: info?.progress ?? 0.0,
            onTap: () => _handleDownload(item, downloadProvider),
          );
        },
      ),
      FavIconButton(
        isFavorite: item.isFavorite,
        onTap: () => _toggleFavorite(index),
      ),
      CompleteIconButton(
        isCompleted: item.isCompleted,
        onTap: () => _toggleComplete(index),
      ),
      ActionIconButton.icon(
        icon: AppIcons.share,
        onTap: () => _handleShare(item),
        tooltip: 'مشاركة',
      ),
    ];
  }

  // ==================== Navigation ====================

  void _navigateToBookViewer(BookModel book) {
    logger.i('Tapped on book: ${book.runtimeType}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfViewerScreenFinal(book: book)),
    );
  }

  void _navigateToAudioPlayer(int index) {
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
  }

  // ==================== Action Handlers ====================

  Future<void> _toggleFavorite(int index) async {
    final item = _getValidItem(index);
    if (item == null) return;

    final success = await UserItemStatusRepository.toggleFavorite(
      item.id,
      _getItemType(item),
    );

    if (!success) {
      _showErrorToast('حدث خطأ أثناء تحديث المفضلة');
      return;
    }

    _updateItemState(
      index,
      (item) => item.copyWith(isFavorite: !item.isFavorite),
    );
  }

  Future<void> _toggleComplete(int index) async {
    final item = _getValidItem(index);
    if (item == null) return;

    final success = await UserItemStatusRepository.toggleCompleted(
      item.id,
      _getItemType(item),
    );

    if (!success) {
      _showErrorToast('حدث خطأ أثناء تحديث الحالة');
      return;
    }

    _updateItemState(
      index,
      (item) => item.copyWith(isCompleted: !item.isCompleted),
    );
  }

  Future<void> _handleDownload(
    BaseContentModel item,
    DownloadProvider downloadProvider,
  ) async {
    final currentStatus = downloadProvider.getDownloadStatus(item);

    switch (currentStatus) {
      case DownloadStatus.none:
        // بدء التنزيل
        await downloadProvider.startDownload(context, item);
        break;

      case DownloadStatus.progress:
        // التحقق من وجود التنزيل في القائمة النشطة
        try {
          final downloadInfo = downloadProvider.getDownloadInfo(item);
          if (downloadInfo != null) {
            _showDownloadOptionsDialog(downloadInfo, downloadProvider);
          } else {
            await downloadProvider.startDownload(context, item);
          }
        } catch (e) {
          logger.e('Error fetching download info: $e');
          // لا يوجد تنزيل نشط - محاولة بدء تنزيل جديد
          if (mounted) {
            await downloadProvider.startDownload(context, item);
          }
        }
        break;
      case DownloadStatus.downloaded:
        // عرض خيارات الملف المنزل
        _showDownloadedFileOptions(item, downloadProvider);
        break;
    }
  }

  void _showDownloadOptionsDialog(
    DownloadTaskInfo downloadInfo,
    DownloadProvider downloadProvider,
  ) async {
    final confirmed = await showInfoDialog(
      context: context,
      title: 'خيارات التنزيل',
      subtitle: 'يتم تنزيل الملف هل تريد إيقاف التنزيل ؟',
      confirmText: "إيقاف",
    );
    if (confirmed == true && mounted) {
      await downloadProvider.pauseDownload(downloadInfo.taskId);
    }
  }

  void _showDownloadedFileOptions(
    BaseContentModel item,
    DownloadProvider downloadProvider,
  ) async {
    final confirmed = await showInfoDialog(
      context: context,
      title: 'خيارات الملف',
      subtitle: 'تم تنزيل الملف مسبقاً، هل تريد حذف الملف ؟',
      confirmText: "حذف",
    );
    if (confirmed == true && mounted) {
      await downloadProvider.deleteDownloadedFile(context, item);
    }
  }

  void _handleShare(BaseContentModel item) {
    // TODO: تنفيذ وظيفة المشاركة
  }

  // ==================== Helper Methods ====================

  BaseContentModel? _getValidItem(int index) {
    if (_items == null || index < 0 || index >= _items!.length) return null;
    return _items![index];
  }

  ItemType _getItemType(BaseContentModel item) {
    return item is LessonModel ? ItemType.lesson : ItemType.book;
  }

  void _updateItemState(
    int index,
    BaseContentModel Function(BaseContentModel) updater,
  ) {
    if (_items != null && index >= 0 && index < _items!.length) {
      setState(() {
        _items![index] = updater(_items![index]);
      });
    }
  }

  void _showErrorToast(String message) {
    if (mounted) {
      AppToasts.showError(context, description: message);
    }
  }
}

// ==================== Helper Classes ====================

class _ItemConfiguration {
  final String title;
  final LeadingContent leadingContent;
  final Function(MainItem) onItemTap;

  const _ItemConfiguration({
    required this.title,
    required this.leadingContent,
    required this.onItemTap,
  });
}
