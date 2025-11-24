import 'package:tribe/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tribe/features/auth/domain/entities/user.dart';
import 'package:tribe/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<User> signup(String name, String email, String password) async {
    return await remoteDataSource.signup(name, email, password);
  }

  @override
  Future<void> logout() async {
    return await remoteDataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }
}
