import 'package:flutter/material.dart';
import '../../db/user/models/user_note_model.dart';
import 'action_dialog.dart';

/// مربع حوار معاينة الملاحظة مع أزرار العمليات
class NotePreviewDialog extends StatelessWidget {
  final UserNoteModel note;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const NotePreviewDialog({
    super.key,
    required this.note,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  /// عرض مربع حوار المعاينة
  static Future<String?> show({
    required BuildContext context,
    required UserNoteModel note,
  }) {
    return showDialog<String>(
      context: context,
      builder:
          (context) => NotePreviewDialog(
            note: note,
            onEdit: () => Navigator.of(context).pop('edit'),
            onDelete: () => Navigator.of(context).pop('delete'),
            onShare: () => Navigator.of(context).pop('share'),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActionDialog(
      headerIcon: Icons.visibility_outlined,
      title: 'معاينة الملاحظة',
      subtitle: 'اطّلع على تفاصيل الملاحظة',
      showActions: false, // نخفي الأزرار الافتراضية
      children: [
        _buildActionIconButtons(context),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    note.title.isNotEmpty ? note.title : 'ملاحظة بدون عنوان',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                note.content,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),

        // العلامات (إذا كانت موجودة)
        if (note.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    note.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ],

        // معلومات إضافية
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'تاريخ الإنشاء: ${_formatDate(note.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row _buildActionIconButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton.filled(
          icon: const Icon(Icons.edit_outlined),
          tooltip: "تعديل",
          onPressed: onEdit,
        ),

        IconButton.filled(
          icon: const Icon(Icons.share),
          tooltip: "مشاركة",
          onPressed: () => onShare,
        ),

        IconButton.filled(
          icon: const Icon(Icons.delete_outline),
          tooltip: "حذف",
          onPressed: onDelete,
        ),
        IconButton.filled(
          icon: const Icon(Icons.close),
          tooltip: "إغلاق",
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
