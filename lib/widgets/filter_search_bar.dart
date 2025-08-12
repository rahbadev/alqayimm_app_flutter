import 'package:alqayimm_app_flutter/widgets/filter_chip.dart';
import 'package:alqayimm_app_flutter/widgets/search_field.dart';
import 'package:alqayimm_app_flutter/widgets/sort_by_icon.dart';
import 'package:flutter/cupertino.dart';

class FilterSearchBar extends StatelessWidget {
  const FilterSearchBar({
    super.key,
    required this.searchField,
    required this.filterChipsWidget,
    required this.sortByIcon,
  });

  final SearchField searchField;
  final FilterChipsWidget filterChipsWidget;
  final SortByIcon sortByIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // شريط البحث
        Row(children: [Expanded(child: searchField), sortByIcon]),
        // قائمة العلامات
        filterChipsWidget,
        // شريط الفلاتر والترتيب
      ],
    );
  }
}
