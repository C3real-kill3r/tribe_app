import 'package:dio/dio.dart';
import 'package:tribe/core/config/api_config.dart';
import 'package:tribe/core/network/api_client.dart';

abstract class GoalRemoteDataSource {
  Future<Map<String, dynamic>> getGoals({
    int page = 1,
    int limit = 20,
    String? status,
    String? category,
    String? type,
  });
  Future<Map<String, dynamic>> getGoal(String goalId);
  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> goalData);
  Future<Map<String, dynamic>> updateGoal(String goalId, Map<String, dynamic> goalData);
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final ApiClient apiClient;

  GoalRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getGoals({
    int page = 1,
    int limit = 20,
    String? status,
    String? category,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (type != null) queryParams['type'] = type;

      final response = await apiClient.get(
        ApiConfig.goalsEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch goals: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to fetch goals';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch goals: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getGoal(String goalId) async {
    try {
      final response = await apiClient.get(ApiConfig.getGoalEndpoint(goalId));

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch goal: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to fetch goal';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch goal: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> goalData) async {
    try {
      final response = await apiClient.post(
        ApiConfig.goalsEndpoint,
        data: goalData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create goal: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to create goal';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to create goal: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> updateGoal(String goalId, Map<String, dynamic> goalData) async {
    try {
      final response = await apiClient.put(
        ApiConfig.updateGoalEndpoint(goalId),
        data: goalData,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update goal: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to update goal';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to update goal: ${e.toString()}');
    }
  }
}

