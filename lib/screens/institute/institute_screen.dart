import 'package:alqayimm_app_flutter/utils/app_icons.dart';
import 'package:alqayimm_app_flutter/utils/app_strings.dart';
import 'package:alqayimm_app_flutter/db/main/enums.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/models/main_db/type_model.dart';
import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:alqayimm_app_flutter/screens/global/material_list_screen.dart';
import 'package:alqayimm_app_flutter/screens/global/types_list_screen.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';
import 'package:alqayimm_app_flutter/widget/lists/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<List<MainItem>> _fetchMainItems(BuildContext context) async {
    final db = await DbHelper.database;
    final repo = Repo(db);

    final levels =
        (await repo.fetchLevels(
          levelSel: LevelSel.withLevel(),
          order: TypeOrder.id,
        )).map((level) {
          // انسخ الكائن مع إضافة الأيقونة المناسبة
          return LevelModel(
            id: level.id,
            name: level.name,
            childCount: level.childCount,
            icon: levelIcon(level.id),
          );
        }).toList();

    final categories =
        (await repo.fetchCategories(
          forBooks: false,
          levelSel: LevelSel.withLevel(),
          categorySel: CategorySel.all(),
        )).map((category) {
          return CategoryModel(
            id: category.id,
            name: category.name,
            childCount: category.childCount,
          );
        }).toList();

    final materials = await repo.fetchMaterials(
      levelSel: LevelSel.withLevel(),
      categorySel: CategorySel.all(),
    );

    final instituteLibrary = await repo.fetchBookTypes();

    final levelsCount = levels.length;
    final categoriesCount = categories.length;
    final materialsCount = materials.length;
    final booksCont = instituteLibrary.length;

    return [
      MainItem(
        title: AppStrings.levels,
        leadingContent: IconLeading(icon: AppIcons.mainLevels),
        details: [
          MainItemDetail(
            text: 'عدد المستويات : $levelsCount',
            icon: AppIcons.smallLevel,
            iconColor: Colors.orange,
          ),
        ],
        onItemTap: (item) {
          TypesListScreen.navigateToScreen(
            context,
            item.title,
            levels,
            false,
            false,
            AppIcons.itemLevel,
          );
        },
      ),
      MainItem(
        leadingContent: IconLeading(icon: AppIcons.mainCategoryMaterial),
        title: AppStrings.categories,
        details: [
          MainItemDetail(
            text: 'عدد التصنيفات : $categoriesCount',
            icon: AppIcons.smallCategoryMaterial,
            iconColor: Colors.blue,
          ),
        ],
        onItemTap: (item) {
          TypesListScreen.navigateToScreen(
            context,
            item.title,
            categories,
            false,
            false,
            AppIcons.itemCategoryMaterial,
          );
        },
      ),
      MainItem(
        leadingContent: IconLeading(icon: AppIcons.mainMaterials),
        title: "جميع الدروس",
        details: [
          MainItemDetail(
            text: 'عدد المواد : $materialsCount',
            icon: AppIcons.smallMaterials,
            iconColor: Colors.deepPurple,
          ),
        ],
        onItemTap: (item) {
          Navigator.push(
            context,
            fadeSlideRoute(
              MaterialsListScreen(
                title: item.title,
                levelSel: LevelSel.withLevel(),
                categorySel: CategorySel.all(),
                authorId: null,
              ),
            ),
          );
        },
      ),
      MainItem(
        leadingContent: IconLeading(icon: AppIcons.mainBooksLibrary),
        title: "مكتبة المعهد",
        details: [
          MainItemDetail(
            text: 'عدد الكتب : $booksCont',
            icon: AppIcons.smallCategoryBook,
            iconColor: Colors.teal,
          ),
        ],
        onItemTap:
            (item) => TypesListScreen.navigateToScreen(
              context,
              item.title,
              instituteLibrary,
              false,
              true,
              AppIcons.itemCategoryBook,
            ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MainItemsListView<MainItem>(
      itemsFuture: _fetchMainItems(context),
      itemBuilder: (item, index) => item,
    );
  }
}

IconData levelIcon(int levelNumber) {
  switch (levelNumber) {
    case 1:
      return MaterialIcons.filter_1;
    case 2:
      return MaterialIcons.filter_2;
    case 3:
      return MaterialIcons.filter_3;
    case 4:
      return MaterialIcons.filter_4;
    case 5:
      return MaterialIcons.filter_5;
    default:
      return MaterialIcons.layers;
  }
}
