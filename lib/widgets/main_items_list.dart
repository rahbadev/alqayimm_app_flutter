import 'package:alqayimm_app_flutter/widgets/dialogs/empty_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/widgets/cards/main_item_card.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MainItemsFuture extends StatelessWidget {
  final Future<List<MainItem>> itemsFuture;
  final double titleFontSize;

  const MainItemsFuture({
    super.key,
    required this.itemsFuture,
    this.titleFontSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MainItem>>(
      future: itemsFuture,
      builder: (context, snapshot) {
        final connectionState = snapshot.connectionState;
        return MainItemsList(
          items: snapshot.data ?? [],
          titleFontSize: titleFontSize,
          isLoading: connectionState == ConnectionState.waiting,
        );
      },
    );
  }
}

class MainItemsList extends StatelessWidget {
  final List<MainItem> items;
  final double titleFontSize;
  final bool isLoading;
  final bool? isEmpty;

  const MainItemsList({
    super.key,
    required this.items,
    this.titleFontSize = 30,
    required this.isLoading,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingEmptyListScreen(
      isLoading: isLoading,
      isEmpty: isEmpty ?? items.isEmpty,
      title: 'لا توجد عناصر',
      desc: 'لم يتم العثور على أي عناصر لعرضها.',
      icon: Icons.info_outline,
      childWidget: _buildList(),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: MainItemCard(
                mainItem: items[index],
                titleFontSize: titleFontSize,
              ),
            ),
          ),
        );
      },
    );
  }
}
