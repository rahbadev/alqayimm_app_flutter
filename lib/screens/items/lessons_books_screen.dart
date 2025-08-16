import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/downloader/download_provider.dart';
import 'package:alqayimm_app_flutter/downloader/download_task_model.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/providers/lessons_books_provider.dart';
import 'package:alqayimm_app_flutter/screens/player/audio_player_screen.dart';
import 'package:alqayimm_app_flutter/screens/reader/pdf_viewer_screen.dart';
import 'package:alqayimm_app_flutter/widgets/app_bar.dart';
import 'package:alqayimm_app_flutter/widgets/buttons/items_icon_buttons.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/custom_alert_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/main_items_list.dart';
import 'package:alqayimm_app_flutter/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/widgets/cards/main_item_card.dart';
import 'package:provider/provider.dart';
import 'package:alqayimm_app_flutter/widgets/icons.dart';

enum ScreenType { books, lessons }

class LessonsBooksScreen extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) =>
              LessonsBooksProvider()..loadItems(
                screenType:
                    screenType == ScreenType.lessons
                        ? ScreenType.lessons
                        : ScreenType.books,
                authorId: authorId,
                materialId: materialId,
                levelId: levelId,
                categoryId: categoryId,
                categorySel: categorySel,
                bookTypeSel: bookTypeSel,
              ),
      child: Scaffold(
        appBar: AppBarWidget(
          title: title,
          showDownloadIndicator: ShowDownloadProgress.onDownloading,
        ),
        body: Consumer<LessonsBooksProvider>(
          builder: (context, provider, child) {
            // تحويل البيانات إلى MainItem
            final mainItems =
                provider.items
                    .map((item) => _buildMainItem(context, item, provider))
                    .toList();

            // استخدام MainItemsList الموحد
            return MainItemsList(
              items: mainItems,
              titleFontSize: 20,
              isLoading: provider.isLoading,
            );
          },
        ),
      ),
    );
  }

  MainItem _buildMainItem(
    BuildContext context,
    BaseContentModel item,
    LessonsBooksProvider provider,
  ) {
    final (title, leadingContent, onItemTap) = _getItemConfiguration(
      context,
      item,
      provider,
    );

    return MainItem(
      title: title,
      leadingContent: leadingContent,
      onItemTap: onItemTap,
      details: _buildItemDetails(item),
      actions: _buildItemActions(context, item, provider.items.indexOf(item)),
    );
  }

  (String title, LeadingContent leadingContent, MainItemTapCallback onItemTap)
  _getItemConfiguration(
    BuildContext context,
    BaseContentModel item,
    LessonsBooksProvider provider,
  ) {
    if (item is BookModel) {
      return (
        item.name,
        ImageLeading(
          imageUrl: item.bookThumbUrl,
          placeholderIcon: AppIcons.book,
        ),
        (_) => _navigateToBookViewer(context, item),
      );
    } else if (item is LessonModel) {
      return (
        item.name,
        IconLeading(icon: AppIcons.lessonItem),
        (_) => _navigateToAudioPlayer(
          context,
          provider.items.cast<LessonModel>(),
          provider.items.indexOf(item),
        ),
      );
    }

    throw UnimplementedError('Unsupported item type: ${item.runtimeType}');
  }

  // ==================== Navigation ====================

  void _navigateToBookViewer(BuildContext context, BookModel book) {
    logger.i('Tapped on book: ${book.runtimeType}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfViewerScreen(book: book)),
    );
  }

  void _navigateToAudioPlayer(
    BuildContext context,
    List<LessonModel> items,
    int index,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioPlayerScreen(lessons: items, initialIndex: index),
      ),
    );
  }

  List<MainItemDetail>? _buildItemDetails(BaseContentModel item) {
    final details = <MainItemDetail>[];

    final authorName = item.authorName?.trim();
    if (authorName != null && authorName.isNotEmpty) {
      details.add(
        MainItemDetail(
          text: item is LessonModel ? authorName : 'المؤلف: $authorName',
          icon: AppIcons.author,
          iconColor: Colors.teal,
          onTap: (_) => {},
        ),
      );
    }

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

    return details;
  }

  List<Widget> _buildItemActions(
    BuildContext context,
    BaseContentModel item,
    int index,
  ) {
    return [
      Consumer<DownloadProvider>(
        builder: (context, downloadProvider, child) {
          final downloadModel = downloadProvider.getDownloadInfo(item);
          return DownloadButton(
            downloadStatus:
                downloadModel?.downloadStatus ?? DownloadStatus.none,
            progress: downloadModel?.progress ?? 0.0,
            onTap: () => _handleDownload(context, item, downloadProvider),
          );
        },
      ),
      FavIconButton(
        isFavorite: item.isFavorite,
        onTap:
            () => Provider.of<LessonsBooksProvider>(
              context,
              listen: false,
            ).toggleFavorite(item),
      ),
      CompleteIconButton(
        isCompleted: item.isCompleted,
        onTap:
            () => Provider.of<LessonsBooksProvider>(
              context,
              listen: false,
            ).toggleComplete(item),
      ),
      ActionIconButton.icon(
        icon: AppIcons.share,
        onTap: () => _handleShare(item),
        tooltip: 'مشاركة',
      ),
    ];
  }

  Future<void> _handleDownload(
    BuildContext context,
    BaseContentModel item,
    DownloadProvider downloadProvider,
  ) async {
    final currentStatus = downloadProvider.getDownloadStatus(item);

    switch (currentStatus) {
      case DownloadStatus.none:
        // بدء التنزيل
        await downloadProvider.startDownload(item);
        break;

      case DownloadStatus.progress:
        // التحقق من وجود التنزيل في القائمة النشطة
        try {
          final downloadInfo = downloadProvider.getDownloadInfo(item);
          if (downloadInfo != null) {
            _showDownloadOptionsDialog(context, downloadInfo, downloadProvider);
          } else {
            await downloadProvider.startDownload(item);
          }
        } catch (e) {
          logger.e('Error fetching download info: $e');
          await downloadProvider.startDownload(item);
        }
        break;
      case DownloadStatus.downloaded:
        // عرض خيارات الملف المنزل
        _showDownloadedFileOptions(context, item, downloadProvider);
        break;
    }
  }

  void _showDownloadOptionsDialog(
    BuildContext context,
    DownloadTaskModel downloadModel,
    DownloadProvider downloadProvider,
  ) async {
    final confirmed = await showInfoDialog(
      context: context,
      title: 'خيارات التنزيل',
      subtitle: 'يتم تنزيل الملف هل تريد إيقاف التنزيل ؟',
      confirmText: "إيقاف",
    );
    if (confirmed == true) {
      await downloadProvider.pauseDownload(downloadModel);
    }
  }
}

void _showDownloadedFileOptions(
  BuildContext context,
  BaseContentModel item,
  DownloadProvider downloadProvider,
) async {
  final confirmed = await showInfoDialog(
    context: context,
    title: 'خيارات الملف',
    subtitle: 'تم تنزيل الملف مسبقاً، هل تريد حذف الملف ؟',
    confirmText: "حذف",
  );
  if (confirmed == true) {
    final success = await downloadProvider.removeDownload(item);
    if (success && context.mounted) {
      _showInfoToast('تم حذف الملف بنجاح');
    } else {
      _showErrorToast('فشل في حذف الملف');
    }
  }
}

void _handleShare(BaseContentModel item) {
  // TODO: تنفيذ وظيفة المشاركة
}

void _showErrorToast(String message) {
  AppToasts.showError(description: message);
}

void _showInfoToast(String message) {
  AppToasts.showInfo(description: message);
}
