import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:flutter/material.dart';

typedef MainItemTapCallback = void Function(MainItem item);
typedef MainItemDetailTapCallback = void Function(MainItemDetail item);

class MainItem {
  final String title;
  final LeadingContent leadingContent;
  final MainItemTapCallback? onItemTap;
  final List<MainItemDetail>? details;
  final List<ActionButton>? actions;
  final MenuButton? menuButton;
  MainItem({
    required this.title,
    required this.leadingContent,
    this.details,
    this.onItemTap,
    this.actions,
    this.menuButton,
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

class ActionButton {
  final Widget buttonWidget;
  final MainItemTapCallback onTap;
  final String? tooltip;

  ActionButton({required this.buttonWidget, required this.onTap, this.tooltip});
}

class MenuButton {
  final IconData icon;
  final List<MenuOption> options;
  final Function(MenuOption) onSelected;

  MenuButton({
    this.icon = Icons.more_vert,
    required this.options,
    required this.onSelected,
  });
}

class MenuOption {
  final String label;
  final IconData? icon;

  const MenuOption({required this.label, this.icon});
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
        margin: const EdgeInsets.only(bottom: 8),
        color: Theme.of(context).colorScheme.onPrimary,
        elevation: 3,
        shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
              if (mainItem.actions != null || mainItem.menuButton != null) ...[
                _buildActionsRow(
                  context,
                  mainItem.actions,
                  mainItem.menuButton,
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

  Widget _buildActionsRow(
    BuildContext context,
    List<ActionButton>? actions,
    MenuButton? menuButton,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (actions != null)
          ...actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: action.buttonWidget,
                onPressed: () => action.onTap(mainItem),
                tooltip: action.tooltip,
              ),
            ),
          ),

        if (menuButton != null)
          PopupMenuButton<MenuOption>(
            onSelected: menuButton.onSelected,
            itemBuilder:
                (context) =>
                    menuButton.options
                        .map(
                          (option) => PopupMenuItem(
                            value: option,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
            icon: Icon(menuButton.icon, size: 22),
          ),
      ],
    );
  }
}
