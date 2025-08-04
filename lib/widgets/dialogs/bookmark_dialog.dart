import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/screens/player/audio_controls.dart';
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
  final ItemType itemType;
  final int itemId;
  final int position;
  final String? title;
  final DateTime? createdAt;
  final bool isEditing;

  /// Constructor رئيسي
  const BookmarkDialog({
    super.key,
    this.id,
    required this.itemType,
    required this.itemId,
    required this.position,
    this.title,
    this.createdAt,
    this.isEditing = false,
  });

  /// إضافة علامة مرجعية لدرس
  static Future<bool?> showForLesson({
    required BuildContext context,
    required LessonModel lesson,
    required int position,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => BookmarkDialog(
            itemId: lesson.id,
            itemType: ItemType.lesson,
            position: position,
            isEditing: false,
          ),
    );
  }

  /// إضافة علامة مرجعية لكتاب
  static Future<bool?> showForBook({
    required BuildContext context,
    required BookModel book,
    required int pageNumber,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => BookmarkDialog(
            itemId: book.id,
            itemType: ItemType.book,
            position: pageNumber,
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
            position: bookmark.position,
            itemType: bookmark.itemType,
            itemId: bookmark.itemId,
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
      text:
          widget.itemType == ItemType.lesson
              ? AudioControls.formatDuration(
                Duration(milliseconds: widget.position),
              )
              : 'الصفحة: ${widget.position}',
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
                enabled: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// حفظ العلامة المرجعية
  Future<void> _saveBookmark() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final positionText = _positionController.text.trim();
      final position =
          positionText.isEmpty ? 0 : int.tryParse(positionText) ?? 0;
      final now = DateTime.now();

      if (widget.isEditing) {
        // تحديث علامة مرجعية موجودة
        final updatedBookmark = UserBookmarkModel(
          id: widget.id!,
          itemId: widget.id!,
          itemType: widget.itemType,
          position: position,
          title: title,
          createdAt: widget.createdAt ?? now,
        );
        await BookmarksRepository.updateBookmark(updatedBookmark);
      } else {
        // إضافة علامة مرجعية جديدة
        final newBookmark = UserBookmarkModel(
          id: 0,
          itemId: widget.id!,
          itemType: widget.itemType,
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
