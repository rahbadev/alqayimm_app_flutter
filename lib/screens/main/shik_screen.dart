import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/widget/icons.dart';
import 'package:alqayimm_app_flutter/screens/items/types_list_screen.dart';
import 'package:alqayimm_app_flutter/widget/cards.dart';
import 'package:alqayimm_app_flutter/widget/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';

class ShikScreen extends StatelessWidget {
  const ShikScreen({super.key});

  Future<List<MainItem>> _fetchMainItems(BuildContext context) async {
    final db = await DbHelper.database;
    final repo = Repo(db);
    final booksCategories = await repo.fetchCategories(
      authorId: 27,
      forBooks: true,
      levelSel: LevelSel.all(),
    );
    final materialsCategories = await repo.fetchCategories(
      authorId: 27,
      levelSel: LevelSel.all(),
    );

    return [
      MainItem(
        leadingContent: IconLeading(icon: AppIcons.mainMaterials),
        title: 'دروس الشيخ',
        details: [
          MainItemDetail(
            text: 'عدد الدروس : ${materialsCategories.length}',
            icon: AppIcons.smallMaterials,
            iconColor: Colors.pink,
          ),
        ],
        onItemTap:
            (item) => TypesListScreen.navigateToScreen(
              context,
              item.title,
              materialsCategories,
              true,
              false,
              Icons.library_music,
            ),
      ),
      MainItem(
        leadingContent: IconLeading(icon: AppIcons.mainBooksLibrary),
        title: 'مكتبة الشيخ',
        details: [
          MainItemDetail(
            text: 'عدد الكتب : ${booksCategories.length}',
            icon: AppIcons.smallCategoryBook,
            iconColor: Colors.teal,
          ),
        ],
        onItemTap:
            (item) => TypesListScreen.navigateToScreen(
              context,
              item.title,
              booksCategories,
              true,
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
