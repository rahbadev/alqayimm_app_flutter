import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/widgets/text_fileds.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/action_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/db/user/models/user_bookmark_model.dart';
import 'package:alqayimm_app_flutter/db/user/repos/bookmarks_repository.dart';

/// نافذة حوار لإضافة أو تعديل العلامات المرجعية
class BookmarkDialog extends StatefulWidget {
  final int? id;
  final int? itemId;
  final ItemType? itemType;
  final int? position;
  final String? title;
  final DateTime? createdAt;
  final String? materialName;
  final String? lessonName;
  final String? bookName;
  final bool isEditing;

  /// Constructor رئيسي
  const BookmarkDialog({
    super.key,
    this.id,
    this.itemId,
    this.itemType,
    this.position,
    this.title,
    this.createdAt,
    this.materialName,
    this.lessonName,
    this.bookName,
    this.isEditing = false,
  });

  /// إضافة علامة مرجعية لدرس
  static Future<bool?> showForLesson({
    required BuildContext context,
    required int lessonId,
    int? position,
    String? materialName,
    String? lessonName,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => BookmarkDialog(
            itemId: lessonId,
            itemType: ItemType.lesson,
            position: position,
            materialName: materialName,
            lessonName: lessonName,
            isEditing: false,
          ),
    );
  }

  /// إضافة علامة مرجعية لكتاب
  static Future<bool?> showForBook({
    required BuildContext context,
    required int bookId,
    int? pageNumber,
    String? bookName,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => BookmarkDialog(
            itemId: bookId,
            itemType: ItemType.book,
            position: pageNumber,
            bookName: bookName,
            isEditing: false,
          ),
    );
  }

  /// تعديل علامة مرجعية موجودة
  static Future<bool?> showEdit({
    required BuildContext context,
    required UserBookmarkModel bookmark,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => BookmarkDialog(
            id: bookmark.id,
            itemId: bookmark.itemId,
            itemType: bookmark.itemType,
            position: bookmark.position,
            title: bookmark.title,
            createdAt: bookmark.createdAt,
            isEditing: true,
          ),
    );
  }

  @override
  State<BookmarkDialog> createState() => _BookmarkDialogState();
}

class _BookmarkDialogState extends State<BookmarkDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _positionController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? '');
    _positionController = TextEditingController(
      text: widget.position?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActionDialog(
      headerIcon:
          widget.isEditing ? Icons.edit_outlined : Icons.bookmark_add_outlined,
      title: widget.isEditing ? 'تعديل علامة مرجعية' : 'إضافة علامة مرجعية',
      subtitle:
          widget.isEditing
              ? 'قم بتعديل بيانات العلامة المرجعية'
              : 'أضف علامة مرجعية لحفظ موضعك المفضل',
      confirmText: widget.isEditing ? 'تحديث' : 'حفظ',
      confirmIcon: widget.isEditing ? Icons.edit_rounded : Icons.save_rounded,
      onConfirm: _saveBookmark,
      onCancel: () => Navigator.of(context).pop(false),
      isLoading: _isLoading,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'عنوان العلامة المرجعية',
                hint: 'أدخل عنوان أو وصف للعلامة المرجعية',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال عنوان للعلامة المرجعية';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _positionController,
                label: 'الموضع',
                hint: 'رقم الدقيقة أو رقم الصفحة',
                icon: Icons.location_on,
                keyboardType: TextInputType.number,
              ),
              if (_hasContextInfo()) ...[
                const SizedBox(height: 24),
                _buildContextInfo(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// عرض معلومات السياق إذا كانت متوفرة
  Widget _buildContextInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'معلومات السياق:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.materialName != null && widget.lessonName != null) ...[
            Text('المادة: ${widget.materialName}'),
            Text('الدرس: ${widget.lessonName}'),
          ],
          if (widget.bookName != null) Text('الكتاب: ${widget.bookName}'),
          if (widget.position != null)
            Text(
              widget.itemType == ItemType.lesson
                  ? 'الموضع الحالي: ${widget.position}'
                  : 'الصفحة الحالية: ${widget.position}',
            ),
        ],
      ),
    );
  }

  /// التحقق من وجود معلومات السياق
  bool _hasContextInfo() {
    return widget.materialName != null ||
        widget.lessonName != null ||
        widget.bookName != null;
  }

  /// حفظ العلامة المرجعية
  Future<void> _saveBookmark() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final positionText = _positionController.text.trim();
      final position = positionText.isEmpty ? null : int.tryParse(positionText);
      final now = DateTime.now();

      if (widget.isEditing) {
        // تحديث علامة مرجعية موجودة
        final updatedBookmark = UserBookmarkModel(
          id: widget.id!,
          itemId: widget.itemId!,
          itemType: widget.itemType!,
          position: position,
          title: title,
          createdAt: widget.createdAt ?? now,
        );
        await BookmarksRepository.updateBookmark(updatedBookmark);
      } else {
        // إضافة علامة مرجعية جديدة
        if (widget.itemId == null || widget.itemType == null) {
          throw Exception('يجب تحديد معرف العنصر ونوعه');
        }
        final newBookmark = UserBookmarkModel(
          id: 0,
          itemId: widget.itemId!,
          itemType: widget.itemType!,
          position: position,
          title: title,
          createdAt: now,
        );
        await BookmarksRepository.addBookmark(newBookmark);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        AppToasts.showSuccess(
          title:
              widget.isEditing
                  ? 'تم تحديث العلامة المرجعية بنجاح'
                  : 'تم إضافة العلامة المرجعية بنجاح',
          description: 'يمكنك مراجعة العلامات في قسم العلامات',
        );
      }
    } catch (e) {
      logger.e(
        'Error saving bookmark: $e',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppToasts.showError(
        title:
            widget.isEditing
                ? 'فشل في تحديث العلامة المرجعية'
                : 'فشل في إضافة العلامة المرجعية',
        description: 'يرجى المحاولة مرة أخرى',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
