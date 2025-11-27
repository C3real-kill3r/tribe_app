import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tribe/core/config/api_config.dart';
import 'package:tribe/core/network/api_client.dart';
import 'package:tribe/core/storage/token_storage_service.dart';
import 'package:tribe/features/auth/data/models/user_model.dart';
import 'dart:io';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(String fullName, String username, String email, String password, String confirmPassword);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final TokenStorageService tokenStorage;

  AuthRemoteDataSourceImpl({
    required this.apiClient,
    required this.tokenStorage,
  });

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    String deviceType;
    String? deviceId;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceType = 'android';
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceType = 'ios';
      deviceId = iosInfo.identifierForVendor;
    } else {
      deviceType = 'web';
    }

    return {
      'device_type': deviceType,
      'device_id': deviceId,
      'app_version': packageInfo.version,
    };
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final deviceInfo = await _getDeviceInfo();
      
      final response = await apiClient.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
          'device_info': deviceInfo,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Save tokens
        await tokenStorage.saveAccessToken(data['access_token'] as String);
        await tokenStorage.saveRefreshToken(data['refresh_token'] as String);
        
        // Get user data
        final userData = data['user'] as Map<String, dynamic>;
        
        return UserModel.fromJson(userData);
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Login failed';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signup(
    String fullName,
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await apiClient.post(
        ApiConfig.registerEndpoint,
        data: {
          'email': email,
          'username': username,
          'full_name': fullName,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        
        // Save tokens
        await tokenStorage.saveAccessToken(data['access_token'] as String);
        await tokenStorage.saveRefreshToken(data['refresh_token'] as String);
        
        // Get user data
        final userData = data['user'] as Map<String, dynamic>;
        
        return UserModel.fromJson(userData);
      } else {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Registration failed';
        
        if (errorData is Map<String, dynamic>) {
          // Handle validation errors
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
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          await apiClient.post(
            ApiConfig.logoutEndpoint,
            data: {'refresh_token': refreshToken},
          );
        } catch (e) {
          // Even if API call fails, clear local tokens
        }
      }
      
      await tokenStorage.clearAll();
    } catch (e) {
      // Clear tokens even if logout API call fails
      await tokenStorage.clearAll();
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // First check if we have a token
      final token = await tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      // Try to get user from API
      final response = await apiClient.get(ApiConfig.authMeEndpoint);

      if (response.statusCode == 200) {
        final userData = response.data as Map<String, dynamic>;
        await tokenStorage.saveUserData(userData.toString());
        return UserModel.fromJson(userData);
      } else {
        // Token might be invalid, clear it
        await tokenStorage.clearAll();
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Unauthorized - clear tokens
        await tokenStorage.clearAll();
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
