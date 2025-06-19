import 'package:alqayimm_app_flutter/db/main/enmus.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/models/main_db/type_model.dart';
import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:alqayimm_app_flutter/widget/lists/main_items_list.dart';
import 'package:alqayimm_app_flutter/screens/global/types_list_screen.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';

class ShikScreen extends StatefulWidget {
  const ShikScreen({super.key});
  @override
  State<ShikScreen> createState() => _ShikScreenState();
}

class _ShikScreenState extends State<ShikScreen> {
  List<CategoryModel> booksCategories = [];
  List<CategoryModel> materialsCategories = [];
  int booksCount = 0;
  int materialsCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
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

    setState(() {
      this.booksCategories = booksCategories;
      this.materialsCategories = materialsCategories;
      booksCount = booksCategories.length;
      materialsCount = materialsCategories.length;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return MainItemsList(
      items: [
        MainItem(
          leadingContent: IconLeading(icon: Icons.library_music),
          title: 'دروس الشيخ',
          details: [
            MainItemDetail(
              text: 'عدد الدروس : $materialsCount',
              icon: Icons.music_note,
              iconColor: Colors.pink,
            ),
          ],
        ),
        MainItem(
          leadingContent: IconLeading(icon: Icons.library_books),
          title: 'مكتبة الشيخ',
          details: [
            MainItemDetail(
              text: 'عدد الكتب : $booksCount',
              icon: Icons.book_sharp,
              iconColor: Colors.teal,
            ),
          ],
        ),
      ],
      onItemTap: (item, index) {
        if (index == 0) {
          Navigator.push(
            context,
            fadeSlideRoute(
              TypesListScreen(
                title: item.title,
                items: materialsCategories,
                forShik: true,
                isBooks: false,
              ),
            ),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            fadeSlideRoute(
              TypesListScreen(
                title: item.title,
                items: booksCategories,
                forShik: true,
                isBooks: true,
              ),
            ),
          );
        }
      },
    );
  }
}
