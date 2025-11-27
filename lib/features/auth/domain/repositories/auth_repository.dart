import 'package:tribe/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> signup(String fullName, String username, String email, String password, String confirmPassword);
  Future<void> logout();
  Future<User?> getCurrentUser();
}
