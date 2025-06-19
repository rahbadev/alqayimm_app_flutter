import 'package:flutter/cupertino.dart';

enum Type { category, level, bookType }

// كلاس أساسي
class TypeModel {
  final int id;
  final String name;
  final int? childCount;
  final IconData? icon;
  final Type type;

  TypeModel({
    required this.id,
    required this.name,
    required this.childCount,
    required this.type,
    this.icon,
  });
}

@override
// التصنيفات
class CategoryModel extends TypeModel {
  CategoryModel({
    required super.id,
    required super.name,
    required super.childCount,
    super.icon,
  }) : super(type: Type.category);

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int,
      name: map['name'] as String,
      childCount: map['child_count'] as int? ?? 0,
    );
  }
}

// المستويات
class LevelModel extends TypeModel {
  LevelModel({
    required super.id,
    required super.name,
    required super.childCount,
    super.icon,
  }) : super(type: Type.level);

  factory LevelModel.fromMap(Map<String, dynamic> map) {
    return LevelModel(
      id: map['id'] as int,
      name: map['name'] as String,
      childCount: map['child_count'] as int? ?? 0,
    );
  }
}

// أنواع الكتب
class BookTypeModel extends TypeModel {
  BookTypeModel({
    required super.id,
    required super.name,
    required super.childCount,
    super.icon,
  }) : super(type: Type.bookType);

  factory BookTypeModel.fromMap(Map<String, dynamic> map) {
    return BookTypeModel(
      id: map['id'] as int,
      name: map['name'] as String,
      childCount: map['child_count'] as int? ?? 0,
    );
  }
}
