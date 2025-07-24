import 'package:alqayimm_app_flutter/db/user/db_constants.dart';

class UserItemStatusModel {
  final int id;
  final int itemId;
  final ItemType itemType;
  final bool? isFavorite;
  final DateTime? completedAt;
  final int? lastPosition;

  const UserItemStatusModel({
    required this.id,
    required this.itemId,
    required this.itemType,
    this.isFavorite,
    this.completedAt,
    this.lastPosition,
  });

  factory UserItemStatusModel.fromMap(Map<String, dynamic> map) {
    return UserItemStatusModel(
      id: map[UserItemStatusFields.id] as int,
      itemId: map[UserItemStatusFields.itemId] as int,
      itemType: ItemType.fromValue(
        map[UserItemStatusFields.itemType] as String,
      ),
      isFavorite: map[UserItemStatusFields.isFavorite] == 1,
      completedAt:
          map[UserItemStatusFields.completedAt] != null
              ? DateTime.parse(map[UserItemStatusFields.completedAt] as String)
              : null,
      lastPosition: map[UserItemStatusFields.lastPosition] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserItemStatusFields.id: id,
      UserItemStatusFields.itemId: itemId,
      UserItemStatusFields.itemType: itemType.value,
      UserItemStatusFields.isFavorite: isFavorite == true ? 1 : 0,
      UserItemStatusFields.completedAt: completedAt?.toIso8601String(),
      UserItemStatusFields.lastPosition: lastPosition,
    };
  }

  /// خريطة تحديث تحتوي فقط على القيم غير null
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{
      UserItemStatusFields.itemId: itemId,
      UserItemStatusFields.itemType: itemType.value,
    };

    if (isFavorite != null) {
      map[UserItemStatusFields.isFavorite] = isFavorite! ? 1 : 0;
    }
    if (completedAt != null) {
      map[UserItemStatusFields.completedAt] = completedAt!.toIso8601String();
    }
    if (lastPosition != null) {
      map[UserItemStatusFields.lastPosition] = lastPosition;
    }

    return map;
  }

  /// إنشاء نسخة محدثة
  UserItemStatusModel copyWith({
    int? id,
    int? itemId,
    ItemType? itemType,
    bool? isFavorite,
    DateTime? completedAt,
    int? lastPosition,
    bool clearCompletedAt = false,
    bool clearLastPosition = false,
  }) {
    return UserItemStatusModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      isFavorite: isFavorite ?? this.isFavorite,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      lastPosition:
          clearLastPosition ? null : (lastPosition ?? this.lastPosition),
    );
  }

  /// التحقق من حالة الإكمال
  bool get isCompleted => completedAt != null;

  /// التحقق من وجود موضع محفوظ
  bool get hasPosition => lastPosition != null && lastPosition! > 0;

  @override
  String toString() {
    return 'UserItemStatusModel(id: $id, itemId: $itemId, itemType: $itemType, '
        'isFavorite: $isFavorite, completedAt: $completedAt, lastPosition: $lastPosition)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserItemStatusModel &&
        other.id == id &&
        other.itemId == itemId &&
        other.itemType == itemType &&
        other.isFavorite == isFavorite &&
        other.completedAt == completedAt &&
        other.lastPosition == lastPosition;
  }

  @override
  int get hashCode =>
      Object.hash(id, itemId, itemType, isFavorite, completedAt, lastPosition);
}
