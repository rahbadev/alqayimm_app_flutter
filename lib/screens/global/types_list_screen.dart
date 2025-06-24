import 'package:alqayimm_app_flutter/db/main/enums.dart';
import 'package:alqayimm_app_flutter/screens/global/books_list_screen.dart';
import 'package:alqayimm_app_flutter/screens/global/material_list_screen.dart';
import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/widget/lists/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/user/db_queries.dart';
import 'package:alqayimm_app_flutter/models/main_db/type_model.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';

class TypesListScreen extends StatelessWidget {
  final List<TypeModel> items;
  final String title;
  final bool forShik;
  final bool isBooks;
  final IconData icon;

  const TypesListScreen({
    super.key,
    required this.items,
    required this.title,
    required this.forShik,
    required this.isBooks,
    required this.icon,
  });

  Future<List<MainItemDetail>> _getTypeDetails(TypeModel type) async {
    // final count = await UserDbQueries.getMaterialsCountForLevel(type.id);
    final percentage = await UserDbQueries.getCompletionPercentage(type.id);
    final lastPlayed = await UserDbQueries.getLastPlayedMaterial(type.id);

    return [
      MainItemDetail(
        text:
            (isBooks ? 'عدد الكتب: ' : 'عدد المواد: ') +
            type.childCount.toString(),
        icon: Icons.numbers,
        iconColor: Colors.orange,
      ),
      MainItemDetail(
        text: 'قمت بإنهاء: ${(percentage * 100).toStringAsFixed(0)}%',
        icon: Icons.check_circle,
        iconColor: Colors.green,
      ),
      MainItemDetail(
        text:
            (isBooks ? 'أخر ما تم فتحه: ' : 'آخر ما تم تشغيله: ') +
            lastPlayed.toString(),
        icon: Icons.play_arrow,
        iconColor: Colors.blue,
      ),
    ];
  }

  static void navigateToScreen(
    BuildContext context,
    String title,
    List<TypeModel> types,
    bool forShik,
    bool? isBooks,
    IconData icon,
  ) {
    Navigator.push(
      context,
      fadeSlideRoute(
        TypesListScreen(
          title: title,
          items: types,
          forShik: forShik,
          isBooks: isBooks ?? false,
          icon: icon,
        ),
      ),
    );
  }

  Future<List<MainItem>> _getMainItems(BuildContext context) async {
    return Future.wait(
      items.map((type) async {
        final details = await _getTypeDetails(type);
        final icon = type.icon ?? this.icon;
        final title = type.name;
        return MainItem(
          leadingContent: IconLeading(icon: icon),
          title: title,
          details: details,
          onItemTap: (item) {
            if (isBooks) {
              Navigator.push(
                context,
                fadeSlideRoute(
                  BooksListScreen(
                    title: item.title,
                    categorySel:
                        forShik
                            ? CategorySel.only([type.id])
                            : CategorySel.all(),
                    bookTypeSel:
                        forShik
                            ? BookTypeSel.all()
                            : BookTypeSel.only([type.id]),
                    authorId: forShik ? 27 : null,
                  ),
                ),
              );
            } else if (type is LevelModel) {
              Navigator.push(
                context,
                fadeSlideRoute(
                  MaterialsListScreen(
                    title: item.title,
                    levelSel: LevelSel.only([type.id]),
                    categorySel: CategorySel.all(),
                    authorId: forShik ? 27 : null,
                  ),
                ),
              );
            } else if (type is CategoryModel) {
              if (forShik) {
                Navigator.push(
                  context,
                  fadeSlideRoute(
                    MaterialsListScreen(
                      title: item.title,
                      levelSel: LevelSel.all(),
                      categorySel: CategorySel.only([type.id]),
                      authorId: 27,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  fadeSlideRoute(
                    MaterialsListScreen(
                      title: item.title,
                      levelSel: LevelSel.withLevel(),
                      categorySel: CategorySel.only([type.id]),
                      authorId: null,
                    ),
                  ),
                );
              }
            }
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: MainItemsListView<MainItem>(
        itemsFuture: items.isEmpty ? Future.value([]) : _getMainItems(context),
        itemBuilder: (item, index) => item,
      ),
    );
  }
}
