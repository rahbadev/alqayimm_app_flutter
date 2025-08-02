import 'package:alqayimm_app_flutter/widgets/containers.dart';
import 'package:alqayimm_app_flutter/widgets/switchs.dart';
import 'package:alqayimm_app_flutter/widgets/text_fileds.dart';
import 'package:alqayimm_app_flutter/widgets/toasts.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/action_dialog.dart';
import 'package:flutter/material.dart';
import '../../db/user/models/user_note_model.dart';
import '../../db/user/repos/user_notes_repository.dart';

class NoteDialog extends StatefulWidget {
  final int? noteId;
  final String? noteTitle;
  final String? noteContent;
  final String? source;
  final List<String>? tags;

  const NoteDialog({
    super.key,
    this.noteId,
    this.noteTitle,
    this.noteContent,
    this.source,
    this.tags,
  });

  static Future<bool?> showNoteDialog({
    required BuildContext context,
    int? noteId,
    String? noteTitle,
    String? noteContent,
    String? source,
    List<String>? tags,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => NoteDialog(
            noteId: noteId,
            noteTitle: noteTitle,
            noteContent: noteContent,
            source: source,
            tags: tags,
          ),
    );
  }

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagController;
  final _formKey = GlobalKey<FormState>();
  final List<String> _selectedTags = [];
  List<String> _availableTags = [];
  bool _isLoading = false;
  bool _tagsLoading = true;

  // Switches
  bool _addSourceToEndNote = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteTitle ?? '');
    _contentController = TextEditingController(text: widget.noteContent ?? '');
    _tagController = TextEditingController();
    _selectedTags.addAll(widget.tags ?? []);
    _loadTags();
  }

  /// تحميل جميع الوسوم المتاحة
  Future<void> _loadTags() async {
    final tags = await UserNotesRepository.getAllTags();
    if (mounted) {
      setState(() {
        _availableTags = tags;
        _tagsLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  /// حفظ أو تعديل الملاحظة
  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    String content = _contentController.text.trim();
    if (_addSourceToEndNote &&
        widget.source != null &&
        widget.source!.isNotEmpty) {
      content += "\n${widget.source}";
    }

    final note = UserNoteModel(
      id: widget.noteId ?? 0,
      title: _titleController.text.trim(),
      content: content,
      tags: _selectedTags,
      createdAt: DateTime.now(),
    );

    final success =
        widget.noteId == null
            ? await UserNotesRepository.addNote(note)
            : await UserNotesRepository.updateNote(note);

    setState(() => _isLoading = false);
    if (success != null) {
      if (!mounted) return;
      Navigator.of(context).pop(true);
      AppToasts.showSuccess(
        title: widget.noteId == null ? 'تم حفظ الملاحظة' : 'تم تعديل الملاحظة',
        description: 'يمكنك مراجعة الملاحظات في قسم الملاحظات',
      );
    } else {
      AppToasts.showError(
        title:
            widget.noteId == null
                ? 'فشل في حفظ الملاحظة'
                : 'فشل في تعديل الملاحظة',
        description: 'يرجى المحاولة مرة أخرى',
      );
    }
  }

  /// إضافة علامة جديدة
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_availableTags.contains(tag)) {
      setState(() {
        _availableTags.add(tag);
        _selectedTags.add(tag);
        _tagController.clear();
      });
    } else {
      _tagController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard
      },
      child: ActionDialog(
        headerIcon:
            widget.noteId == null
                ? Icons.note_add_rounded
                : Icons.edit_note_rounded,
        title: widget.noteId == null ? 'إضافة ملاحظة جديدة' : 'تعديل الملاحظة',
        subtitle:
            widget.noteId == null
                ? 'أضف ملاحظة جديدة لحفظ أفكارك المهمة'
                : 'قم بتعديل محتوى الملاحظة حسب حاجتك',
        confirmText: widget.noteId == null ? 'حفظ الملاحظة' : 'حفظ التعديلات',
        confirmIcon:
            widget.noteId == null ? Icons.save_rounded : Icons.edit_rounded,
        onConfirm: _saveNote,
        onCancel: () => Navigator.of(context).pop(),
        isLoading: _isLoading,
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _titleController,
                  label: 'عنوان الملاحظة',
                  hint: 'ادخل عنوان الملاحظة هنا',
                  icon: Icons.title,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال عنوان للملاحظة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _contentController,
                  label: 'محتوى الملاحظة',
                  hint: 'اكتب محتوى الملاحظة هنا...',
                  icon: Icons.description,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال محتوى للملاحظة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Tags Section
                _buildTagsSection(),
                const SizedBox(height: 24),
                _buildOptionsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Available Tags
        if (!_tagsLoading && _availableTags.isNotEmpty) ...[
          SectionTitle(icon: Icons.local_offer, title: 'العلامات المتاحة:'),
          const SizedBox(height: 12),
          ContentContainer(
            child:
                _tagsLoading
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : _availableTags.isEmpty
                    ? Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.label_off,
                            size: 48,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لا توجد علامات متاحة',
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : Wrap(
                      spacing: 10,
                      children:
                          _availableTags.map((tag) {
                            final isSelected = _selectedTags.contains(tag);
                            return FilterChip(
                              label: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTags.add(tag);
                                  } else {
                                    _selectedTags.remove(tag);
                                  }
                                });
                              },
                              selectedColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                              checkmarkColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerLow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          }).toList(),
                    ),
          ),
          const SizedBox(height: 20),
        ],
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _tagController,
                label: "إضافة علامة",
                hint: 'اكتب علامة جديدة...',
                icon: Icons.tag,
                onFieldSubmitted: (_) {
                  _addTag();
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: _addTag,
              icon: const Icon(Icons.add, size: 18),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          SwitchOption(
            value: _addSourceToEndNote,
            onChanged: (val) => setState(() => _addSourceToEndNote = val),
            title: 'إضافة المصدر',
            subtitle: 'سيتم إضافة المصدر في نهاية الملاحظة',
            icon: Icons.book_rounded,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ),
    );
  }
}
