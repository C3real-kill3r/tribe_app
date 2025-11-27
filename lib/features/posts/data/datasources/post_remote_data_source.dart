import 'package:dio/dio.dart';
import 'package:tribe/core/config/api_config.dart';
import 'package:tribe/core/network/api_client.dart';

abstract class PostRemoteDataSource {
  Future<Map<String, dynamic>> getPosts({
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getPost(String postId);
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData);
  Future<void> likePost(String postId);
  Future<Map<String, dynamic>> getPostComments(String postId, {
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> addComment(String postId, String content);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiClient apiClient;

  PostRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getPosts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConfig.postsEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch posts: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to fetch posts';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch posts: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getPost(String postId) async {
    try {
      final response = await apiClient.get(ApiConfig.getPostEndpoint(postId));

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch post: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to fetch post';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch post: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    try {
      final response = await apiClient.post(
        ApiConfig.postsEndpoint,
        data: postData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create post: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to create post';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      await apiClient.post(ApiConfig.likePostEndpoint(postId));
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to like post';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to like post: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getPostComments(String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConfig.getPostCommentsEndpoint(postId),
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch comments: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to fetch comments';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch comments: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> addComment(String postId, String content) async {
    try {
      final response = await apiClient.post(
        ApiConfig.addPostCommentEndpoint(postId),
        data: {'content': content},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to add comment: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to add comment';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to add comment: ${e.toString()}');
    }
  }
}

