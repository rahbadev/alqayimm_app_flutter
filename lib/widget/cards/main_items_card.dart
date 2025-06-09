import 'package:flutter/material.dart';

class MainItem {
  final Widget iconWidget;
  final String title;
  final List<MainItemDetail>? details;
  final Color? titleColor;

  MainItem({
    required this.iconWidget,
    required this.title,
    this.details,
    this.titleColor,
  });
}

class MainItemDetail {
  final String? text;
  final Widget? textWidget;
  final IconData icon;
  final Color? iconColor;

  MainItemDetail({
    this.text,
    this.textWidget,
    required this.icon,
    this.iconColor,
  });
}

class MainItemCard extends StatelessWidget {
  final MainItem item;
  const MainItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.onPrimary,
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // زاوية دائرية 8
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // كرت صغير للأيقونة
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Theme.of(context).colorScheme.surfaceContainer,
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: item.iconWidget,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color:
                          item.titleColor ??
                          Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (item.details != null)
                    ...item.details!.map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              d.icon,
                              color:
                                  d.iconColor ??
                                  Theme.of(context).colorScheme.onSurface,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child:
                                  d.textWidget ??
                                  Text(
                                    d.text ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withAlpha(150),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
