// يمكنك وضعها في ملف مشترك مثل: lib/widget/cards/main_item_actions.dart

import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';
import 'package:alqayimm_app_flutter/widget/icons/animated_icon.dart';
import 'package:alqayimm_app_flutter/utils/app_icons.dart';
import 'package:alqayimm_app_flutter/db/main/enums.dart';

List<ActionButton> buildActionButtons({
  required dynamic item, // BookModel أو LessonModel
  VoidCallback? onTapDownload,
  VoidCallback? onTapShare,
  VoidCallback? onTapOpenWith,
  VoidCallback? onTapComplete,
  VoidCallback? onTapFavorite,
  VoidCallback? onTapLinked,
}) {
  final List<ActionButton> actions = [];

  // زر التنزيل/الحذف/إيقاف التنزيل (زر واحد فقط)
  if (onTapDownload != null) {
    actions.add(
      ActionButton(
        buttonWidget: AnimatedIconSwitcher(
          icon: () {
            final status = item.downloadStatus ?? DownloadStatus.notDownloaded;
            switch (status) {
              case DownloadStatus.notDownloaded:
                return Icon(AppIcons.download, key: const ValueKey('download'));
              case DownloadStatus.downloading:
                return SizedBox(
                  key: const ValueKey('progress'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    backgroundColor: Colors.grey[300],
                  ),
                );
              case DownloadStatus.downloaded:
                return Icon(AppIcons.delete, key: const ValueKey('delete'));
              default:
                return Icon(AppIcons.download, key: const ValueKey('download'));
            }
          }(),
        ),
        tooltip: () {
          final status = item.downloadStatus ?? DownloadStatus.notDownloaded;
          switch (status) {
            case DownloadStatus.notDownloaded:
              return 'تنزيل';
            case DownloadStatus.downloading:
              return 'إيقاف التنزيل';
            case DownloadStatus.downloaded:
              return 'حذف';
            default:
              return '';
          }
        }(),
        onTap: (_) => onTapDownload(),
      ),
    );
  }

  // زر المشاركة
  if (onTapShare != null) {
    actions.add(
      ActionButton(
        buttonWidget: const Icon(AppIcons.share),
        tooltip: 'مشاركة',
        onTap: (_) => onTapShare(),
      ),
    );
  }

  // زر فتح باستخدام
  if (onTapOpenWith != null) {
    actions.add(
      ActionButton(
        buttonWidget: const Icon(AppIcons.openInNew),
        tooltip: 'فتح باستخدام',
        onTap: (_) => onTapOpenWith(),
      ),
    );
  }

  // زر الإكمال
  if (onTapComplete != null) {
    actions.add(
      ActionButton(
        buttonWidget: AnimatedIconSwitcher(
          icon: Icon(
            item.isCompleted == true
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            key: ValueKey(item.isCompleted == true),
            color: item.isCompleted == true ? Colors.green : null,
          ),
        ),
        tooltip: item.isCompleted == true ? 'تم الإكمال' : 'لم يتم الإكمال',
        onTap: (_) => onTapComplete(),
      ),
    );
  }

  // زر المفضلة
  if (onTapFavorite != null) {
    actions.add(
      ActionButton(
        buttonWidget: AnimatedIconSwitcher(
          icon: Icon(
            item.isFavorite == true ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(item.isFavorite == true),
            color: item.isFavorite == true ? Colors.red : null,
          ),
        ),
        tooltip:
            item.isFavorite == true ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
        onTap: (_) => onTapFavorite(),
      ),
    );
  }

  // زر العناصر المرتبطة
  if (onTapLinked != null) {
    actions.add(
      ActionButton(
        buttonWidget: const Icon(Icons.link),
        tooltip: 'عناصر مرتبطة',
        onTap: (_) => onTapLinked(),
      ),
    );
  }

  return actions;
}
