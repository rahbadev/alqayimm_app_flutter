import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:alqayimm_app_flutter/screens/items/lessons_books_screen.dart';
import 'package:alqayimm_app_flutter/screens/items/material_list_screen.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/widgets/app_bar.dart';
import 'package:alqayimm_app_flutter/widgets/cards/main_item_card.dart';
import 'package:alqayimm_app_flutter/widgets/download_progress_indicator.dart';
import 'package:alqayimm_app_flutter/widgets/icons.dart';
import 'package:alqayimm_app_flutter/widgets/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/models/type_model.dart';

class TypesListScreen extends StatelessWidget {
  final List<TypeModel> items;
  final String title;
  final bool forShik;
  final bool isBooks;
  final IconData mainIcon;

  const TypesListScreen({
    super.key,
    required this.items,
    required this.title,
    required this.forShik,
    required this.isBooks,
    required this.mainIcon,
  });

  static void navigateToScreen(
    BuildContext context,
    String title,
    List<TypeModel> types,
    bool forShik,
    bool? isBooks,
    IconData icon,
  ) {
    Navigator.of(context, rootNavigator: true).push(
      fadeSlideRoute(
        TypesListScreen(
          title: title,
          items: types,
          forShik: forShik,
          isBooks: isBooks ?? false,
          mainIcon: icon,
        ),
      ),
    );
  }

  Future<List<MainItemDetail>> _getTypeDetails(TypeModel type) async {
    double percentage = 0.0;
    if (!forShik && !isBooks) {
      percentage = switch (type) {
        LevelModel() => await UserItemStatusRepository.getCompletionPercentage(
          levelId: type.id,
        ),
        CategoryModel() =>
          await UserItemStatusRepository.getCompletionPercentage(
            categoryId: type.id,
          ),
        // يمكنك إضافة حالات أخرى إذا كان عندك أنواع أخرى
        _ => 0.0, // في حال لم يكن النوع Level أو Category
      };
    }

    return [
      MainItemDetail(
        text:
            (isBooks ? 'عدد الكتب: ' : 'عدد المواد: ') +
            type.childCount.toString(),
        icon: AppIcons.smallCategoryMaterial,
        iconColor: Colors.blue,
      ),
      if (percentage > 0.0)
        MainItemDetail(
          text: 'نسبة الإكمال: ${(percentage * 100).toStringAsFixed(0)}%',
          icon: Icons.check_circle,
          iconColor: Colors.green,
        ),
      // todo
      // MainItemDetail(
      //   text:
      //       (isBooks ? 'أخر ما تم فتحه: ' : 'آخر ما تم تشغيله: ') +
      //       lastPlayed.toString(),
      //   icon: Icons.play_arrow,
      //   iconColor: Colors.blue,
      // ),
    ];
  }

  Future<List<MainItem>> _getMainItems(BuildContext context) async {
    return Future.wait(
      items.map((type) async {
        final details = await _getTypeDetails(type);
        final icon = type.icon ?? mainIcon;
        final title = type.name;
        return MainItem(
          leadingContent: IconLeading(icon: icon),
          title: title,
          details: details,
          onItemTap: (item) {
            if (isBooks) {
              LessonsBooksScreen.navigateToScreen(
                context: context,
                screenType: ScreenType.books,
                title: item.title,
                categorySel:
                    forShik ? CategorySel.only([type.id]) : CategorySel.all(),
                bookTypeSel:
                    forShik ? BookTypeSel.all() : BookTypeSel.only([type.id]),
                authorId: forShik ? 27 : null,
              );
            } else if (type is LevelModel) {
              MaterialsListScreen.navigateToScreen(
                context,
                item.title,
                LevelSel.only([type.id]),
                CategorySel.all(),
                forShik ? 27 : null,
              );
            } else if (type is CategoryModel) {
              if (forShik) {
                MaterialsListScreen.navigateToScreen(
                  context,
                  item.title,
                  LevelSel.all(),
                  CategorySel.only([type.id]),
                  27,
                );
              } else {
                MaterialsListScreen.navigateToScreen(
                  context,
                  item.title,
                  LevelSel.withLevel(),
                  CategorySel.only([type.id]),
                  null,
                );
              }
            }
          },
        );
      }).toList(),
    );
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: title,
        showDownloadIndicator: ShowDownloadProgress.onDownloading,
      ),
      body: MainItemsFuture(itemsFuture: _getMainItems(context)),
    );
  }
}
