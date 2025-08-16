import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/screens/reader/pdf_viewer_screen.dart';
import 'package:alqayimm_app_flutter/widgets/app_bar.dart';
import 'package:alqayimm_app_flutter/widgets/cards/bookmark_card.dart';
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

  Map<BaseContentModel, List<UserBookmarkModel>> _groupedBookmarks = {};

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

    final db = await DbHelper.database;
    final repo = Repo(db);
    try {
      final bookmarks = await BookmarksRepository.getAllBookmarks();

      // فصل الـ ids حسب النوع
      List<int> lessonIds = [];
      List<int> bookIds = [];

      for (var bookmark in bookmarks) {
        if (bookmark.itemType == ItemType.lesson) {
          lessonIds.add(bookmark.itemId);
        } else if (bookmark.itemType == ItemType.book) {
          bookIds.add(bookmark.itemId);
        }
      }

      List<LessonModel> lessons = await repo.getLessonsByIds(lessonIds) ?? [];
      List<BookModel> books = await repo.getBooksByIds(bookIds) ?? [];

      // بناء خرائط للبحث السريع
      final Map<int, BookModel> booksMap = {
        for (var book in books) book.id: book,
      };
      final Map<int, LessonModel> lessonsMap = {
        for (var lesson in lessons) lesson.id: lesson,
      };

      // بناء التجميع النهائي
      final Map<BaseContentModel, List<UserBookmarkModel>> grouped = {};

      for (var bookmark in bookmarks) {
        final itemId = bookmark.itemId;
        final itemType = bookmark.itemType;

        BaseContentModel? key;

        if (itemType == ItemType.book) {
          key = booksMap[itemId];
        } else if (itemType == ItemType.lesson) {
          key = lessonsMap[itemId];
        }

        if (key != null) {
          grouped.putIfAbsent(key, () => []).add(bookmark);
        }
      }

      setState(() {
        _groupedBookmarks = grouped;
        _isLoading = false;
      });
      updateFilteredBookmarks();
    } catch (e) {
      setState(() {
        _groupedBookmarks = {};
        _isLoading = false;
      });
    }
  }

  // بناء مجموعة مفلترة ومرتبة حسب البحث والفلاتر
  Map<BaseContentModel, List<UserBookmarkModel>> get _filteredGroupedBookmarks {
    final searchQuery = _searchController.text.toLowerCase();
    final Map<BaseContentModel, List<UserBookmarkModel>> filtered = {};

    for (final entry in _groupedBookmarks.entries) {
      final content = entry.key;
      final bookmarks =
          entry.value.where((bookmark) {
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
            }).toList()
            ..sort(_getSortComparator());

      if (bookmarks.isNotEmpty) {
        filtered[content] = bookmarks;
      }
    }

    return filtered;
  }

  Comparator<UserBookmarkModel> _getSortComparator() {
    return (a, b) {
      switch (_sortBy) {
        case SortBy.dateDesc:
          return b.createdAt.compareTo(a.createdAt);
        case SortBy.dateAsc:
          return a.createdAt.compareTo(b.createdAt);
        case SortBy.titleAsc:
          return a.title.compareTo(b.title);
        case SortBy.titleDesc:
          return b.title.compareTo(a.title);
      }
    };
  }

  void updateFilteredBookmarks() {
    setState(() {});
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
          AudioPlayerScreen.navigateTo(
            context,
            lessonsList,
            index,
            positionMs: bookmark.position,
          );
        }
      } else if (bookmark.itemType == ItemType.book) {
        final book = await repo.getBookById(bookmark.itemId);
        if (book != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PdfViewerScreen(
                    book: book,
                    initialPage: bookmark.position,
                  ),
            ),
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
      appBar: AppBarWidget(title: "العلامات المرجعية"),
      body: Column(
        children: [
          _buildSearchFilters(),
          Expanded(
            child: LoadingEmptyListScreen(
              isLoading: _isLoading,
              isEmpty: _filteredGroupedBookmarks.isEmpty,
              title: 'لا توجد علامات مرجعية',
              desc: 'ستظهر العلامات المرجعية هنا',
              icon: Icons.note_alt_outlined,
              childWidget: _buildGroupedList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Column(
      children: [
        FilterSearchBar(
          sortByIcon: SortByIcon(
            sortBy: _sortBy,
            onSortChanged: (newSortBy) {
              setState(() {
                _sortBy = newSortBy;
              });
              updateFilteredBookmarks();
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
              final selectedIndex = chips.indexWhere((chip) => chip.$2);
              setState(() {
                _selectedFilterIndex = selectedIndex >= 0 ? selectedIndex : 0;
              });
              updateFilteredBookmarks();
            },
          ),
        ),
      ],
    );
  }

  // عرض مجمع للعلامات المرجعية
  Widget _buildGroupedList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _filteredGroupedBookmarks.entries.length,
      itemBuilder: (context, index) {
        final entry = _filteredGroupedBookmarks.entries.elementAt(index);
        final item = entry.key;
        final bookmarks = entry.value;

        return BookmarkItemCard(
          item: item,
          bookmarks: bookmarks,
          onTap: (bookmark) {
            _navigateToItem(bookmark);
          },
          onEdit: (bookmark) {
            _editBookmark(bookmark);
          },
          onDelete: (bookmark) {
            _deleteBookmark(bookmark);
          },
        );
      },
    );
  }
}
