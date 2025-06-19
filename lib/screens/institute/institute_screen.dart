import 'package:alqayimm_app_flutter/app_strings.dart';
import 'package:alqayimm_app_flutter/db/main/enmus.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/models/main_db/material_model.dart';
import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:alqayimm_app_flutter/widget/lists/main_items_list.dart';
import 'package:alqayimm_app_flutter/screens/global/material_list_screen.dart';
import 'package:alqayimm_app_flutter/screens/global/types_list_screen.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/models/main_db/type_model.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int levelsCount = 0;
  int categoriesCount = 0;
  int materialsCount = 0;
  int booksCont = 0;
  List<LevelModel> levels = [];
  List<CategoryModel> categories = [];
  List<MaterialModel> materials = [];
  List<BookTypeModel> instituteLibrary = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    final db = await DbHelper.database;
    final repo = Repo(db);

    // todo this not used for item but only for counts
    final levels = await repo.fetchLevels(
      levelSel: LevelSel.withLevel(),
      order: TypeOrder.id,
    );

    final categories = await repo.fetchCategories(
      forBooks: false,
      levelSel: LevelSel.withLevel(),
      categorySel: CategorySel.all(),
    );
    final materials = await repo.fetchMaterials(
      levelSel: LevelSel.withLevel(),
      categorySel: CategorySel.all(),
    );

    final instituteLibrary = await repo.fetchBookTypes();

    setState(() {
      this.levels = levels;
      this.categories = categories;
      this.materials = materials;
      this.instituteLibrary = instituteLibrary;
      levelsCount = levels.length;
      categoriesCount = categories.length;
      materialsCount = materials.length;
      booksCont = instituteLibrary.length;
      loading = false;
    });
  }

  List<MainItem> _buidlItems() {
    return [
      MainItem(
        title: AppStrings.levels,
        leadingContent: IconLeading(icon: Icons.layers),
        details: [
          MainItemDetail(
            text: 'عدد المستويات : $levelsCount',
            icon: Icons.layers,
            iconColor: Colors.orange,
          ),
        ],
      ),
      MainItem(
        leadingContent: IconLeading(icon: Icons.style),
        title: AppStrings.categories,
        details: [
          MainItemDetail(
            text: 'عدد التصنيفات : $categoriesCount',
            icon: Icons.topic,
            iconColor: Colors.blue,
          ),
        ],
      ),
      MainItem(
        leadingContent: IconLeading(icon: Icons.library_music),
        title: AppStrings.allMaterials,
        details: [
          MainItemDetail(
            text: 'عدد المواد : $materialsCount',
            icon: Icons.music_note,
            iconColor: Colors.pinkAccent,
          ),
        ],
      ),
      MainItem(
        leadingContent: IconLeading(icon: Icons.book),
        title: AppStrings.instituteLibrary,
        details: [
          MainItemDetail(
            text: 'عدد الكتب : $booksCont',
            icon: Icons.book,
            iconColor: Colors.teal,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return MainItemsList(
      items: _buidlItems(),
      onItemTap: (item, index) {
        if (index == 0) {
          // المستويات
          Navigator.push(
            context,
            fadeSlideRoute(
              TypesListScreen(
                items: levels,
                title: item.title,
                forShik: false,
                isBooks: false,
              ),
            ),
          );
        } else if (index == 1) {
          // التصنيفات
          Navigator.push(
            context,
            fadeSlideRoute(
              TypesListScreen(
                items: categories,
                title: item.title,
                forShik: false,
                isBooks: false,
              ),
            ),
          );
        } else if (index == 2) {
          // جميع المواد
          Navigator.push(
            context,
            fadeSlideRoute(
              MaterialsListScreen(
                title: item.title,
                levelSel: LevelSel.withLevel(),
                categorySel: CategorySel.all(),
                authorId: null, // لا نحتاج إلى مؤلف هنا
              ),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            fadeSlideRoute(
              TypesListScreen(
                items: instituteLibrary,
                title: item.title,
                forShik: false,
                isBooks: true,
              ),
            ),
          );
        }
      },
    );
  }
}
