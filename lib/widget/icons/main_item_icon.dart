import 'package:alqayimm_app_flutter/widget/icons/custom_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

abstract class LeadingContent {
  Widget build(BuildContext context);
}

class IconLeading extends LeadingContent {
  final IconData icon;
  final Color? color;
  final double? size;

  IconLeading({required this.icon, this.color, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 100,
      child: Center(
        child: Card(
          clipBehavior: Clip.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CustomIcon(icon: icon, color: color, size: size),
          ),
        ),
      ),
    );
  }
}

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
      return _buildPlaceholder().build(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder: (_, _) => _buildPlaceholder().build(context),
          errorWidget: (_, _, _) => _buildPlaceholder().build(context),
        ),
      ),
    );
  }

  IconLeading _buildPlaceholder() {
    return IconLeading(icon: placeholderIcon);
  }
}
