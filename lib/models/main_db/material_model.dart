class MaterialModel {
  final int id;
  final String name;
  final String? aboutMaterial;
  final int? authorId;
  final int? levelId;
  final int? categoryId;
  final String? authorName;    // جديد
  final String? levelName;     // جديد
  final String? categoryName;  // جديد

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
  });

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] as int,
      name: map['name'] as String,
      aboutMaterial: map['about_material'] as String?,
      authorId: map['author_id'] as int?,
      levelId: map['level_id'] as int?,
      categoryId: map['category_id'] as int?,
      authorName: map['author_name'] as String?,      // جديد
      levelName: map['level_name'] as String?,        // جديد
      categoryName: map['category_name'] as String?,  // جديد
    );
  }
}
