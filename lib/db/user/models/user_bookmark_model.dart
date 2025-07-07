import 'package:alqayimm_app_flutter/db/user/db_constants.dart';

class UserBookmarkModel {
  final int id;
  final int itemId;
  final ItemType itemType;
  final int? position;
  final String title;
  final DateTime createdAt;

  UserBookmarkModel({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.position,
    required this.title,
    required this.createdAt,
  });

  factory UserBookmarkModel.fromMap(Map<String, dynamic> map) {
    return UserBookmarkModel(
      id: map[UserBookmarkFields.id] as int,
      itemId: map[UserBookmarkFields.itemId] as int,
      itemType: ItemType.fromValue(map[UserBookmarkFields.itemType] as String),
      position: map[UserBookmarkFields.position] as int?,
      title: map[UserBookmarkFields.title] as String,
      createdAt: DateTime.parse(map[UserBookmarkFields.createdAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserBookmarkFields.id: id,
      UserBookmarkFields.itemId: itemId,
      UserBookmarkFields.itemType: itemType.value,
      UserBookmarkFields.position: position,
      UserBookmarkFields.title: title,
      UserBookmarkFields.createdAt: createdAt.toIso8601String(),
    };
  }

  UserBookmarkModel copyWith({
    int? id,
    int? itemId,
    ItemType? itemType,
    int? position,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserBookmarkModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      position: position ?? this.position,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
