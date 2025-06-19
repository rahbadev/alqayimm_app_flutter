import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:flutter/material.dart';

class MainItem {
  final String title;
  final LeadingContent leadingContent;
  final List<MainItemDetail>? details;

  MainItem({required this.title, required this.leadingContent, this.details});
}

class MainItemDetail {
  final String text;
  final IconData icon;
  final Color iconColor;

  MainItemDetail({
    required this.text,
    required this.icon,
    required this.iconColor,
  });
}

class MainItemCard extends StatelessWidget {
  final MainItem mainItem;
  final List<ActionButton>? actions;
  final MenuButton? menuButton;
  final VoidCallback onTap;
  final double titleFontSize;

  const MainItemCard({
    super.key,
    required this.mainItem,
    this.actions,
    this.menuButton,
    required this.onTap,
    this.titleFontSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: Theme.of(context).colorScheme.onPrimary,
        elevation: 3,
        shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(200),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18), // زاوية دائرية 8
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // المحتوى الأمامي (أيقونة/صورة)
              mainItem.leadingContent.build(context),
              const SizedBox(width: 12),
              // المحتوى الرئيسي
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان
                    Text(
                      mainItem.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // التفاصيل
                    if (mainItem.details != null &&
                        mainItem.details!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ..._buildDetails(context),
                    ],

                    // الأزرار والتحكمات
                    if (actions != null || menuButton != null) ...[
                      const SizedBox(height: 12),
                      _buildActionsRow(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetails(BuildContext context) {
    return mainItem.details!
        .map(
          (detail) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(detail.icon, size: 16, color: detail.iconColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    detail.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(180),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (actions != null)
          ...actions!.map(
            (action) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(action.icon, size: 22, color: action.iconColor),
                onPressed: action.onPressed,
                tooltip: action.tooltip,
              ),
            ),
          ),

        if (menuButton != null)
          PopupMenuButton<MenuOption>(
            onSelected: menuButton!.onSelected,
            itemBuilder:
                (context) =>
                    menuButton!.options
                        .map(
                          (option) => PopupMenuItem(
                            value: option,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
            icon: Icon(menuButton!.icon, size: 22),
          ),
      ],
    );
  }
}

/// زر إجراء
class ActionButton {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? iconColor;

  ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.iconColor,
  });
}

/// زر القائمة المنبثقة
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

/// خيار القائمة
class MenuOption {
  final String label;
  final IconData? icon;

  const MenuOption({required this.label, this.icon});
}
