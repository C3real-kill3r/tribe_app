import 'package:tribe/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.fullName,
    super.bio,
    super.profileImageUrl,
    super.coverImageUrl,
    super.goalsAchieved = 0,
    super.photosShared = 0,
    super.emailVerified = false,
    super.isActive = true,
    super.lastSeenAt,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      bio: json['bio'],
      profileImageUrl: json['profile_image_url'] ?? json['profileImageUrl'],
      coverImageUrl: json['cover_image_url'] ?? json['coverImageUrl'],
      goalsAchieved: json['goals_achieved'] ?? json['goalsAchieved'] ?? 0,
      photosShared: json['photos_shared'] ?? json['photosShared'] ?? 0,
      emailVerified: json['email_verified'] ?? json['emailVerified'] ?? false,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'])
          : json['lastSeenAt'] != null
              ? DateTime.parse(json['lastSeenAt'])
              : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'bio': bio,
      'profile_image_url': profileImageUrl,
      'cover_image_url': coverImageUrl,
      'goals_achieved': goalsAchieved,
      'photos_shared': photosShared,
      'email_verified': emailVerified,
      'is_active': isActive,
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
