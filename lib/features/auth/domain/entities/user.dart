import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? bio;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final int goalsAchieved;
  final int photosShared;
  final bool emailVerified;
  final bool isActive;
  final DateTime? lastSeenAt;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.bio,
    this.profileImageUrl,
    this.coverImageUrl,
    this.goalsAchieved = 0,
    this.photosShared = 0,
    this.emailVerified = false,
    this.isActive = true,
    this.lastSeenAt,
    required this.createdAt,
  });

  // Convenience getter for display name
  String get displayName => fullName;

  // Convenience getter for photo URL (backward compatibility)
  String? get photoUrl => profileImageUrl;

  // Convenience getter for name (backward compatibility)
  String get name => fullName;

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        fullName,
        bio,
        profileImageUrl,
        coverImageUrl,
        goalsAchieved,
        photosShared,
        emailVerified,
        isActive,
        lastSeenAt,
        createdAt,
      ];
}
