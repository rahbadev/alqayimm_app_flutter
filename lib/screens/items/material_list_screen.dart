import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/screens/items/lessons_books_screen.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/widgets/app_bar.dart';
import 'package:alqayimm_app_flutter/widgets/icons.dart';
import 'package:alqayimm_app_flutter/widgets/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/widgets/cards/main_item_card.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';

class MaterialsListScreen extends StatelessWidget {
  final String title;
  final LevelSel levelSel;
  final CategorySel categorySel;
  final int? authorId;

  const MaterialsListScreen({
    super.key,
    required this.title,
    required this.levelSel,
    required this.categorySel,
    this.authorId,
  });

  static void navigateToScreen(
    BuildContext context,
    String title,
    LevelSel levelSel,
    CategorySel categorySel,
    int? authorId,
  ) {
    Navigator.of(context, rootNavigator: true).push(
      fadeSlideRoute(
        MaterialsListScreen(
          title: title,
          levelSel: levelSel,
          categorySel: categorySel,
          authorId: authorId,
        ),
      ),
    );
  }

  Future<List<MainItem>> _fetchMaterials(BuildContext context) async {
    final db = await DbHelper.database;
    final repo = Repo(db);

    final materials = await repo.fetchMaterials(
      authorId: authorId,
      levelSel: levelSel,
      categorySel: categorySel,
    );

    // build material details
    final showLevel = levelSel is LevelWith;
    final showCategory = categorySel is CatAll;

    return Future.wait(
      materials.map((material) async {
        final percentage =
            await UserItemStatusRepository.getCompletionPercentageForMaterial(
              material.id,
            );
        return MainItem(
          leadingContent: IconLeading(icon: MaterialIcons.my_library_music),
          title: material.name,
          details: [
            if (authorId == null)
              MainItemDetail(
                text: material.authorName ?? 'غير معروف',
                icon: AppIcons.author,
                iconColor: Colors.teal,
              ),
            if (showCategory && material.categoryName != null)
              MainItemDetail(
                text: 'التصنيف: ${material.categoryName}',
                icon: Icons.category,
                iconColor: Colors.blue,
              ),
            if (showLevel && material.levelName != null)
              MainItemDetail(
                text: material.levelName!,
                icon: AppIcons.mainLevels,
                iconColor: Colors.orange,
              ),
            MainItemDetail(
              text: 'عدد الدروس: ${material.lessonsCount}',
              icon: AppIcons.number,
              iconColor: Colors.orange,
            ),
            if (percentage > 0)
              MainItemDetail(
                text: 'نسبة الإكمال: ${(percentage * 100).toStringAsFixed(0)}%',
                icon: AppIcons.percentage,
                iconColor: Colors.green,
              ),
          ],
          onItemTap: (item) {
            LessonsBooksScreen.navigateToScreen(
              context: context,
              screenType: ScreenType.lessons,
              materialId: material.id,
              title: material.name,
            );
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: title,
        showDownloadIndicator: ShowDownloadProgress.onDownloading,
      ),
      body: MainItemsFuture(
        itemsFuture: _fetchMaterials(context),
        titleFontSize: 24,
      ),
    );
  }
}
