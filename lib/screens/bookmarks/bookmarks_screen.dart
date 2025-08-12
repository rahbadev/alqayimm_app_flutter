import 'package:alqayimm_app_flutter/screens/reader/pdf_viewer_screen.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/empty_list_screen.dart';
import 'package:alqayimm_app_flutter/widgets/filter_chip.dart';
import 'package:alqayimm_app_flutter/widgets/filter_search_bar.dart';
import 'package:alqayimm_app_flutter/widgets/search_field.dart';
import 'package:alqayimm_app_flutter/widgets/sort_by_icon.dart';
import 'package:alqayimm_app_flutter/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/user/models/user_bookmark_model.dart';
import 'package:alqayimm_app_flutter/db/user/repos/bookmarks_repository.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/screens/player/audio_player_screen.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/custom_alert_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/bookmark_dialog.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _searchController = TextEditingController();
  List<UserBookmarkModel> _allBookmarks = [];
  List<UserBookmarkModel> _filteredBookmarks = [];
  int _selectedFilterIndex = 0;
  SortBy _sortBy = SortBy.dateDesc;
  bool _isLoading = true;

  List<FilterChipItem> get _filtersChips => [
    ("الكل", _selectedFilterIndex == 0, Icons.all_inclusive),
    ("الكتب", _selectedFilterIndex == 1, Icons.book),
    ("الدروس", _selectedFilterIndex == 2, Icons.headphones),
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    try {
      final bookmarks = await BookmarksRepository.getAllBookmarks();

      setState(() {
        _allBookmarks = bookmarks;
        _isLoading = false;
      });
      updateFilteredBookmarks();
    } catch (e) {
      setState(() {
        _allBookmarks = [];
        _isLoading = false;
      });
    }
  }

  void updateFilteredBookmarks() {
    final searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _filteredBookmarks =
          _allBookmarks.where((bookmark) {
            final matchesSearch = bookmark.title.toLowerCase().contains(
              searchQuery,
            );
            final matchesFilter =
                _selectedFilterIndex == 0 ||
                (_selectedFilterIndex == 1 &&
                    bookmark.itemType == ItemType.book) ||
                (_selectedFilterIndex == 2 &&
                    bookmark.itemType == ItemType.lesson);
            return matchesSearch && matchesFilter;
          }).toList();
    });
  }

  Future<void> _navigateToItem(UserBookmarkModel bookmark) async {
    final db = await DbHelper.database;
    final repo = Repo(db);

    try {
      if (bookmark.itemType == ItemType.lesson) {
        final lesson = await repo.getLessonById(bookmark.itemId);
        if (lesson != null && mounted) {
          final lessonsList = await repo.fetchLessons(
            materialId: lesson.materialId,
          );
          final index = lessonsList.indexWhere((l) => l.id == lesson.id);
          AudioPlayerScreen.navigateTo(context, lessonsList, index);
        }
      } else if (bookmark.itemType == ItemType.book) {
        final book = await repo.getBookById(bookmark.itemId);
        if (book != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PdfViewerScreen(book: book)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppToasts.showError(description: 'حدث خطأ في فتح العنصر');
      }
    }
  }

  Future<void> _deleteBookmark(UserBookmarkModel bookmark) async {
    final confirmed = await showWarningDialog(
      context: context,
      title: 'حذف العلامة المرجعية',
      subtitle: 'هل تريد حقاً حذف "${bookmark.title}"؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      final success = await BookmarksRepository.deleteBookmark(bookmark.id);
      if (success) {
        _loadBookmarks();
        AppToasts.showSuccess(description: 'تم حذف العلامة المرجعية');
      }
    }
  }

  Future<void> _editBookmark(UserBookmarkModel bookmark) async {
    final result = await BookmarkDialog.showEdit(
      context: context,
      bookmark: bookmark,
    );
    if (result == true) {
      await _loadBookmarks();
      AppToasts.showSuccess(description: 'تم التحديث بنجاح');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العلامات المرجعية')),
      body: Column(
        children: [
          _buildSearchFilters(),
          // _buildStats(),
          Expanded(
            child: LoadingEmptyListScreen(
              isLoading: _isLoading,
              isEmpty: _filteredBookmarks.isEmpty,
              title: 'لا توجد علامات مرجعية',
              desc: 'ستظهر العلامات المرجعية هنا',
              icon: Icons.note_alt_outlined,
              childWidget: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _filteredBookmarks.length,
                itemBuilder:
                    (context, index) =>
                        _buildBookmarkCard(_filteredBookmarks[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
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
        hintText: 'البحث في العلامات المرجعية...',
        onChanged: (value) {
          updateFilteredBookmarks();
        },
      ),
      filterChipsWidget: FilterChipsWidget(
        items: _filtersChips,
        singleSelect: true,
        onSelected: (chips) {
          // ابحث عن الفلتر المحدد
          final selectedIndex = chips.indexWhere((chip) => chip.$2);
          setState(() {
            _selectedFilterIndex = selectedIndex >= 0 ? selectedIndex : 0;
          });
          updateFilteredBookmarks();
        },
      ),
    );
  }

  // Widget _buildStats() {
  //   if (_filteredBookmarks.isEmpty) return const SizedBox.shrink();

  //   final bookCount =
  //       _filteredBookmarks.where((b) => b.itemType == ItemType.book).length;
  //   final lessonCount =
  //       _filteredBookmarks.where((b) => b.itemType == ItemType.lesson).length;

  //   return Container(
  //     color: Colors.white,
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     child: Row(
  //       children: [
  //         Text(
  //           '${_filteredBookmarks.length} عنصر',
  //           style: TextStyle(color: Colors.grey[600], fontSize: 12),
  //         ),
  //         if (bookCount > 0) ...[
  //           const SizedBox(width: 16),
  //           Icon(Icons.book, size: 14, color: Colors.green[600]),
  //           const SizedBox(width: 4),
  //           Text(
  //             '$bookCount',
  //             style: TextStyle(color: Colors.grey[600], fontSize: 12),
  //           ),
  //         ],
  //         if (lessonCount > 0) ...[
  //           const SizedBox(width: 16),
  //           Icon(Icons.headphones, size: 14, color: Colors.blue[600]),
  //           const SizedBox(width: 4),
  //           Text(
  //             '$lessonCount',
  //             style: TextStyle(color: Colors.grey[600], fontSize: 12),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBookmarkCard(UserBookmarkModel bookmark) {
    final isBook = bookmark.itemType == ItemType.book;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToItem(bookmark),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isBook ? Colors.green : Colors.blue).withOpacity(
                        0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isBook ? Icons.book : Icons.headphones,
                      color: isBook ? Colors.green[600] : Colors.blue[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookmark.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              isBook ? 'كتاب' : 'درس',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const Text(
                              ' • ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'الموضع: ${bookmark.position}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editBookmark(bookmark);
                      } else if (value == 'delete') {
                        _deleteBookmark(bookmark);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('تعديل'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'حذف',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                    child: const Icon(Icons.more_vert, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
