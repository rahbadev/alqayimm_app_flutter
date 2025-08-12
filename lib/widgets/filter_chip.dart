import 'package:flutter/material.dart';

typedef FilterChipItem = (String label, bool isSelected, IconData? icon);

class FilterChipsWidget extends StatelessWidget {
  const FilterChipsWidget({
    super.key,
    required this.items,
    required this.onSelected,
    this.singleSelect = false,
  });

  final List<FilterChipItem> items;
  final void Function(List<FilterChipItem>) onSelected;
  final bool singleSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: StatefulBuilder(
        builder: (context, setState) {
          List<FilterChipItem> chips = List.from(items);
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: chips.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final (label, isSelected, icon) = chips[index];
              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (singleSelect) {
                      // تحديد واحد فقط
                      for (var i = 0; i < chips.length; i++) {
                        chips[i] = (
                          chips[i].$1,
                          i == index ? selected : false,
                          chips[i].$3,
                        );
                      }
                    } else {
                      // تحديد متعدد
                      chips[index] = (label, selected, icon);
                    }
                  });
                  onSelected(chips);
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                checkmarkColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                labelStyle: TextStyle(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final FilterChipItem item;
  final void Function(FilterChipItem) onSelected;
  const FilterChipWidget({
    super.key,
    required this.item,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final (label, isSelected, icon) = item;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon), const SizedBox(width: 4)],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        onSelected((label, selected, icon));
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color:
            isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
