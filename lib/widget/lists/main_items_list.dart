import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MainItemsListView<T> extends StatelessWidget {
  final Future<List<T>>? itemsFuture;
  final List<T>? items;
  final MainItem Function(T item, int index) itemBuilder;
  final String emptyText;
  final double titleFontSize;

  const MainItemsListView({
    super.key,
    this.itemsFuture,
    this.items,
    required this.itemBuilder,
    this.emptyText = 'لا توجد بيانات',
    this.titleFontSize = 30,
  }) : assert(itemsFuture != null || items != null);

  @override
  Widget build(BuildContext context) {
    Widget buildList(List<T> data) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: AnimationLimiter(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: MainItemCard(
                      mainItem: itemBuilder(data[index], index),
                      titleFontSize: titleFontSize,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    if (itemsFuture != null) {
      return FutureBuilder<List<T>>(
        future: itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ في جلب البيانات'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return Center(child: Text(emptyText));
          }
          return buildList(data);
        },
      );
    } else if (items != null) {
      if (items!.isEmpty) {
        return Center(child: Text(emptyText));
      }
      return buildList(items!);
    }
    return const SizedBox.shrink();
  }
}
