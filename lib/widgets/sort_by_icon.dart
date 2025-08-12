import 'package:flutter/material.dart';

enum SortBy {
  dateDesc("الأحدث أولاً"),
  dateAsc("الأقدم أولاً"),
  titleAsc("حسب الاسم (أ-ي)"),
  titleDesc("حسب الاسم (ي-أ)");

  final String label;
  const SortBy(this.label);
}

class SortByIcon extends StatelessWidget {
  const SortByIcon({
    super.key,
    required this.sortBy,
    required this.onSortChanged,
  });

  final SortBy sortBy;
  final ValueChanged<SortBy> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortBy>(
      initialValue: sortBy,
      icon: Icon(Icons.sort, color: Theme.of(context).colorScheme.onSurface),
      tooltip: "ترتيب حسب",
      onSelected: (value) {
        final newSortBy = SortBy.values.firstWhere((e) => e == value);
        onSortChanged(newSortBy);
      },
      itemBuilder:
          (context) => [
            popupMenuItemBuild(context, SortBy.dateDesc, Icons.access_time),
            popupMenuItemBuild(context, SortBy.dateAsc, Icons.access_time),
            popupMenuItemBuild(context, SortBy.titleAsc, Icons.sort_by_alpha),
            popupMenuItemBuild(context, SortBy.titleDesc, Icons.sort_by_alpha),
          ],
    );
  }
}

PopupMenuItem<SortBy> popupMenuItemBuild(
  BuildContext context,
  SortBy sortBy,
  IconData icon,
) {
  return PopupMenuItem(
    value: sortBy,
    child: Row(children: [Icon(icon), SizedBox(width: 8), Text(sortBy.label)]),
  );
}
