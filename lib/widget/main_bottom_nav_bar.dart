import 'package:alqayimm_app_flutter/widget/icons.dart';
import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:alqayimm_app_flutter/utils/app_strings.dart';

class MainBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const MainBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CircleNavBar(
        activeIcons: const [
          NavBarIcon(icon: AppIcons.notesShrp, isActive: true),
          NavBarIcon(icon: AppIcons.siteSharp, isActive: true),
          NavBarIcon(icon: AppIcons.homeSharp, isActive: true),
          NavBarIcon(icon: AppIcons.searchSharp, isActive: true),
          NavBarIcon(icon: AppIcons.personSharp, isActive: true),
        ],
        inactiveIcons: const [
          NavBarIcon(icon: AppIcons.notesOutline),
          NavBarIcon(icon: AppIcons.siteOutline),
          NavBarIcon(icon: AppIcons.homeOutline),
          NavBarIcon(icon: AppIcons.searchOutline),
          NavBarIcon(icon: AppIcons.personOutline),
        ],
        levels: const [
          AppStrings.navNotes,
          AppStrings.navLocation,
          AppStrings.navHome,
          AppStrings.navSearch,
          AppStrings.navSheikh,
        ],
        color: Theme.of(context).colorScheme.surface,
        circleColor: Theme.of(context).colorScheme.surface,
        height: 75,
        circleWidth: 60,
        activeIndex: selectedIndex,
        onTap: onTap,
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        shadowColor: Theme.of(context).colorScheme.primary.withAlpha(75),
        circleShadowColor: Theme.of(context).colorScheme.primary.withAlpha(75),
        elevation: 8,
      ),
    );
  }
}
