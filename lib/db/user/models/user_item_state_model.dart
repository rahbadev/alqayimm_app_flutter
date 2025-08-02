import 'package:alqayimm_app_flutter/db/user/db_constants.dart';

class UserItemStatusModel {
  final int id;
  final int itemId;
  final ItemType itemType;
  final bool? isFavorite;
  final String? _completedAt;
  final int? lastPosition;

  const UserItemStatusModel({
    required this.id,
    required this.itemId,
    required this.itemType,
    this.isFavorite,
    String? completedAt,
    this.lastPosition,
  }) : _completedAt = completedAt;

  factory UserItemStatusModel.fromMap(Map<String, dynamic> map) {
    return UserItemStatusModel(
      id: map[UserItemStatusFields.id] as int,
      itemId: map[UserItemStatusFields.itemId] as int,
      itemType: ItemType.fromValue(
        map[UserItemStatusFields.itemType] as String,
      ),
      isFavorite: map[UserItemStatusFields.isFavorite] == 1,
      completedAt: map[UserItemStatusFields.completedAt] as String? ?? '',
      lastPosition: map[UserItemStatusFields.lastPosition] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserItemStatusFields.id: id,
      UserItemStatusFields.itemId: itemId,
      UserItemStatusFields.itemType: itemType.value,
      UserItemStatusFields.isFavorite: isFavorite == true ? 1 : 0,
      UserItemStatusFields.completedAt: _completedAt ?? '',
      UserItemStatusFields.lastPosition: lastPosition,
    };
  }

  /// التحقق من حالة الإكمال
  bool get isCompleted => _completedAt != null && _completedAt.isNotEmpty;

  String? get completedString {
    if (_completedAt == null) return null;
    return _completedAt;
  }

  DateTime? get completedDate {
    if (_completedAt == null || _completedAt.isEmpty) return null;
    return DateTime.parse(_completedAt);
  }

  /// التحقق من وجود موضع محفوظ
  bool get hasPosition => lastPosition != null && lastPosition! > 0;

  @override
  String toString() {
    return 'UserItemStatusModel(id: $id, itemId: $itemId, itemType: $itemType, '
        'isFavorite: $isFavorite, completedAt: $completedDate, lastPosition: $lastPosition)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserItemStatusModel &&
        other.id == id &&
        other.itemId == itemId &&
        other.itemType == itemType &&
        other.isFavorite == isFavorite &&
        other.completedDate == completedDate &&
        other.lastPosition == lastPosition;
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    itemType,
    isFavorite,
    completedDate,
    lastPosition,
  );
}
