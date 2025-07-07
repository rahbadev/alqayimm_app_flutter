class UserDatabaseConstants {
  static const String dbName = 'user_database.db';
  static const int dbVersion = 1;

  static const String userItemStatusTable = 'user_item_status';
  static const String userNotesTable = 'user_notes';
  static const String userProfileTable = 'user_profile';
  static const String bookmarksTable = 'bookmarks';
}

class UserItemStatusFields {
  static const String id = 'id';
  static const String itemId = 'item_id';
  static const String itemType = 'item_type';
  static const String isFavorite = 'is_favorite';
  static const String completedAt = 'completed_at';
  static const String lastPosition = 'last_position';
}

class UserNoteFields {
  static const String id = 'id';
  static const String title = 'note_title';
  static const String content = 'note_content';
  static const String tags = 'tags';
  static const String createdAt = 'created_at';
}

class UserProfileFields {
  static const String id = 'id';
  static const String fullName = 'full_name';
  static const String email = 'email';
  static const String googleDriveId = 'google_drive_id';
  static const String lastBackupDate = 'last_backup_date';
  static const String lastRestoreDate = 'last_restore_date';
  static const String isSignedIn = 'is_signed_in';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class UserBookmarkFields {
  static const String id = 'id';
  static const String itemId = 'item_id';
  static const String itemType = 'item_type';
  static const String position = 'position';
  static const String title = 'title';
  static const String createdAt = 'created_at';
}

enum ItemType {
  book('book'),
  lesson('lesson');

  final String value;
  const ItemType(this.value);

  static ItemType fromValue(String value) {
    return ItemType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw Exception('Unknown ItemType: $value'),
    );
  }

  static String allowedForNotesCheck() =>
      "('${ItemType.lesson.value}', '${ItemType.book.value}')";
}
