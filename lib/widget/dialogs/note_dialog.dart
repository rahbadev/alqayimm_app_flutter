import 'package:alqayimm_app_flutter/widget/headers.dart';
import 'package:alqayimm_app_flutter/widget/toasts.dart';
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
  bool _addMaterialNameAsTag = false;

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
    // ملاحظة: خيار إضافة اسم المادة كعلامة لم يُستخدم هنا، أضفه حسب الحاجة

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

    if (mounted) {
      if (success != null) {
        Navigator.of(context).pop(true);
        AppToasts.showSuccess(
          context,
          title:
              widget.noteId == null ? 'تم حفظ الملاحظة' : 'تم تعديل الملاحظة',
        );
      } else {
        AppToasts.showError(
          context,
          title:
              widget.noteId == null
                  ? 'فشل في حفظ الملاحظة'
                  : 'فشل في تعديل الملاحظة',
        );
      }
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
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              spreadRadius: 1,
              color: Theme.of(context).colorScheme.shadow.withAlpha(100),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            DialogHeader(
              icon:
                  widget.noteId == null
                      ? Icons.note_add_rounded
                      : Icons.edit_note_rounded,
              title:
                  widget.noteTitle == null
                      ? 'إضافة ملاحظة جديدة'
                      : 'تعديل الملاحظة',
              subtitle:
                  widget.noteContent == null
                      ? 'إضافة ملاحظة جديدة'
                      : 'تعديل الملاحظة',
            ),

            Flexible(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
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
                              _buildTextField(
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
                      ),
                    ),
                  ),
                  // Action Buttons
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('إلغاء'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: _isLoading ? null : _saveNote,
                            icon:
                                _isLoading
                                    ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                      ),
                                    )
                                    : Icon(
                                      widget.noteId == null
                                          ? Icons.save_rounded
                                          : Icons.edit_rounded,
                                    ),
                            label: Text(
                              widget.noteId == null
                                  ? 'حفظ الملاحظة'
                                  : 'حفظ التعديلات',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TextField Decoration
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? Function(String?)? onFieldSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onFieldSubmitted: (_) {
          _addTag();
        },
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Tags
          if (!_tagsLoading && _availableTags.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.local_offer,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'العلامات المتاحة:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withAlpha(50),
                ),
              ),
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
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
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

          // Add New Tag
          Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'إضافة علامة جديدة:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _tagController,
                  label: "إضافة علامة",
                  hint: 'اكتب علامة جديدة...',
                  icon: Icons.tag,
                  onFieldSubmitted: (_) {
                    _addTag();
                    return null;
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
      ),
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
          _buildSwitchOption(
            value: _addSourceToEndNote,
            onChanged: (val) => setState(() => _addSourceToEndNote = val),
            title: 'إضافة المصدر',
            subtitle: 'سيتم إضافة المصدر في نهاية الملاحظة',
            icon: Icons.book_rounded,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSwitchOption(
            value: _addMaterialNameAsTag,
            onChanged: (val) => setState(() => _addMaterialNameAsTag = val),
            title: 'إضافة اسم المادة كعلامة',
            subtitle: 'سيتم إضافة اسم المادة كعلامة تلقائياً',
            icon: Icons.label_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOption({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  value
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color:
                  value
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        value
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
