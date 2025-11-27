import 'package:tribe/features/auth/domain/entities/user.dart';
import 'package:tribe/features/user/data/datasources/user_remote_data_source.dart';
import 'package:tribe/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> getCurrentUserProfile() async {
    return await remoteDataSource.getCurrentUserProfile();
  }

  @override
  Future<User> updateUserProfile({
    String? fullName,
    String? username,
    String? bio,
    String? email,
  }) async {
    return await remoteDataSource.updateUserProfile(
      fullName: fullName,
      username: username,
      bio: bio,
      email: email,
    );
  }
}

