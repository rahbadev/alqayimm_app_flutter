import 'package:alqayimm_app_flutter/db/main/enums.dart';

class LessonModel {
  final int id;
  final String name;
  final int mateialId;
  final int lessonNumber;
  final int? authorId;
  final int? categoryId;
  final String? aboutLesson;
  final String? url;
  final int? lessonVer;
  final String? aboutVer;
  final String? authorName;
  final String? categoryName;
  final DownloadStatus? downloadStatus;
  final bool isCompleted;
  final bool isFavorite;

  LessonModel({
    required this.id,
    required this.name,
    required this.mateialId,
    required this.lessonNumber,
    this.authorId,
    this.categoryId,
    this.aboutLesson,
    this.url,
    this.lessonVer,
    this.aboutVer,
    this.authorName,
    this.categoryName,
    this.downloadStatus = DownloadStatus.notDownloaded,
    this.isCompleted = false,
    this.isFavorite = false,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] as int,
      name: map['name'] as String,
      mateialId: map['material_id'] as int,
      lessonNumber: map['lesson_number'] as int,
      authorId: map['author_id'] as int?,
      categoryId: map['category_id'] as int?,
      aboutLesson: map['about_lesson'] as String?,
      url: map['url'] as String?,
      lessonVer: map['lesson_ver'] as int?,
      aboutVer: map['about_ver'] as String?,
      authorName: map['author_name'] as String?,
      categoryName: map['category_name'] as String?,
    );
  }

  LessonModel copyWith({
    int? id,
    String? name,
    int? mateialId,
    int? lessonNumber,
    int? authorId,
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
  }) {
    return LessonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mateialId: mateialId ?? this.mateialId,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      authorId: authorId ?? this.authorId,
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
    );
  }
}
