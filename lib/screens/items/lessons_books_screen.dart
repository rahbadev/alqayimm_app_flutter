import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/providers/lessons_books_provider.dart';
import 'package:alqayimm_app_flutter/screens/player/audio_player_screen.dart';
import 'package:alqayimm_app_flutter/screens/reader/pdf_viewer_screen.dart';
import 'package:alqayimm_app_flutter/widgets/app_bar.dart';
import 'package:alqayimm_app_flutter/widgets/main_items_list.dart';
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
      actions: _buildItemActions(item),
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
        item.lessonName,
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
    return [
      MainItemDetail(
        text: 'تفاصيل العنصر',
        icon: Icons.info,
        iconColor: Colors.blue,
        onTap: (detail) {
          // Handle detail tap
        },
      ),
    ];
  }

  List<Widget>? _buildItemActions(BaseContentModel item) {
    return [
      Builder(
        builder:
            (context) => IconButton(
              icon: Icon(
                item.isFavorite == true
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: item.isFavorite == true ? Colors.red : null,
              ),
              onPressed: () {
                Provider.of<LessonsBooksProvider>(
                  context,
                  listen: false,
                ).toggleFavorite(item);
              },
            ),
      ),
      Builder(
        builder:
            (context) => IconButton(
              icon: Icon(
                item.isCompleted == true
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: item.isCompleted == true ? Colors.green : null,
              ),
              onPressed: () {
                Provider.of<LessonsBooksProvider>(
                  context,
                  listen: false,
                ).toggleComplete(item);
              },
            ),
      ),
    ];
  }
}
