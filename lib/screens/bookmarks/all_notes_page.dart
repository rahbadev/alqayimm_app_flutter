import 'package:alqayimm_app_flutter/widgets/cards/note_card.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/custom_alert_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/preview_note_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../db/user/models/user_note_model.dart';
import '../../db/user/repos/user_notes_repository.dart';
import '../../widgets/dialogs/note_dialog.dart';
import '../../widgets/toasts.dart';

/// صفحة جميع الملاحظات
class AllNotesPage extends StatefulWidget {
  const AllNotesPage({super.key});

  @override
  State<AllNotesPage> createState() => _AllNotesPageState();
}

class _AllNotesPageState extends State<AllNotesPage> {
  final _searchController = TextEditingController();
  List<String> _availableTags = [];
  final Set<String> _selectedTags = {}; // تغيير من String? إلى Set<String>
  String _sortBy = 'date_desc'; // date_desc, date_asc, title_asc, title_desc
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
        tagFilter: _selectedTags.isEmpty ? null : _selectedTags.join(','),
      );

      // تطبيق الترتيب
      _sortNotes(notes);

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

  /// ترتيب الملاحظات
  void _sortNotes(List<UserNoteModel> notes) {
    switch (_sortBy) {
      case 'date_desc':
        notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'date_asc':
        notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'title_asc':
        notes.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'title_desc':
        notes.sort((a, b) => b.title.compareTo(a.title));
        break;
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

  /// بناء شريحة العلامة
  Widget _buildTagChip(String tag, {bool isSelected = false}) {
    return FilterChip(
      label: Text(tag),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedTags.add(tag);
          } else {
            _selectedTags.remove(tag);
          }
        });
        _loadNotes();
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color:
            isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
      ),
    );
  }

  /// بناء شريط الفلاتر والترتيب
  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // زر الترتيب
          PopupMenuButton<String>(
            initialValue: _sortBy,
            icon: Icon(
              Icons.sort,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: 'ترتيب',
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadNotes();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'date_desc',
                    child: Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 8),
                        Text('الأحدث أولاً'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'date_asc',
                    child: Row(
                      children: [
                        Icon(Icons.history),
                        SizedBox(width: 8),
                        Text('الأقدم أولاً'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'title_asc',
                    child: Row(
                      children: [
                        Icon(Icons.sort_by_alpha),
                        SizedBox(width: 8),
                        Text('العنوان (أ-ي)'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'title_desc',
                    child: Row(
                      children: [
                        Icon(Icons.sort_by_alpha),
                        SizedBox(width: 8),
                        Text('العنوان (ي-أ)'),
                      ],
                    ),
                  ),
                ],
          ),
          const SizedBox(width: 8),
          // عرض عدد النتائج
          Expanded(
            child: Text(
              '${_notes.length} ملاحظة${_buildFilterText()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // زر مسح الفلاتر
          if (_selectedTags.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'مسح الفلاتر',
              onPressed: () {
                setState(() => _selectedTags.clear());
                _loadNotes();
              },
            ),
        ],
      ),
    );
  }

  /// بناء نص الفلتر
  String _buildFilterText() {
    if (_selectedTags.isEmpty) return '';

    if (_selectedTags.length == 1) {
      return ' في "${_selectedTags.first}"';
    } else if (_selectedTags.length == 2) {
      return ' في "${_selectedTags.elementAt(0)}" و "${_selectedTags.elementAt(1)}"';
    } else {
      return ' في ${_selectedTags.length} علامات';
    }
  }

  /// بناء قائمة العلامات
  Widget _buildTagsList() {
    if (_availableTags.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _availableTags.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = _availableTags[index];
          return _buildTagChip(tag, isSelected: _selectedTags.contains(tag));
        },
      ),
    );
  }

  /// بناء واجهة البحث والفلاتر
  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // شريط البحث
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchField.notes(
            controller: _searchController,
            onSubmitted: (_) => _loadNotes(),
          ),
        ),
        // قائمة العلامات
        _buildTagsList(),
        // شريط الفلاتر والترتيب
        _buildFiltersBar(),
      ],
    );
  }

  /// بناء كرت الملاحظة
  Widget _buildNoteCard(UserNoteModel note) {
    return NoteCard(
      note: note,
      onTap: () => _showNotePreview(note),
      onActionSelected: (action) => _handleNoteAction(action, note),
    );
  }

  /// عرض معاينة الملاحظة
  Future<void> _showNotePreview(UserNoteModel note) async {
    final action = await NotePreviewDialog.show(context: context, note: note);

    if (action != null && mounted) {
      switch (action) {
        case 'edit':
          _openNoteDialog(note);
          break;
        case 'delete':
          _deleteNote(note);
          break;
        case 'share':
          _shareNote(note);
      }
    }
  }

  /// التعامل مع أكشنات الملاحظة (تعديل/مشاركة/حذف)
  void _handleNoteAction(String action, UserNoteModel note) {
    switch (action) {
      case 'edit':
        _openNoteDialog(note);
        break;
      case 'share':
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
    if (result == true) {
      _loadNotes();
      _loadTags(); // إعادة تحميل العلامات في حالة إضافة علامات جديدة
    }
  }

  /// حذف الملاحظة
  Future<void> _deleteNote(UserNoteModel note) async {
    final confirmed = await showWarningDialog(
      context: context,
      title: 'تأكيد الحذف',
      subtitle: 'هل أنت متأكد من حذف الملاحظة "${note.title}"؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );
    if (confirmed != true) return;

    final success = await UserNotesRepository.deleteNote(note.id);
    if (success && mounted) {
      _loadNotes();
      _loadTags(); // إعادة تحميل العلامات في حالة حذف آخر ملاحظة لعلامة معينة
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
              _selectedTags.isNotEmpty
                  ? Icons.filter_list_off
                  : Icons.note_alt_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTags.isNotEmpty
                  ? 'لا توجد ملاحظات في العلامات المحددة'
                  : 'لا توجد ملاحظات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTags.isNotEmpty
                  ? 'جرب البحث في علامات أخرى أو امسح الفلاتر'
                  : 'ابدأ بإضافة ملاحظة جديدة',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
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
    if (result == true) {
      _loadNotes();
      _loadTags(); // إعادة تحميل العلامات في حالة إضافة علامات جديدة
    }
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
