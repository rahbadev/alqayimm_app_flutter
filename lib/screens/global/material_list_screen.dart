import 'package:alqayimm_app_flutter/db/main/enums.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/models/main_db/material_model.dart';
import 'package:alqayimm_app_flutter/screens/global/lessons_list_screen.dart';
import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:alqayimm_app_flutter/widget/lists/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: MainItemsListView<MaterialModel>(
        itemsFuture: _fetchMaterials(), // لاحظ تغيير اسم الدالة
        itemBuilder: (item, index) => _buildMaterialItem(context, item),
      ),
    );
  }

  // أضف هذه الدالة لجلب المواد فقط (بدون تحويلها هنا)
  Future<List<MaterialModel>> _fetchMaterials() async {
    final db = await DbHelper.database;
    final repo = Repo(db);

    return await repo.fetchMaterials(
      authorId: authorId,
      levelSel: levelSel,
      categorySel: categorySel,
    );
  }

  MainItem _buildMaterialItem(BuildContext context, MaterialModel material) {
    return MainItem(
      leadingContent: IconLeading(icon: MaterialIcons.my_library_music),
      title: material.name,
      details: [
        if (material.aboutMaterial != null)
          MainItemDetail(
            text: material.aboutMaterial!,
            icon: Icons.info_outline,
            iconColor: Colors.grey,
          ),
      ],
      onItemTap: (item) {
        LessonsListScreen.navigateToScreen(
          context: context,
          materialId: material.id,
          title: material.name,
        );
      },
    );
  }
}
