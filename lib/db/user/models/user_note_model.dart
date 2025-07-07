import 'package:alqayimm_app_flutter/db/user/db_constants.dart';

class UserNoteModel {
  final int id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;

  UserNoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
  });

  factory UserNoteModel.fromMap(Map<String, dynamic> map) {
    return UserNoteModel(
      id: map[UserNoteFields.id] as int,
      title: map[UserNoteFields.title] as String,
      content: map[UserNoteFields.content] as String,
      tags:
          (map[UserNoteFields.tags] as String)
              .split(',')
              .where((tag) => tag.isNotEmpty)
              .toList(),
      createdAt: DateTime.parse(map[UserNoteFields.createdAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserNoteFields.id: id,
      UserNoteFields.title: title,
      UserNoteFields.content: content,
      UserNoteFields.tags: tags.join(','),
      UserNoteFields.createdAt: createdAt.toIso8601String(),
    };
  }

  UserNoteModel copyWith({
    int? id,
    String? title,
    String? content,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserNoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
