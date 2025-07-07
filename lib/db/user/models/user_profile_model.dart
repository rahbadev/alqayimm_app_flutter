class UserProfileModel {
  final int id;
  final String? fullName;
  final String? email;
  final String? googleDriveId;
  final DateTime? lastBackupDate;
  final DateTime? lastRestoreDate;
  final bool isSignedIn;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.id,
    this.fullName,
    this.email,
    this.googleDriveId,
    this.lastBackupDate,
    this.lastRestoreDate,
    this.isSignedIn = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as int,
      fullName: map['full_name'] as String?,
      email: map['email'] as String?,
      googleDriveId: map['google_drive_id'] as String?,
      lastBackupDate:
          map['last_backup_date'] != null
              ? DateTime.parse(map['last_backup_date'] as String)
              : null,
      lastRestoreDate:
          map['last_restore_date'] != null
              ? DateTime.parse(map['last_restore_date'] as String)
              : null,
      isSignedIn: (map['is_signed_in'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'google_drive_id': googleDriveId,
      'last_backup_date': lastBackupDate?.toIso8601String(),
      'last_restore_date': lastRestoreDate?.toIso8601String(),
      'is_signed_in': isSignedIn ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? googleDriveId,
    DateTime? lastBackupDate,
    DateTime? lastRestoreDate,
    bool? isSignedIn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      googleDriveId: googleDriveId ?? this.googleDriveId,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      lastRestoreDate: lastRestoreDate ?? this.lastRestoreDate,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
