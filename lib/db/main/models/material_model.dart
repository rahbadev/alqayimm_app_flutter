class MaterialModel {
  final int id;
  final String name;
  final String? aboutMaterial;
  final int? authorId;
  final int? levelId;
  final int? categoryId;
  final String? authorName;
  final String? levelName;
  final String? categoryName;
  final int lessonsCount;

  MaterialModel({
    required this.id,
    required this.name,
    this.aboutMaterial,
    this.authorId,
    this.levelId,
    this.categoryId,
    this.authorName,
    this.levelName,
    this.categoryName,
    this.lessonsCount = 0,
  });

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] as int,
      name: map['name'] as String,
      aboutMaterial: map['about_material'] as String?,
      authorId: map['author_id'] as int?,
      levelId: map['level_id'] as int?,
      categoryId: map['category_id'] as int?,
      authorName: map['author_name'] as String?,
      levelName: map['level_name'] as String?,
      categoryName: map['category_name'] as String?,
      lessonsCount: map['lessons_count'] as int? ?? 0,
    );
  }
}
