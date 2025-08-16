import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/db/user/models/user_bookmark_model.dart';
import 'package:alqayimm_app_flutter/screens/player/audio_controls.dart';
import 'package:alqayimm_app_flutter/theme/theme.dart';
import 'package:alqayimm_app_flutter/widgets/icons.dart';
import 'package:flutter/material.dart';

class BookmarkItemCard extends StatelessWidget {
  final BaseContentModel item;
  final List<UserBookmarkModel> bookmarks;
  final Function(UserBookmarkModel) onTap;
  final Function(UserBookmarkModel) onEdit;
  final Function(UserBookmarkModel) onDelete;

  const BookmarkItemCard({
    super.key,
    required this.item,
    required this.bookmarks,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isBook = item is BookModel;
    final icon = isBook ? AppIcons.bookmarkBook : AppIcons.bookmarkLesson;
    final color =
        isBook ? MaterialTheme.warning(context) : MaterialTheme.info(context);
    final title =
        item is LessonModel
            ? (item as LessonModel).materialName ?? item.name
            : item.name;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: IconLeading(icon: icon, size: 24, color: color).build(context),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.authorName ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.right,
              ),
              Row(
                children: [
                  Chip(
                    label: Text(
                      '${bookmarks.length} علامة',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                    backgroundColor: color.withValues(alpha: 0.12),
                    avatar: Icon(Icons.bookmark, size: 16, color: color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        children: [
          ListView.builder(
            itemBuilder: (_, index) {
              final bookmark = bookmarks[index];
              return _buildBookmarkTile(
                context,
                item,
                bookmark,
                onTap,
                onEdit,
                onDelete,
                color,
              );
            },
            itemCount: bookmarks.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ],
      ),
    );
  }
}

// بناء عنصر العلامة المرجعية داخل المجموعة
Widget _buildBookmarkTile(
  BuildContext context,
  BaseContentModel item,
  UserBookmarkModel bookmark,
  Function(UserBookmarkModel) onTap,
  Function(UserBookmarkModel) onEdit,
  Function(UserBookmarkModel) onDelete,
  Color color,
) {
  final isBook = bookmark.itemType == ItemType.book;

  return InkWell(
    onTap: () => onTap(bookmark),
    borderRadius: BorderRadius.circular(8),
    child: Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // خط ملون كمؤشر
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.5), color],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // محتوى العلامة المرجعية
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isBook ? Icons.pageview : Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatPosition(item, bookmark),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(bookmark.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // أزرار الإجراءات
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: Colors.orange,
                  onPressed: () => onEdit(bookmark),
                ),
                const SizedBox(width: 4),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: Colors.red,
                  onPressed: () => onDelete(bookmark),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildActionButton({
  required IconData icon,
  required Color color,
  required VoidCallback onPressed,
}) {
  return IconButton(
    iconSize: 18,
    onPressed: onPressed,
    icon: Icon(icon, color: color),
  );
}

// تنسيق التاريخ
String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date).inDays;

  if (difference == 0) {
    return 'اليوم';
  } else if (difference == 1) {
    return 'أمس';
  } else if (difference < 7) {
    return 'منذ $difference أيام';
  } else if (difference < 30) {
    final weeks = (difference / 7).floor();
    return 'منذ $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// تنسيق موضع العلامة المرجعية
String _formatPosition(BaseContentModel item, UserBookmarkModel bookmark) {
  if (item is BookModel) {
    return 'الصفحة ${bookmark.position}';
  } else if (item is LessonModel) {
    final position = AudioControls.formatPosition(bookmark.position);
    return '${item.name} $position';
  }
  return '';
}
