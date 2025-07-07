import 'package:alqayimm_app_flutter/widget/cards/note_card.dart';
import 'package:alqayimm_app_flutter/widget/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../db/user/models/user_note_model.dart';
import '../../db/user/repos/user_notes_repository.dart';
import '../../widget/dialogs/note_dialog.dart';
import '../../widget/toasts.dart';
import '../../widget/containers/filter_container.dart';

/// صفحة جميع الملاحظات
class AllNotesPage extends StatefulWidget {
  const AllNotesPage({super.key});

  @override
  State<AllNotesPage> createState() => _AllNotesPageState();
}

class _AllNotesPageState extends State<AllNotesPage> {
  final _searchController = TextEditingController();
  List<String> _availableTags = [];
  String? _selectedTag;
  bool _isLoading = true;
  List<UserNoteModel> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadTags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// تحميل جميع الملاحظات مع تطبيق الفلاتر والبحث
  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await UserNotesRepository.getAllNotes(
        searchQuery:
            _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
        tagFilter: _selectedTag,
      );
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToasts.showError(context, title: 'خطأ في تحميل الملاحظات');
    }
  }

  /// تحميل جميع الوسوم المتاحة
  Future<void> _loadTags() async {
    final tags = await UserNotesRepository.getAllTags();
    if (mounted) setState(() => _availableTags = tags);
  }

  /// مشاركة نص الملاحظة
  Future<void> _shareNote(UserNoteModel note) async {
    final shareText = '${note.title}\n\n${note.content}';
    await Clipboard.setData(ClipboardData(text: shareText));
    if (mounted) {
      AppToasts.showSuccess(
        context,
        title: 'تم نسخ الملاحظة',
        description: 'تم نسخ الملاحظة إلى الحافظة',
      );
    }
  }

  /// بناء واجهة البحث والفلاتر
  Widget _buildSearchAndFilters() {
    return FilterContainer.bottomRounded(
      child: Column(
        children: [
          // شريط البحث
          SearchField.notes(
            controller: _searchController,
            onSubmitted: (_) => _loadNotes(),
          ),
          const SizedBox(height: 16),
          // فلتر العلامات
          DropdownButtonFormField<String?>(
            value: _selectedTag,
            decoration: InputDecoration(
              labelText: 'العلامة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('جميع العلامات'),
              ),
              ..._availableTags.map(
                (tag) =>
                    DropdownMenuItem<String?>(value: tag, child: Text(tag)),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedTag = value);
              _loadNotes();
            },
          ),
        ],
      ),
    );
  }

  /// بناء كرت الملاحظة
  Widget _buildNoteCard(UserNoteModel note) {
    return NoteCard(
      note: note,
      onTap: () => _openNoteDialog(note),
      onActionSelected: (action) => _handleNoteAction(action, note),
    );
  }

  /// التعامل مع أكشنات الملاحظة (تعديل/مشاركة/حذف)
  void _handleNoteAction(String action, UserNoteModel note) {
    switch (action) {
      case 'edit':
        _openNoteDialog(note);
        break;
      case 'share_text':
        _shareNote(note);
        break;
      case 'delete':
        _deleteNote(note);
        break;
    }
  }

  /// فتح نافذة تعديل/عرض الملاحظة
  Future<void> _openNoteDialog(UserNoteModel note) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => NoteDialog(
            noteId: note.id,
            noteTitle: note.title,
            noteContent: note.content,
            tags: note.tags,
          ),
    );
    if (result == true) _loadNotes();
  }

  /// حذف الملاحظة
  Future<void> _deleteNote(UserNoteModel note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف الملاحظة'),
            content: Text('هل تريد حذف الملاحظة "${note.title}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    final success = await UserNotesRepository.deleteNote(note.id);
    if (success && mounted) {
      _loadNotes();
      AppToasts.showSuccess(
        context,
        title: 'تم حذف الملاحظة',
        description: 'تم حذف "${note.title}" بنجاح',
      );
    }
  }

  /// بناء قائمة الملاحظات
  Widget _buildNotesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد ملاحظات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة ملاحظة جديدة',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _notes.length,
      itemBuilder: (context, index) => _buildNoteCard(_notes[index]),
    );
  }

  /// إضافة ملاحظة جديدة
  Future<void> _addNewNote() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => NoteDialog(),
    );
    if (result == true) _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildNotesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewNote,
        icon: const Icon(Icons.add),
        label: const Text('ملاحظة جديدة'),
      ),
    );
  }
}
