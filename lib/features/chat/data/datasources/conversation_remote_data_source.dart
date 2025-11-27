import 'package:dio/dio.dart';
import 'package:tribe/core/config/api_config.dart';
import 'package:tribe/core/network/api_client.dart';

abstract class ConversationRemoteDataSource {
  Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getConversationMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  });
  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String content,
  );
}

class ConversationRemoteDataSourceImpl implements ConversationRemoteDataSource {
  final ApiClient apiClient;

  ConversationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConfig.conversationsEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch conversations: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to fetch conversations';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch conversations: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getConversationMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConfig.getConversationMessagesEndpoint(conversationId),
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch messages: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to fetch messages';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch messages: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String content,
  ) async {
    try {
      final response = await apiClient.post(
        ApiConfig.sendMessageEndpoint(conversationId),
        data: {
          'content': content,
          'message_type': 'text',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to send message: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?['message'] ?? 
                           'Failed to send message';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }
}

