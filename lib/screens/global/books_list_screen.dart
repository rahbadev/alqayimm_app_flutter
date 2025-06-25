import 'package:alqayimm_app_flutter/db/main/enums.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/screens/global/generec_lesson_books_screen.dart';
import 'package:alqayimm_app_flutter/screens/player/pdf_viewer_screen.dart';
import 'package:alqayimm_app_flutter/transitions/fade_slide_route.dart';
import 'package:alqayimm_app_flutter/utils/app_icons.dart';
import 'package:alqayimm_app_flutter/widget/cards/main_item.dart';
import 'package:alqayimm_app_flutter/widget/icons/main_item_icon.dart';
import 'package:alqayimm_app_flutter/widget/lists/main_items_list.dart';
import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/models/main_db/book_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:alqayimm_app_flutter/widget/icons/animated_icon.dart';

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

  static void navigateToScreen({
    required BuildContext context,
    required String title,
    required CategorySel categorySel,
    required BookTypeSel bookTypeSel,
    int? authoerId,
  }) {
    Navigator.push(
      context,
      fadeSlideRoute(
        BooksListScreen(
          title: title,
          categorySel: categorySel,
          bookTypeSel: bookTypeSel,
          authorId: authoerId,
        ),
      ),
    );
  }
}

class _BooksListScreenState extends State<BooksListScreen> {
  late Future<List<BookModel>> _booksFuture;
  List<BookModel>? _books;

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchBooks();
  }

  Future<List<BookModel>> _fetchBooks() async {
    final db = await DbHelper.database;
    final repo = Repo(db);
    final books = await repo.fetchBooks(
      authorId: widget.authorId,
      categorySel: widget.categorySel,
      bookTypeSel: widget.bookTypeSel,
    );
    _books = books;
    return books;
  }

  MainItem _buildBookItem(BookModel book, int? index) {
    final authorName = book.authorName?.trim();
    final categoryName = book.categoryName?.trim();
    return MainItem(
      title: book.name,
      leadingContent: ImageLeading(
        imageUrl: book.bookThumbUrl,
        placeholderIcon: AppIcons.book,
      ),
      details: [
        if (authorName != null && authorName.isNotEmpty)
          MainItemDetail(
            text: 'المؤلف: $authorName',
            icon: Icons.person,
            iconColor: Colors.teal,
            onTap: (item) => Fluttertoast.showToast(msg: 'المؤلف: $authorName'),
          ),
        if (categoryName != null && categoryName.isNotEmpty)
          MainItemDetail(
            text: 'التصنيف: $categoryName',
            icon: Icons.category,
            iconColor: Colors.blue,
            onTap:
                (item) => Fluttertoast.showToast(msg: 'التصنيف: $categoryName'),
          ),
      ],
      onItemTap: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => PdfViewerScreen(
                  filePath: book.name ?? '',
                  url: book.bookUrl,
                  title: book.name,
                ),
          ),
        );
      },
      actions: buildActionButtons(
        item: book,
        onTapDownload: () => _downloadBook(index),
        onTapShare: () {
          Fluttertoast.showToast(msg: 'مشاركة الكتاب: ${book.name}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: MainItemsListView<BookModel>(
        itemsFuture: _booksFuture,
        itemBuilder: (book, index) => _buildBookItem(book, index),
        titleFontSize: 20,
      ),
    );
  }

  Future<void> _downloadBook(int? index) async {
    if (index == null ||
        _books == null ||
        index < 0 ||
        index >= _books!.length) {
      Fluttertoast.showToast(msg: 'خطأ في تحميل الكتاب');
      return;
    }
    setState(() {
      _books![index] = _books![index].copyWith(
        downloadStatus: DownloadStatus.downloading,
      );
    });
    await Future.delayed(const Duration(seconds: 4)); // محاكاة التنزيل
    setState(() {
      _books![index] = _books![index].copyWith(
        downloadStatus: DownloadStatus.downloaded,
      );
    });
    Fluttertoast.showToast(msg: 'تم التنزيل');
  }

  Future<void> _deleteBook(int? index) async {
    if (index == null ||
        _books == null ||
        index < 0 ||
        index >= _books!.length) {
      Fluttertoast.showToast(msg: 'خطأ في حذف الكتاب');
      return;
    }
    setState(() {
      _books![index] = _books![index].copyWith(
        downloadStatus: DownloadStatus.notDownloaded,
      );
    });
    Fluttertoast.showToast(msg: 'تم الحذف');
  }

  Future<void> _toggleComplete(int? index) async {
    if (index == null || _books == null || index < 0 || index >= _books!.length)
      return;
    setState(() {
      _books![index] = _books![index].copyWith(
        isCompleted: !_books![index].isCompleted,
      );
    });
    Fluttertoast.showToast(
      msg: _books![index].isCompleted ? 'تم الإكمال' : 'لم يتم الإكمال',
    );
  }

  Future<void> _toggleFavorite(int? index) async {
    if (index == null || _books == null || index < 0 || index >= _books!.length)
      return;
    setState(() {
      _books![index] = _books![index].copyWith(
        isFavorite: !_books![index].isFavorite,
      );
    });
    Fluttertoast.showToast(
      msg:
          _books![index].isFavorite
              ? 'تمت الإضافة للمفضلة'
              : 'تمت الإزالة من المفضلة',
    );
  }
}
