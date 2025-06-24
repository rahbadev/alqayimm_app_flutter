import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:alqayimm_app_flutter/utils/app_strings.dart';
import 'package:alqayimm_app_flutter/widget/icons/button_nav_bar_icon.dart';

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
          NavBarIcon(icon: Icons.bookmark, isActive: true),
          NavBarIcon(icon: Icons.public, isActive: true),
          NavBarIcon(icon: Icons.home, isActive: true),
          NavBarIcon(icon: Icons.search, isActive: true),
          NavBarIcon(icon: Icons.person, isActive: true),
        ],
        inactiveIcons: const [
          NavBarIcon(icon: Icons.bookmark),
          NavBarIcon(icon: Icons.public),
          NavBarIcon(icon: Icons.home),
          NavBarIcon(icon: Icons.search),
          NavBarIcon(icon: Icons.person),
        ],
        levels: const [
          AppStrings.navBookmarks,
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
