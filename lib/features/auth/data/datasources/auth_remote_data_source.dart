import 'package:tribe/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(String name, String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return const UserModel(
      id: '1',
      email: 'test@tribe.com',
      name: 'Test User',
      photoUrl: 'https://i.pravatar.cc/150?u=1',
    );
  }

  @override
  Future<UserModel> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: '1',
      email: email,
      name: name,
      photoUrl: 'https://i.pravatar.cc/150?u=1',
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Return null for now to force login
    return null;
  }
}
