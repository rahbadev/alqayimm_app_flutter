import 'package:alqayimm_app_flutter/db/enums.dart';

abstract class BaseContentModel {
  final int id;
  final int? authorId;
  final String? authorName;
  final int? categoryId;
  final String? categoryName;
  final DownloadStatus downloadStatus;
  final bool isCompleted;
  final bool isFavorite;

  const BaseContentModel({
    required this.id,
    this.authorId,
    this.authorName,
    this.categoryId,
    this.categoryName,
    this.downloadStatus = DownloadStatus.none,
    this.isCompleted = false,
    this.isFavorite = false,
  });

  // جعل copyWith abstract لإجبار الكلاسات الوراثة على تنفيذها
  BaseContentModel copyWith({
    int? id,
    int? authorId,
    String? authorName,
    int? categoryId,
    String? categoryName,
    DownloadStatus? downloadStatus,
    bool? isCompleted,
    bool? isFavorite,
  });

  // دوال مساعدة مفيدة
  bool get hasAuthor => authorName?.isNotEmpty == true;
  bool get hasCategory => categoryName?.isNotEmpty == true;
  bool get isDownloaded => downloadStatus == DownloadStatus.downloaded;
  bool get isDownloading => downloadStatus == DownloadStatus.progress;
}

class LessonModel extends BaseContentModel {
  final String lessonName;
  final int materialId;
  final int? lessonNumber;
  final int? levelId;
  final String? aboutLesson;
  final String? url;
  final int? lessonVer;
  final String? aboutVer;
  final String? materialName;

  const LessonModel({
    required super.id,
    required this.lessonName,
    required this.materialId,
    this.lessonNumber,
    super.authorId,
    this.levelId,
    super.categoryId,
    this.aboutLesson,
    this.url,
    this.lessonVer,
    this.aboutVer,
    super.authorName,
    super.categoryName,
    super.downloadStatus,
    super.isCompleted,
    super.isFavorite,
    this.materialName,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] as int,
      lessonName: map['lesson_name'] as String,
      materialId: map['material_id'] as int,
      materialName: map['material_name'] as String?,
      lessonNumber: map['lesson_number'] as int?,
      authorId: map['author_id'] as int?,
      levelId: map['level_id'] as int?,
      categoryId: map['category_id'] as int?,
      aboutLesson: map['about_lesson'] as String?,
      url: map['url'] as String?,
      lessonVer: map['ver'] as int?,
      aboutVer: map['about_ver'] as String?,
      authorName: map['author_name'] as String?,
      categoryName: map['category_name'] as String?,
    );
  }

  @override
  LessonModel copyWith({
    int? id,
    String? lessonName,
    int? materialId,
    int? lessonNumber,
    int? authorId,
    int? levelId,
    int? categoryId,
    String? aboutLesson,
    String? url,
    int? lessonVer,
    String? aboutVer,
    String? authorName,
    String? categoryName,
    DownloadStatus? downloadStatus,
    bool? isCompleted,
    bool? isFavorite,
    String? materialName,
  }) {
    return LessonModel(
      id: id ?? this.id,
      lessonName: lessonName ?? this.lessonName,
      materialId: materialId ?? this.materialId,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      authorId: authorId ?? this.authorId,
      levelId: levelId ?? this.levelId,
      categoryId: categoryId ?? this.categoryId,
      aboutLesson: aboutLesson ?? this.aboutLesson,
      url: url ?? this.url,
      lessonVer: lessonVer ?? this.lessonVer,
      aboutVer: aboutVer ?? this.aboutVer,
      authorName: authorName ?? this.authorName,
      categoryName: categoryName ?? this.categoryName,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
      materialName: materialName ?? this.materialName,
    );
  }
}

class BookModel extends BaseContentModel {
  final String name;
  final int? bookTypeId;
  final String? aboutBook;
  final String? bookUrl;
  final int? bookVer;
  final String? aboutVer;
  final String? bookThumbUrl;

  const BookModel({
    required super.id,
    required this.name,
    super.authorId,
    super.categoryId,
    this.bookTypeId,
    this.aboutBook,
    this.bookUrl,
    this.bookVer,
    this.aboutVer,
    this.bookThumbUrl,
    super.authorName,
    super.categoryName,
    super.downloadStatus,
    super.isCompleted,
    super.isFavorite,
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

  @override
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
    bool? isFavorite,
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
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
