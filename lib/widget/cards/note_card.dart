import 'package:flutter/material.dart';
import '../../db/user/models/user_note_model.dart';

/// ودجيت مخصص لعرض بطاقة الملاحظة
class NoteCard extends StatelessWidget {
  final UserNoteModel note;
  final VoidCallback? onTap;
  final Function(String action)? onActionSelected;
  final EdgeInsetsGeometry? margin;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onActionSelected,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onActionSelected != null)
                    PopupMenuButton<String>(
                      onSelected: onActionSelected!,
                      itemBuilder: (context) => _buildMenuItems(note),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Content
              Text(
                note.content,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Context info and date
              Row(
                children: [
                  // Context indicator
                  _buildGenericIndicator(context),

                  const Spacer(),

                  // Date
                  Text(
                    _formatDate(note.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Tags
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children:
                      note.tags
                          .take(3)
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 10),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenericIndicator(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'ملاحظة عامة',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(UserNoteModel note) {
    return [
      const PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [Icon(Icons.edit), SizedBox(width: 8), Text('تعديل')],
        ),
      ),
      const PopupMenuItem(
        value: 'share_text',
        child: Row(
          children: [
            Icon(Icons.share),
            SizedBox(width: 8),
            Text('مشاركة النص'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
