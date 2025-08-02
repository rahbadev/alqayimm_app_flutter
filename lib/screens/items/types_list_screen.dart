import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:alqayimm_app_flutter/screens/items/lessons_books_screen.dart';
import 'package:alqayimm_app_flutter/screens/items/material_list_screen.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/widgets/cards/main_item_card.dart';
import 'package:alqayimm_app_flutter/widgets/download/download_progress_indicator.dart';
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
        icon: AppIcons.smallCategoryMaterial,
        iconColor: Colors.blue,
      ),
      if (percentage > 0.0)
        MainItemDetail(
          text: 'نسبة الإكمال: ${(percentage * 100).toStringAsFixed(0)}%',
          icon: Icons.check_circle,
          iconColor: Colors.green,
        ),
      // todo
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
              MaterialsListScreen.navigateToScreen(
                context,
                item.title,
                LevelSel.only([type.id]),
                CategorySel.all(),
                widget.forShik ? 27 : null,
              );
            } else if (type is CategoryModel) {
              if (widget.forShik) {
                MaterialsListScreen.navigateToScreen(
                  context,
                  item.title,
                  LevelSel.all(),
                  CategorySel.only([type.id]),
                  27,
                );
              } else {
                MaterialsListScreen.navigateToScreen(
                  context,
                  item.title,
                  LevelSel.withLevel(),
                  CategorySel.only([type.id]),
                  null,
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
    Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [DownloadProgressIndicator()],
      ),
      body: MainItemsListView<MainItem>(
        itemsFuture: widget.items.isEmpty ? Future.value([]) : _mainItemsFuture,
        itemBuilder: (item, index) => item,
      ),
    );
  }
}
