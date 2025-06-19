import 'package:alqayimm_app_flutter/db/main/enmus.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:alqayimm_app_flutter/widget/lists/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/models/main_db/material_model.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';

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

class _MaterialsListScreenState extends State<MaterialsListScreen> {
  late Future<List<MaterialModel>> _materialsFuture;

  @override
  void initState() {
    super.initState();
    _materialsFuture = _fetchMaterials();
  }

  Future<List<MaterialModel>> _fetchMaterials() async {
    final db = await DbHelper.database;
    final repo = Repo(db);
    return repo.fetchMaterials(
      authorId: widget.authorId,
      levelSel: widget.levelSel,
      categorySel: widget.categorySel,
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _materialsFuture = _fetchMaterials();
    });
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'لا توجد مواد متاحة',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في جلب البيانات',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<MaterialModel>>(
          future: _materialsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final materials = snapshot.data!;
            return MainItemsList(
              items:
                  materials.map((material) {
                    return MainItem(
                      leadingContent: IconLeading(
                        icon: Icons.library_music,
                        color: Colors.teal,
                      ),
                      title: material.name,
                      details: [
                        if (material.aboutMaterial != null)
                          MainItemDetail(
                            text: material.aboutMaterial!,
                            icon: Icons.info_outline,
                            iconColor: Colors.grey,
                          ),
                      ],
                    );
                  }).toList(),
              onItemTap: (item, index) {
                // TODO: Implement material details navigation
              },
            );
          },
        ),
      ),
    );
  }
}
