import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/screens/lists/types_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_items_card.dart';
import 'package:alqayimm_app_flutter/widget/icons/icon_main_cv.dart';

class MainCardsScreen extends StatefulWidget {
  const MainCardsScreen({super.key});

  @override
  State<MainCardsScreen> createState() => _MainCardsScreenState();
}

class _MainCardsScreenState extends State<MainCardsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<MainItem> items = [
    MainItem(
      iconWidget: IconWidget(iconData: Icons.library_books),
      title: 'المستويات',
      details: [
        MainItemDetail(
          text: 'عدد المستويات : 5',
          icon: Icons.layers,
          iconColor: Colors.orange,
        ),
        MainItemDetail(
          text: 'عدد المستويات التي أنهيتها : 4',
          icon: Icons.check_circle,
          iconColor: Colors.green,
        ),
        MainItemDetail(
          text: 'آخر درس تم تشغيله : شرح الأصول الثلاثة - 1',
          icon: Icons.play_arrow,
        ),
      ],
    ),
    MainItem(
      iconWidget: IconWidget(iconData: Icons.book),
      title: 'التصنيفات',
      details: [
        MainItemDetail(
          text: 'عدد التصنيفات : 10',
          icon: Icons.category,
          iconColor: Colors.blue,
        ),
        MainItemDetail(
          text: 'آخر تصنيف تم زيارته: كتاب شرح الدرر البهية',
          icon: Icons.history,
        ),
      ],
    ),
    MainItem(
      iconWidget: IconWidget(iconData: Icons.library_books),
      title: 'المشايخ',
      details: [
        MainItemDetail(
          text: 'عدد المشايخ : 12',
          icon: Icons.contacts,
          iconColor: Colors.orange,
        ),
        MainItemDetail(
          text: 'آخر درس تم تشغيله: متن الأصول الثلاثة',
          icon: Icons.play_arrow,
        ),
      ],
    ),
  ];

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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                0.1 * index,
                0.6 + 0.1 * index,
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  0.1 * index,
                  0.6 + 0.1 * index,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                logger.info('Tapped on item: ${items[index].title}');
                final item = items[index];
                if (item.title == 'المستويات') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => const TypesListScreen(
                            groupName: 'المستويات',
                            title: 'المستويات',
                          ),
                    ),
                  );
                } else if (item.title == 'التصنيفات') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => const TypesListScreen(
                            groupName: 'التصنيف',
                            title: 'التصنيفات',
                          ),
                    ),
                  );
                } else if (item.title == 'المشايخ') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => const TypesListScreen(
                            groupName: 'الشيخ',
                            title: 'المشايخ',
                          ),
                    ),
                  );
                }
              },
              child: MainItemCard(item: items[index]),
            ),
          ),
        );
      },
    );
  }
}
