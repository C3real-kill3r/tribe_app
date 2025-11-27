import 'package:dio/dio.dart';
import 'package:tribe/core/config/api_config.dart';
import 'package:tribe/core/network/api_client.dart';
import 'package:tribe/features/auth/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getCurrentUserProfile();
  Future<UserModel> updateUserProfile({
    String? fullName,
    String? username,
    String? bio,
    String? email,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> getCurrentUserProfile() async {
    try {
      final response = await apiClient.get(ApiConfig.meEndpoint);

      if (response.statusCode == 200) {
        final userData = response.data as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to fetch user profile';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    String? fullName,
    String? username,
    String? bio,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (username != null) data['username'] = username;
      if (bio != null) data['bio'] = bio;
      if (email != null) data['email'] = email;

      final response = await apiClient.put(
        ApiConfig.meEndpoint,
        data: data,
      );

      if (response.statusCode == 200) {
        final userData = response.data as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      } else {
        throw Exception('Failed to update profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Failed to update profile';
        
        if (errorData is Map<String, dynamic>) {
          if (errorData.containsKey('detail')) {
            if (errorData['detail'] is List) {
              final errors = errorData['detail'] as List;
              errorMessage = errors.map((e) => e['msg'] ?? e.toString()).join(', ');
            } else {
              errorMessage = errorData['detail'].toString();
            }
          } else if (errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          }
        }
        
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}

