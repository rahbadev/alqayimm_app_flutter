import 'package:alqayimm_app_flutter/db/main/enums.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
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
        Fluttertoast.showToast(msg: book.name);
      },
      actions: _buildActionButtons(book, index),
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

  List<ActionButton> _buildActionButtons(BookModel book, int? index) {
    List<ActionButton> actions = [];

    // زر التنزيل/التحميل/الحذف مع حركة AnimatedIconSwitcher
    actions.add(
      ActionButton(
        buttonWidget: AnimatedIconSwitcher(
          icon: () {
            switch (book.downloadStatus) {
              case DownloadStatus.notDownloaded:
                return Icon(AppIcons.download, key: const ValueKey('download'));
              case DownloadStatus.downloading:
                return SizedBox(
                  key: const ValueKey('progress'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.teal,
                    ),
                  ),
                );
              case DownloadStatus.downloaded:
                return Icon(AppIcons.delete, key: const ValueKey('delete'));
              default:
                return Icon(AppIcons.download, key: const ValueKey('download'));
            }
          }(),
        ),
        tooltip: () {
          switch (book.downloadStatus) {
            case DownloadStatus.notDownloaded:
              return 'تنزيل';
            case DownloadStatus.downloading:
              return 'جار التنزيل';
            case DownloadStatus.downloaded:
              return 'حذف';
            default:
              return '';
          }
        }(),
        onTap: (item) {
          switch (book.downloadStatus) {
            case DownloadStatus.notDownloaded:
              _downloadBook(index);
              break;
            case DownloadStatus.downloading:
              // لا شيء أو يمكنك إضافة إلغاء التنزيل
              break;
            case DownloadStatus.downloaded:
              _deleteBook(index);
              break;
            default:
              break;
          }
        },
      ),
    );

    // 2- مشاركة
    actions.add(
      ActionButton(
        buttonWidget: const Icon(AppIcons.share),
        tooltip: 'مشاركة',
        onTap: (item) {
          Fluttertoast.showToast(msg: 'تم المشاركة');
        },
      ),
    );

    // 3- فتح باستخدام
    actions.add(
      ActionButton(
        buttonWidget: const Icon(AppIcons.openInNew),
        tooltip: 'فتح باستخدام',
        onTap: (item) {
          Fluttertoast.showToast(msg: 'فتح باستخدام...');
        },
      ),
    );

    // 4- تم الإكمال ولم يتم الإكمال (AnimatedIconSwitcher)
    actions.add(
      ActionButton(
        buttonWidget: AnimatedIconSwitcher(
          icon: Icon(
            book.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            key: ValueKey(book.isCompleted),
            color: book.isCompleted ? Colors.green : null,
          ),
        ),
        tooltip: book.isCompleted ? 'تم الإكمال' : 'لم يتم الإكمال',
        onTap: (item) => _toggleComplete(index),
      ),
    );

    // 5- أكشن المفضلة (AnimatedIconSwitcher)
    actions.add(
      ActionButton(
        buttonWidget: AnimatedIconSwitcher(
          icon: Icon(
            book.isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(book.isFavorite),
            color: book.isFavorite ? Colors.red : null,
          ),
        ),
        tooltip: book.isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
        onTap: (item) => _toggleFavorite(index),
      ),
    );

    // 6- عناصر مرتبطة
    actions.add(
      ActionButton(
        buttonWidget: const Icon(Icons.link),
        tooltip: 'عناصر مرتبطة',
        onTap: (item) {
          Fluttertoast.showToast(msg: 'عرض العناصر المرتبطة');
        },
      ),
    );

    return actions;
  }
}
