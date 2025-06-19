import 'package:alqayimm_app_flutter/db/main/enmus.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';
import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:alqayimm_app_flutter/widget/lists/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/models/main_db/book_model.dart';

class BooksListScreen extends StatefulWidget {
  final String title;
  final CategorySel categorySel;
  final BookTypeSel bookTypeSel;
  final int? authorId;

  const BooksListScreen({
    super.key,
    required this.title,
    required this.categorySel,
    required this.bookTypeSel,
    this.authorId,
  });

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  late Future<List<BookModel>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchBooks();
  }

  Future<List<BookModel>> _fetchBooks() async {
    final db = await DbHelper.database;
    final repo = Repo(db);
    return repo.fetchBooks(
      authorId: widget.authorId,
      categorySel: widget.categorySel,
      bookTypeSel: widget.bookTypeSel,
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _booksFuture = _fetchBooks();
    });
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'لا توجد كتب متاحة',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في جلب البيانات',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<BookModel>>(
          future: _booksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final books = snapshot.data!;
            return MainItemsList(
              items:
                  books.map((book) {
                    return MainItem(
                      title: book.name,
                      leadingContent: ImageLeading(
                        imageUrl: book.bookThumbUrl,
                        placeholderIcon: Icons.book,
                      ),
                      details: [
                        if (book.name != null)
                          MainItemDetail(
                            text: book.name!,
                            icon: Icons.info_outline,
                            iconColor: Colors.grey,
                          ),
                      ],
                    );
                  }).toList(),
              titleFontSize: 20,
              onItemTap: (item, index) {
                // TODO: Implement material details navigation
              },
            );
          },
        ),
      ),
    );
  }
}
