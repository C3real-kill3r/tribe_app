import 'package:dio/dio.dart';
import 'package:tribe/core/config/api_config.dart';
import 'package:tribe/core/network/api_client.dart';

abstract class FriendRemoteDataSource {
  Future<Map<String, dynamic>> getFriends({
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getFriendRequests({
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getFriendSuggestions({
    int page = 1,
    int limit = 20,
  });
  Future<void> sendFriendRequest(String userId);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> removeFriend(String friendId);
}

class FriendRemoteDataSourceImpl implements FriendRemoteDataSource {
  final ApiClient apiClient;

  FriendRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getFriends({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConfig.friendsEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch friends: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to fetch friends';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch friends: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getFriendRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConfig.friendRequestsEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch friend requests: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to fetch friend requests';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch friend requests: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getFriendSuggestions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConfig.friendSuggestionsEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch friend suggestions: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to fetch friend suggestions';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch friend suggestions: ${e.toString()}');
    }
  }

  @override
  Future<void> sendFriendRequest(String userId) async {
    try {
      await apiClient.post(
        ApiConfig.friendRequestsEndpoint,
        data: {'user_id': userId},
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to send friend request';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to send friend request: ${e.toString()}');
    }
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await apiClient.put(ApiConfig.acceptFriendRequestEndpoint(requestId));
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to accept friend request';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to accept friend request: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFriend(String friendId) async {
    try {
      await apiClient.delete(ApiConfig.removeFriendEndpoint(friendId));
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to remove friend';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to remove friend: ${e.toString()}');
    }
  }
}

