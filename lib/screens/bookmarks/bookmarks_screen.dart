import 'package:alqayimm_app_flutter/screens/reader/pdf_viewer_screen_final.dart';
import 'package:alqayimm_app_flutter/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/user/models/user_bookmark_model.dart';
import 'package:alqayimm_app_flutter/db/user/repos/bookmarks_repository.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/screens/player/audio_player_screen.dart';
import 'package:alqayimm_app_flutter/widgets/search_field.dart';

import 'package:alqayimm_app_flutter/widgets/dialogs/custom_alert_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/bookmark_dialog.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<UserBookmarkModel> _bookmarks = [];
  bool _isLoading = true;
  String? _searchQuery;
  ItemType? _selectedItemType;
  String _sortBy = 'date_desc';

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookmarks = await BookmarksRepository.getAllBookmarks(
        searchQuery: _searchQuery,
        itemTypeFilter: _selectedItemType,
        orderBy: _getSortOrderBy(),
      );

      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _bookmarks = [];
        _isLoading = false;
      });
    }
  }

  String _getSortOrderBy() {
    switch (_sortBy) {
      case 'date_asc':
        return '${UserBookmarkFields.createdAt} ASC';
      case 'title_asc':
        return '${UserBookmarkFields.title} ASC';
      case 'title_desc':
        return '${UserBookmarkFields.title} DESC';
      case 'date_desc':
      default:
        return '${UserBookmarkFields.createdAt} DESC';
    }
  }

  Future<void> _deleteBookmark(int id) async {
    final confirmed = await showWarningDialog(
      context: context,
      title: 'حذف العلامة المرجعية',
      subtitle: 'هل تريد حقاً حذف هذه العلامة المرجعية؟',
      confirmText: 'نعم',
      cancelText: 'تراجع',
    );

    if (confirmed == true) {
      final success = await BookmarksRepository.deleteBookmark(id);
      if (success) {
        setState(() {
          _bookmarks.removeWhere((bookmark) => bookmark.id == id);
        });
        if (mounted) {
          AppToasts.showSuccess(
            context,
            description: 'تم حذف العلامة المرجعية بنجاح',
          );
        }
      }
    }
  }

  Future<void> _navigateToItem(UserBookmarkModel bookmark) async {
    final db = await DbHelper.database;
    final repo = Repo(db);

    try {
      if (bookmark.itemType == ItemType.lesson) {
        final lesson = await repo.getLessonById(bookmark.itemId);
        if (lesson != null && mounted) {
          // جلب جميع دروس نفس المادة
          final lessonsList = await repo.fetchLessons(
            materialId: lesson.materialId,
          );

          // تحديد موقع الدرس في القائمة
          final index = lessonsList.indexWhere((l) => l.id == lesson.id);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AudioPlayerScreen(
                    lessons: lessonsList,
                    initialIndex: index >= 0 ? index : 0,
                  ),
            ),
          );
        }
      } else if (bookmark.itemType == ItemType.book) {
        final book = await repo.getBookById(bookmark.itemId);
        // TODO Fix
        if (book != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PdfViewerScreenFinal(book: book)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ في فتح العنصر')));
      }
    }
  }

  Widget _buildItemTypeIcon(ItemType? type) {
    switch (type) {
      case ItemType.lesson:
        return const Icon(Icons.headphones, color: Colors.blue);
      case ItemType.book:
        return const Icon(Icons.book, color: Colors.green);
      default:
        return const Icon(Icons.bookmark, color: Colors.grey);
    }
  }

  String _getItemTypeName(ItemType type) {
    switch (type) {
      case ItemType.lesson:
        return 'درس';
      case ItemType.book:
        return 'كتاب';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العلامات المرجعية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'ترتيب',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'تصفية',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchField(
              onSubmitted: (query) {
                setState(() {
                  _searchQuery = query.isNotEmpty ? query : null;
                });
                _loadBookmarks();
              },
              hintText: 'بحث في العلامات المرجعية...',
            ),
          ),
          if (_selectedItemType != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  // Filter chip
                  Chip(
                    label: Text(
                      'النوع: ${_getItemTypeName(_selectedItemType!)}',
                    ),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        _selectedItemType = null;
                      });
                      _loadBookmarks();
                    },
                  ),
                  const Spacer(),
                  Text('${_bookmarks.length} عنصر'),
                ],
              ),
            ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _bookmarks.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text('لا توجد علامات مرجعية'),
                          if (_searchQuery != null || _selectedItemType != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = null;
                                  _selectedItemType = null;
                                });
                                _loadBookmarks();
                              },
                              child: const Text('إزالة التصفية'),
                            ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = _bookmarks[index];
                        return Dismissible(
                          key: Key('bookmark_${bookmark.id}'),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteBookmark(bookmark.id),
                          confirmDismiss: (_) async {
                            return await showWarningDialog(
                                  context: context,
                                  title: 'حذف العلامة المرجعية',
                                  subtitle:
                                      'هل تريد حقاً حذف هذه العلامة المرجعية؟',
                                  confirmText: 'نعم',
                                  cancelText: 'تراجع',
                                ) ??
                                false;
                          },
                          child: ListTile(
                            leading: _buildItemTypeIcon(bookmark.itemType),
                            title: Text(bookmark.title),
                            subtitle:
                                bookmark.position != null
                                    ? Text(
                                      '${_getItemTypeName(bookmark.itemType)} - الموضع: ${bookmark.position}',
                                    )
                                    : Text(_getItemTypeName(bookmark.itemType)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editBookmark(bookmark),
                                  tooltip: 'تعديل',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteBookmark(bookmark.id),
                                  tooltip: 'حذف',
                                ),
                              ],
                            ),
                            onTap: () => _navigateToItem(bookmark),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('جميع العلامات المرجعية'),
                leading: const Icon(Icons.all_inclusive),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedItemType = null;
                  });
                  _loadBookmarks();
                },
              ),
              ListTile(
                title: const Text('الدروس فقط'),
                leading: const Icon(Icons.headphones),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedItemType = ItemType.lesson;
                  });
                  _loadBookmarks();
                },
              ),
              ListTile(
                title: const Text('الكتب فقط'),
                leading: const Icon(Icons.book),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedItemType = ItemType.book;
                  });
                  _loadBookmarks();
                },
              ),
            ],
          ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('الأحدث أولاً'),
                leading: const Icon(Icons.arrow_downward),
                selected: _sortBy == 'date_desc',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _sortBy = 'date_desc';
                  });
                  _loadBookmarks();
                },
              ),
              ListTile(
                title: const Text('الأقدم أولاً'),
                leading: const Icon(Icons.arrow_upward),
                selected: _sortBy == 'date_asc',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _sortBy = 'date_asc';
                  });
                  _loadBookmarks();
                },
              ),
              ListTile(
                title: const Text('العنوان: أ-ي'),
                leading: const Icon(Icons.sort_by_alpha),
                selected: _sortBy == 'title_asc',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _sortBy = 'title_asc';
                  });
                  _loadBookmarks();
                },
              ),
              ListTile(
                title: const Text('العنوان: ي-أ'),
                leading: const Icon(Icons.sort_by_alpha),
                selected: _sortBy == 'title_desc',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _sortBy = 'title_desc';
                  });
                  _loadBookmarks();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _editBookmark(UserBookmarkModel bookmark) async {
    final result = await BookmarkDialog.showEdit(
      context: context,
      bookmark: bookmark,
    );

    if (result == true && mounted) {
      await _loadBookmarks();

      AppToasts.showSuccess(
        context,
        description: 'تم تحديث العلامة المرجعية بنجاح',
      );
    }
  }
}
