import 'package:alqayimm_app_flutter/widget/icons/animated_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

/// ثوابت أيقونات التطبيق (للاستخدام الموحد)
class AppIcons {
  static const mainLevels = Ionicons.md_layers;
  static const smallLevel = Icons.stacked_bar_chart;
  static const itemLevel = Icons.layers;
  static const mainBooksLibrary = Ionicons.md_library;
  static const smallCategoryBook = FontAwesome.book;
  static const itemCategoryBook = MaterialCommunityIcons.bookshelf;
  static const mainCategoryMaterial = FontAwesome5Solid.swatchbook;
  static const smallCategoryMaterial = Icons.topic;
  static const itemCategoryMaterial = mainMaterials;
  static const mainMaterials = Icons.library_music;
  static const smallMaterials = MaterialCommunityIcons.music_box;
  static const book = FontAwesome.book;
  static const lessonItem = Fontisto.applemusic;
  static const download = Icons.download;
  static const downloading = Icons.downloading;
  static const delete = Icons.delete;
  static const share = Icons.share;
  static const openInNew = Icons.open_in_new;
  static const number = Icons.numbers;
  static const author = FontAwesome.user;
  static const percentage = Icons.check_circle;

  static const homeOutline = Ionicons.ios_home_outline;
  static const homeSharp = Ionicons.ios_home_sharp;
  static const searchOutline = Ionicons.md_search_outline;
  static const searchSharp = Ionicons.md_search_sharp;
  static const personOutline = Ionicons.md_person_outline;
  static const personSharp = Ionicons.md_person_sharp;
  static const siteOutline = Ionicons.md_globe_outline;
  static const siteSharp = Ionicons.md_globe_sharp;
  static const bookmarkOutline = Ionicons.md_bookmark_outline;
  static const bookmarkSharp = Ionicons.md_bookmark_sharp;
  static const notesShrp = MaterialCommunityIcons.note_edit;
  static const notesOutline = MaterialCommunityIcons.note_edit_outline;
  static const warning = Ionicons.md_warning_outline;
}

/// ودجيت أيقونة داخل Card مع خيارات متعددة للتخصيص
class IconCard extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool useThemeColors;

  const IconCard({
    super.key,
    required this.icon,
    this.size = 24,
    this.iconColor,
    this.backgroundColor,
    this.padding,
    this.borderRadius = 8,
    this.useThemeColors = true,
  });

  /// Constructor للحالة الأساسية (primary theme)
  const IconCard.primary({
    super.key,
    required this.icon,
    this.size = 24,
    this.padding,
    this.borderRadius = 8,
  }) : iconColor = null,
       backgroundColor = null,
       useThemeColors = true;

  /// Constructor للحالة الثانوية (secondary theme)
  const IconCard.secondary({
    super.key,
    required this.icon,
    this.size = 24,
    this.padding,
    this.borderRadius = 8,
  }) : iconColor = null,
       backgroundColor = null,
       useThemeColors = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color effectiveBackgroundColor;
    Color effectiveIconColor;

    if (useThemeColors) {
      effectiveBackgroundColor =
          backgroundColor ?? theme.colorScheme.onPrimaryContainer;
      effectiveIconColor = iconColor ?? theme.colorScheme.primaryContainer;
    } else {
      effectiveBackgroundColor =
          backgroundColor ?? theme.colorScheme.secondaryContainer;
      effectiveIconColor = iconColor ?? theme.colorScheme.onSecondaryContainer;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: effectiveBackgroundColor,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(8.0),
        child: Icon(icon, color: effectiveIconColor, size: size),
      ),
    );
  }
}

/// أيقونة SVG من الأصول مع دعم اللون والحجم
class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double? size;
  final Color? color;
  final BoxFit fit;
  const SvgIcon({
    super.key,
    required this.assetPath,
    this.size,
    this.color,
    this.fit = BoxFit.contain,
  });
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    assetPath.startsWith('assets/') ? assetPath : 'assets/icons/$assetPath',
    width: size,
    height: size,
    colorFilter:
        color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    fit: fit,
  );
}

/// LeadingContent: أيقونة أو صورة جانبية للقوائم/البطاقات
abstract class LeadingContent {
  Widget build(BuildContext context);
}

/// أيقونة Leading (جانبية)
class IconLeading extends LeadingContent {
  final IconData icon;
  final Color? color;
  final double? size;

  IconLeading({required this.icon, this.color, this.size = 28});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 70,
    height: 100,
    child: Center(
      child: Card(
        clipBehavior: Clip.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Theme.of(context).colorScheme.surfaceContainer,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(
            icon,
            color: color ?? Theme.of(context).colorScheme.primary,
            size: size,
          ),
        ),
      ),
    ),
  );
}

/// صورة Leading من الشبكة أو أيقونة بديلة
class ImageLeading extends LeadingContent {
  final String? imageUrl;
  final IconData placeholderIcon;
  final double width;
  final double height;

  ImageLeading({
    required this.imageUrl,
    required this.placeholderIcon,
    this.width = 70,
    this.height = 100,
  });
  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return IconLeading(icon: placeholderIcon).build(context);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder:
              (_, _) => IconLeading(icon: placeholderIcon).build(context),
          errorWidget:
              (_, _, _) => IconLeading(icon: placeholderIcon).build(context),
        ),
      ),
    );
  }
}

/// أيقونة شريط التنقل السفلي (تدعم أيقونة أو صورة)
class NavBarIcon extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final bool isActive;
  const NavBarIcon({
    super.key,
    this.icon,
    this.assetPath,
    this.isActive = false,
  }) : assert(icon != null || assetPath != null, 'يجب تحديد أيقونة أو صورة');
  @override
  Widget build(BuildContext context) {
    final color =
        isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withAlpha(160);
    if (icon != null) {
      return Icon(icon, color: color, size: 28);
    } else {
      return Image.asset(
        assetPath!,
        width: 32,
        height: 32,
        color: isActive ? null : Colors.grey, // لون باهت عند عدم التفعيل
      );
    }
  }
}
