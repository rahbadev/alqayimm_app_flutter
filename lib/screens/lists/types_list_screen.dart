import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/db/models/type_model.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_items_card.dart';
import 'package:alqayimm_app_flutter/widget/icons/icon_main_cv.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/db_helper.dart';
import 'package:alqayimm_app_flutter/db/db_queries.dart';
import 'package:shimmer/shimmer.dart';

class TypesListScreen extends StatefulWidget {
  final String groupName; // 'المستويات' أو 'التصنيفات'
  final String title; // عنوان الشاشة

  const TypesListScreen({
    super.key,
    required this.groupName,
    required this.title,
  });

  @override
  State<TypesListScreen> createState() => _TypesListScreenState();
}

class _TypesListScreenState extends State<TypesListScreen> {
  late Future<List<TypeModel>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _fetchItems();
  }

  Future<List<TypeModel>> _fetchItems() async {
    logger.info('Fetching items for group: ${widget.groupName}');
    final db = await DbHelper.database;
    final queries = DbQueries(db);
    return await queries.getTypesByGroup(widget.groupName);
  }

  // دالة لجلب تفاصيل النوع (مستوى/تصنيف)
  Future<List<MainItemDetail>> _getTypeDetails(int typeId) async {
    final db = await DbHelper.database;
    final queries = DbQueries(db);

    final subjectsCount = await queries.getSubjectsCountForType(typeId);
    final finishedCount = await queries.getFinishedSubjectsForType(typeId);
    final lastPlayed = await queries.getLastPlayedForType(typeId);

    return [
      MainItemDetail(
        text: 'عدد المواد: $subjectsCount',
        icon: Icons.library_books,
        iconColor: Colors.orange,
      ),
      MainItemDetail(
        text: 'قمت بإنهاء: $finishedCount',
        icon: Icons.check_circle,
        iconColor: Colors.green,
      ),
      MainItemDetail(
        text: 'آخر درس تم تشغيله: ${lastPlayed ?? "-"}',
        icon: Icons.play_arrow,
      ),
    ];
  }

  // ويدجت shimmer لعنصر القائمة
  Widget _shimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: SizedBox(
          height: 90,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 18, color: Colors.white),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(width: 80, height: 12, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ويدجت shimmer لتفاصيل العنصر
  Widget _shimmerDetail() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(height: 12, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<TypeModel>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.warning('Error fetching items: ${snapshot.error}');
            return Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            // shimmer أثناء تحميل القائمة
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => _shimmerCard(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا يوجد بيانات'));
          }
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return FutureBuilder<List<MainItemDetail>>(
                future: _getTypeDetails(item.id),
                builder: (context, detailsSnapshot) {
                  List<MainItemDetail>? details;
                  bool loading =
                      detailsSnapshot.connectionState ==
                      ConnectionState.waiting;
                  if (!loading && detailsSnapshot.hasData) {
                    details = detailsSnapshot.data;
                  }

                  return MainItemCard(
                    item: MainItem(
                      iconWidget: IconWidget(iconData: Icons.category),
                      title: item.name,
                      details:
                          loading
                              ? [
                                MainItemDetail(
                                  textWidget: _shimmerDetail(),
                                  icon: Icons.library_books,
                                  iconColor: Colors.orange,
                                ),
                                MainItemDetail(
                                  textWidget: _shimmerDetail(),
                                  icon: Icons.check_circle,
                                  iconColor: Colors.green,
                                ),
                                MainItemDetail(
                                  textWidget: _shimmerDetail(),
                                  icon: Icons.play_arrow,
                                ),
                              ]
                              : details,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
