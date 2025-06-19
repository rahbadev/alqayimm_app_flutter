import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

typedef MainItemTapCallback = void Function(MainItem item, int index);

class MainItemsList extends StatefulWidget {
  final List<MainItem> items;
  final MainItemTapCallback? onItemTap;
  final double titleFontSize;

  const MainItemsList({
    super.key,
    required this.items,
    this.onItemTap,
    this.titleFontSize = 30,
  });

  @override
  State<MainItemsList> createState() => _MainItemsListState();
}

class _MainItemsListState extends State<MainItemsList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: AnimationLimiter(
        child: ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: MainItemCard(
                    mainItem: widget.items[index],
                    titleFontSize: widget.titleFontSize,
                    onTap:
                        () =>
                            widget.onItemTap?.call(widget.items[index], index),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
