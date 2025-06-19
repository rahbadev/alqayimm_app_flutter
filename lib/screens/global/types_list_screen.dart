import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:alqayimm_app_flutter/widget/lists/main_items_list.dart';
import 'package:alqayimm_app_flutter/screens/global/books_list_screen.dart';
import 'package:alqayimm_app_flutter/screens/global/material_list_screen.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/enmus.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/db/user/db_queries.dart';
import 'package:alqayimm_app_flutter/models/main_db/type_model.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';

class TypesListScreen extends StatelessWidget {
  final List<TypeModel> items;
  final String title;
  final bool forShik;
  final bool isBooks;

  const TypesListScreen({
    super.key,
    required this.items,
    required this.title,
    required this.forShik,
    required this.isBooks,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body:
          items.isEmpty
              ? const Center(child: Text('لا يوجد بيانات'))
              : FutureBuilder<List<MainItem>>(
                future: Future.wait(
                  items.map((type) async {
                    final details = await _getTypeDetails(type);
                    return MainItem(
                      leadingContent: IconLeading(icon: Icons.style),
                      title: type.name,
                      details: details,
                    );
                  }),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return MainItemsList(
                    items: snapshot.data!,
                    onItemTap: (item, index) {
                      logger.info(
                        'Tapped on item: ${item.title}, index: $index , type : ${item.runtimeType}',
                      );
                      final selected = items[index];

                      if (isBooks) {
                        // إذا كان النوع هو نوع كتاب، انتقل إلى شاشة الكتب
                        Navigator.push(
                          context,
                          fadeSlideRoute(
                            BooksListScreen(
                              title: item.title,
                              categorySel:
                                  forShik
                                      ? CategorySel.only([selected.id])
                                      : CategorySel.all(),
                              bookTypeSel:
                                  forShik
                                      ? BookTypeSel.all()
                                      : BookTypeSel.only([selected.id]),
                              authorId: forShik ? 27 : null,
                            ),
                          ),
                        );
                      } else if (selected is LevelModel) {
                        // مواد المعهد في مستوى معين - المستوى (رقم المستوى) + التصنيف (الجميع)
                        Navigator.push(
                          context,
                          fadeSlideRoute(
                            MaterialsListScreen(
                              title: item.title,
                              levelSel: LevelSel.only([selected.id]),
                              categorySel: CategorySel.all(),
                              authorId: forShik ? 27 : null,
                            ),
                          ),
                        );
                      } else if (selected is CategoryModel) {
                        if (forShik) {
                          // المواد في تصنيف معين (الشيخ) - المستوى (فارغ) + التصنيف (رقم التصنيف)
                          Navigator.push(
                            context,
                            fadeSlideRoute(
                              MaterialsListScreen(
                                title: item.title,
                                levelSel: LevelSel.all(),
                                categorySel: CategorySel.only([selected.id]),
                                authorId: 27, // الشيخ
                              ),
                            ),
                          );
                        } else {
                          // المواد في تصنيف معين (المعهد) - المستوى (غير فارغ) + التصنيف (رقم التصنيف)
                          Navigator.push(
                            context,
                            fadeSlideRoute(
                              MaterialsListScreen(
                                title: item.title,
                                levelSel: LevelSel.withLevel(),
                                categorySel: CategorySel.only([selected.id]),
                                authorId: null,
                              ),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
    );
  }
}
