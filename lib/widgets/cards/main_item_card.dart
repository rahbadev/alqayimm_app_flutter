import 'package:alqayimm_app_flutter/widgets/icons.dart';
import 'package:flutter/material.dart';

typedef MainItemTapCallback = void Function(MainItem item);
typedef MainItemDetailTapCallback = void Function(MainItemDetail item);

class MainItem {
  final String title;
  final LeadingContent leadingContent;
  final MainItemTapCallback? onItemTap;
  final List<MainItemDetail>? details;
  final List<Widget>? actions;
  MainItem({
    required this.title,
    required this.leadingContent,
    this.details,
    this.onItemTap,
    this.actions,
  });
}

class MainItemDetail {
  final String text;
  final IconData icon;
  final MainItemDetailTapCallback? onTap;
  final Color iconColor;

  MainItemDetail({
    required this.text,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });
}

class MainItemCard extends StatelessWidget {
  final MainItem mainItem;
  final double titleFontSize;

  const MainItemCard({
    super.key,
    required this.mainItem,
    this.titleFontSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          mainItem.onItemTap != null
              ? () => mainItem.onItemTap!(mainItem)
              : null,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  mainItem.leadingContent.build(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mainItem.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (mainItem.details?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          ..._buildDetails(context, mainItem.details),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (mainItem.actions != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: mainItem.actions ?? [],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetails(
    BuildContext context,
    List<MainItemDetail>? details,
  ) {
    return details!
        .map(
          (detail) => InkWell(
            onTap: detail.onTap != null ? () => detail.onTap!(detail) : null,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(detail.icon, size: 16, color: detail.iconColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      detail.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(180),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}
