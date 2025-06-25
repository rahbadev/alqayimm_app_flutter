import 'package:alqayimm_app_flutter/db/main/enums.dart';

class BookModel {
  final int id;
  final String name;
  final int? authorId;
  final int? categoryId;
  final int? bookTypeId;
  final String? aboutBook;
  final String? bookUrl;
  final int? bookVer;
  final String? aboutVer;
  final String? bookThumbUrl;
  final String? authorName; // جديد
  final String? categoryName; // جديد
  final DownloadStatus? downloadStatus;
  final bool isCompleted;
  final bool isFavorite; // جديد

  BookModel({
    required this.id,
    required this.name,
    this.authorId,
    this.categoryId,
    this.bookTypeId,
    this.aboutBook,
    this.bookUrl,
    this.bookVer,
    this.aboutVer,
    this.bookThumbUrl,
    this.authorName,
    this.categoryName,
    this.downloadStatus = DownloadStatus.notDownloaded,
    this.isCompleted = false,
    this.isFavorite = false, // جديد
  });

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] as int,
      name: map['name'] as String,
      authorId: map['author_id'] as int?,
      categoryId: map['category_id'] as int?,
      bookTypeId: map['book_type_id'] as int?,
      aboutBook: map['about_book'] as String?,
      bookUrl: map['book_url'] as String?,
      bookVer: map['book_ver'] as int?,
      aboutVer: map['about_ver'] as String?,
      bookThumbUrl: map['book_thumb_url'] as String?,
      authorName: map['author_name'] as String?,
      categoryName: map['category_name'] as String?,
    );
  }

  BookModel copyWith({
    int? id,
    String? name,
    int? authorId,
    int? categoryId,
    int? bookTypeId,
    String? aboutBook,
    String? bookUrl,
    int? bookVer,
    String? aboutVer,
    String? bookThumbUrl,
    String? authorName,
    String? categoryName,
    DownloadStatus? downloadStatus,
    bool? isCompleted,
    bool? isFavorite, // جديد
  }) {
    return BookModel(
      id: id ?? this.id,
      name: name ?? this.name,
      authorId: authorId ?? this.authorId,
      categoryId: categoryId ?? this.categoryId,
      bookTypeId: bookTypeId ?? this.bookTypeId,
      aboutBook: aboutBook ?? this.aboutBook,
      bookUrl: bookUrl ?? this.bookUrl,
      bookVer: bookVer ?? this.bookVer,
      aboutVer: aboutVer ?? this.aboutVer,
      bookThumbUrl: bookThumbUrl ?? this.bookThumbUrl,
      authorName: authorName ?? this.authorName,
      categoryName: categoryName ?? this.categoryName,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite, // جديد
    );
  }
}
