import 'package:tribe/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> getCurrentUserProfile();
  Future<User> updateUserProfile({
    String? fullName,
    String? username,
    String? bio,
    String? email,
  });
}

