import 'package:alqayimm_app_flutter/widgets/cards/note_card.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/custom_alert_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/empty_list_screen.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/preview_note_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/filter_chip.dart';
import 'package:alqayimm_app_flutter/widgets/filter_search_bar.dart';
import 'package:alqayimm_app_flutter/widgets/search_field.dart';
import 'package:alqayimm_app_flutter/widgets/sort_by_icon.dart';
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
  List<UserNoteModel> _allNotes = [];
  List<UserNoteModel> _filteredNotes = [];
  List<String> _allTags = [];
  final Set<String> _selectedTags = {};
  SortBy _sortBy = SortBy.dateDesc;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
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
      final notes = await UserNotesRepository.getAllNotes();

      final tags = await UserNotesRepository.getAllTags();

      setState(() {
        _allNotes = notes;
        _allTags = tags;
        _isLoading = false;
      });

      _updateFilteredNotes();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// مشاركة نص الملاحظة
  Future<void> _shareNote(UserNoteModel note) async {
    final shareText = '${note.title}\n\n${note.content}';
    await Clipboard.setData(ClipboardData(text: shareText));
    AppToasts.showSuccess(
      title: 'تم نسخ الملاحظة',
      description: 'تم نسخ الملاحظة إلى الحافظة',
    );
  }

  void _updateFilteredNotes() {
    final searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes =
          _allNotes.where((note) {
            final matchesSearch =
                note.title.toLowerCase().contains(searchQuery) ||
                note.content.toLowerCase().contains(searchQuery);
            final matchesTags =
                _selectedTags.isEmpty ||
                note.tags.any((tag) => _selectedTags.contains(tag));
            return matchesSearch && matchesTags;
          }).toList();
    });
  }

  /// بناء واجهة البحث والفلاتر
  Widget _buildSearchAndFilters() {
    return FilterSearchBar(
      sortByIcon: SortByIcon(
        sortBy: _sortBy,
        onSortChanged: (newSortBy) {
          setState(() {
            _sortBy = newSortBy;
          });
        },
      ),
      searchField: SearchField(
        controller: _searchController,
        onSubmitted: (_) => _loadNotes(),
        hintText: 'البحث في الملاحظات...',
        onChanged: (value) {
          _updateFilteredNotes();
        },
      ),
      // قائمة العلامات
      filterChipsWidget: FilterChipsWidget(
        items:
            _allTags.map((tag) {
              return (tag, _selectedTags.contains(tag), null);
            }).toList(),
        onSelected: (List<FilterChipItem> items) {
          for (final item in items) {
            final (label, isSelected, icon) = item;
            setState(() {
              if (isSelected) {
                _selectedTags.add(label);
              } else {
                _selectedTags.remove(label);
              }
            });
          }
          _updateFilteredNotes();
        },
      ),
    );
  }

  /// بناء كرت الملاحظة

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
      AppToasts.showSuccess(
        title: 'تم حذف الملاحظة',
        description: 'تم حذف "${note.title}" بنجاح',
      );
    }
  }

  /// إضافة ملاحظة جديدة
  Future<void> _addNewNote() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => NoteDialog(),
    );
    if (result == true) {
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: LoadingEmptyListScreen(
              isLoading: _isLoading,
              isEmpty: _filteredNotes.isEmpty,
              title:
                  _selectedTags.isEmpty
                      ? 'لا توجد ملاحظات'
                      : 'لا توجد ملاحظات في العلامات المحددة',
              desc:
                  _selectedTags.isEmpty
                      ? 'جرب البحث في علامات أخرى أو امسح الفلاتر'
                      : 'ابدأ بإضافة ملاحظة جديدة',
              icon: Icons.note_alt_outlined,
              reLoadingButton: (
                _selectedTags.isEmpty ? 'إضافة ملاحظة' : 'مسح الفلاتر',
                _selectedTags.isEmpty
                    ? _addNewNote
                    : () {
                      setState(() {
                        _selectedTags.clear();
                        _searchController.clear();
                        _updateFilteredNotes();
                      });
                    },
              ),
              childWidget: ListView.builder(
                itemCount: _filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = _filteredNotes[index];
                  return NoteCard(
                    note: note,
                    onTap: () => _showNotePreview(note),
                    onActionSelected:
                        (action) => _handleNoteAction(action, note),
                  );
                },
              ),
            ),
          ),
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
