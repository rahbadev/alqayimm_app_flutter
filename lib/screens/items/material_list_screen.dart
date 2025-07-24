import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/db/main/models/material_model.dart';
import 'package:alqayimm_app_flutter/screens/items/lessons_books_screen.dart';
import 'package:alqayimm_app_flutter/widgets/icons.dart';
import 'package:alqayimm_app_flutter/widgets/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/widgets/cards/main_item_card.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:alqayimm_app_flutter/main.dart'; // لتفعيل RouteObserver

class MaterialsListScreen extends StatefulWidget {
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

  @override
  State<MaterialsListScreen> createState() => _MaterialsListScreenState();
}

class _MaterialsListScreenState extends State<MaterialsListScreen>
    with RouteAware {
  late Future<List<MaterialModel>> _materialsFuture;

  @override
  void initState() {
    super.initState();
    _materialsFuture = _fetchMaterials();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      _materialsFuture = _fetchMaterials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: MainItemsListView<MainItem>(
        itemsFuture: _materialsFuture.then((materials) async {
          // بناء MainItem مع تفاصيل النسبة
          return Future.wait(
            materials.map((material) async {
              final percentage =
                  await UserItemStatusRepository.getCompletionPercentageForMaterial(
                    material.id,
                  );
              final showLevel = widget.levelSel is LevelWith;
              final showCategore = widget.categorySel is CatAll;
              return MainItem(
                leadingContent: IconLeading(
                  icon: MaterialIcons.my_library_music,
                ),
                title: material.name,
                details: [
                  if (widget.authorId == null)
                    MainItemDetail(
                      text: "الشيخ: ${material.authorName ?? 'غير معروف'}",
                      icon: AppIcons.author,
                      iconColor: Colors.teal,
                    ),
                  if (showCategore && material.categoryName != null)
                    MainItemDetail(
                      text: 'التصنيف: ${material.categoryName}',
                      icon: Icons.category,
                      iconColor: Colors.blue,
                    ),
                  if (showLevel && material.levelName != null)
                    MainItemDetail(
                      text: 'المستوى: ${material.levelName}',
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
                      text:
                          'نسبة الإكمال: ${(percentage * 100).toStringAsFixed(0)}%',
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
        }),
        itemBuilder: (item, index) => item,
        titleFontSize: 20,
      ),
    );
  }

  Future<List<MaterialModel>> _fetchMaterials() async {
    final db = await DbHelper.database;
    final repo = Repo(db);

    return await repo.fetchMaterials(
      authorId: widget.authorId,
      levelSel: widget.levelSel,
      categorySel: widget.categorySel,
    );
  }
}
