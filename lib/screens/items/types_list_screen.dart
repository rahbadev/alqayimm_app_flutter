import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:alqayimm_app_flutter/screens/items/lessons_books_screen.dart';
import 'package:alqayimm_app_flutter/screens/items/material_list_screen.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/widgets/cards/main_item_card.dart';
import 'package:alqayimm_app_flutter/widgets/download/global_download_indicator.dart';
import 'package:alqayimm_app_flutter/widgets/icons.dart';
import 'package:alqayimm_app_flutter/widgets/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/models/type_model.dart';
import 'package:alqayimm_app_flutter/main.dart'; // تأكد أن لديك RouteObserver هنا

class TypesListScreen extends StatefulWidget {
  final List<TypeModel> items;
  final String title;
  final bool forShik;
  final bool isBooks;
  final IconData icon;

  const TypesListScreen({
    super.key,
    required this.items,
    required this.title,
    required this.forShik,
    required this.isBooks,
    required this.icon,
  });

  @override
  State<TypesListScreen> createState() => _TypesListScreenState();

  static void navigateToScreen(
    BuildContext context,
    String title,
    List<TypeModel> types,
    bool forShik,
    bool? isBooks,
    IconData icon,
  ) {
    Navigator.of(context, rootNavigator: true).push(
      fadeSlideRoute(
        TypesListScreen(
          title: title,
          items: types,
          forShik: forShik,
          isBooks: isBooks ?? false,
          icon: icon,
        ),
      ),
    );
  }
}

class _TypesListScreenState extends State<TypesListScreen> with RouteAware {
  late Future<List<MainItem>> _mainItemsFuture;

  @override
  void initState() {
    super.initState();
    _mainItemsFuture = _getMainItems(context);
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
    // تم الرجوع لهذه الشاشة، أعد تحميل البيانات
    setState(() {
      _mainItemsFuture = _getMainItems(context);
    });
  }

  Future<List<MainItemDetail>> _getTypeDetails(TypeModel type) async {
    double percentage = 0.0;
    if (!widget.forShik && !widget.isBooks) {
      percentage = switch (type) {
        LevelModel() => await UserItemStatusRepository.getCompletionPercentage(
          levelId: type.id,
        ),
        CategoryModel() =>
          await UserItemStatusRepository.getCompletionPercentage(
            categoryId: type.id,
          ),
        // يمكنك إضافة حالات أخرى إذا كان عندك أنواع أخرى
        _ => 0.0, // في حال لم يكن النوع Level أو Category
      };
    }

    return [
      MainItemDetail(
        text:
            (widget.isBooks ? 'عدد الكتب: ' : 'عدد المواد: ') +
            type.childCount.toString(),
        icon: AppIcons.number,
        iconColor: Colors.orange,
      ),
      if (percentage > 0.0)
        MainItemDetail(
          text: 'قمت بإنهاء: ${(percentage * 100).toStringAsFixed(0)}%',
          icon: Icons.check_circle,
          iconColor: Colors.green,
        ),
      // MainItemDetail(
      //   text:
      //       (isBooks ? 'أخر ما تم فتحه: ' : 'آخر ما تم تشغيله: ') +
      //       lastPlayed.toString(),
      //   icon: Icons.play_arrow,
      //   iconColor: Colors.blue,
      // ),
    ];
  }

  Future<List<MainItem>> _getMainItems(BuildContext context) async {
    return Future.wait(
      widget.items.map((type) async {
        final details = await _getTypeDetails(type);
        final icon = type.icon ?? widget.icon;
        final title = type.name;
        return MainItem(
          leadingContent: IconLeading(icon: icon),
          title: title,
          details: details,
          onItemTap: (item) {
            if (widget.isBooks) {
              LessonsBooksScreen.navigateToScreen(
                context: context,
                screenType: ScreenType.books,
                title: item.title,
                categorySel:
                    widget.forShik
                        ? CategorySel.only([type.id])
                        : CategorySel.all(),
                bookTypeSel:
                    widget.forShik
                        ? BookTypeSel.all()
                        : BookTypeSel.only([type.id]),
                authorId: widget.forShik ? 27 : null,
              );
            } else if (type is LevelModel) {
              Navigator.push(
                context,
                fadeSlideRoute(
                  MaterialsListScreen(
                    title: item.title,
                    levelSel: LevelSel.only([type.id]),
                    categorySel: CategorySel.all(),
                    authorId: widget.forShik ? 27 : null,
                  ),
                ),
              );
            } else if (type is CategoryModel) {
              if (widget.forShik) {
                Navigator.push(
                  context,
                  fadeSlideRoute(
                    MaterialsListScreen(
                      title: item.title,
                      levelSel: LevelSel.all(),
                      categorySel: CategorySel.only([type.id]),
                      authorId: 27,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  fadeSlideRoute(
                    MaterialsListScreen(
                      title: item.title,
                      levelSel: LevelSel.withLevel(),
                      categorySel: CategorySel.only([type.id]),
                      authorId: null,
                    ),
                  ),
                );
              }
            }
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlobalDownloadIndicator(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: MainItemsListView<MainItem>(
          itemsFuture:
              widget.items.isEmpty ? Future.value([]) : _mainItemsFuture,
          itemBuilder: (item, index) => item,
        ),
      ),
    );
  }

  bool shouldShowCompletionPercentage({
    required bool forBooks,
    required bool forShik,
    LevelSel? levelSel,
    CategorySel? categorySel,
  }) {
    // لا نظهر النسبة إذا كان للشيخ أو للكتب
    if (forBooks == true || forShik == true) return false;

    // إذا كان المستوى هو withLevel() والتصنيف all أو لم يتم تخصيصه
    if (levelSel is LevelWith &&
        (categorySel == null || categorySel is CatAll)) {
      return true;
    }

    // إذا كان فقط levelSel هو withLevel()
    if (levelSel is LevelWith && categorySel == null) {
      return true;
    }

    // إذا كان فقط categorySel هو all
    if (categorySel is CatAll && (levelSel == null || levelSel is LevelWith)) {
      return true;
    }

    return false;
  }
}
