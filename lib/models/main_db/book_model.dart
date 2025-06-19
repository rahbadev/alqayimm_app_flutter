class BookModel {
  final int id;
  final String name;
  final int? authorId;
  final int? categoryId;
  final int? bookTypeId;
  final String? aboutBook;
  final String? bookUrl;
  final String? bookVer;
  final String? aboutVer;
  final String? bookThumbUrl;

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
      bookVer: map['book_ver'] as String?,
      aboutVer: map['about_ver'] as String?,
      bookThumbUrl: map['book_thumb_url'] as String?,
    );
  }
}
