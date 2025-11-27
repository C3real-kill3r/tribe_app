import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Get base URL from environment variables
  // Falls back to default if not set in .env file
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 
           const String.fromEnvironment(
             'API_BASE_URL',
             defaultValue: 'http://localhost:8000',
           );
  }
  
  // Get API version from environment variables
  static String get apiVersion {
    return dotenv.env['API_VERSION'] ?? 'v1';
  }
  
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
  
  // Environment
  static String get env => dotenv.env['ENV'] ?? 'development';
  
  // Debug mode
  static bool get isDebug {
    final debugStr = dotenv.env['DEBUG'] ?? 'true';
    return debugStr.toLowerCase() == 'true';
  }
  
  // Auth endpoints
  static String get registerEndpoint => '$apiBaseUrl/auth/register';
  static String get loginEndpoint => '$apiBaseUrl/auth/login';
  static String get logoutEndpoint => '$apiBaseUrl/auth/logout';
  static String get refreshTokenEndpoint => '$apiBaseUrl/auth/refresh';
  static String get authMeEndpoint => '$apiBaseUrl/auth/me';
  
  // User endpoints
  static String get meEndpoint => '$apiBaseUrl/users/me';
  static String get updateProfileEndpoint => '$apiBaseUrl/users/me';
  static String get updateProfileImageEndpoint => '$apiBaseUrl/users/me/profile-image';
  static String get updateCoverImageEndpoint => '$apiBaseUrl/users/me/cover-image';
  static String getUserEndpoint(String userId) => '$apiBaseUrl/users/$userId';
  static String getUserGoalsEndpoint(String userId) => '$apiBaseUrl/users/$userId/goals';
  static String getUserPostsEndpoint(String userId) => '$apiBaseUrl/users/$userId/posts';
  
  // Friends endpoints
  static String get friendsEndpoint => '$apiBaseUrl/friends';
  static String get friendRequestsEndpoint => '$apiBaseUrl/friends/requests';
  static String get friendSuggestionsEndpoint => '$apiBaseUrl/friends/suggestions';
  static String acceptFriendRequestEndpoint(String requestId) => '$apiBaseUrl/friends/requests/$requestId/accept';
  static String removeFriendEndpoint(String friendId) => '$apiBaseUrl/friends/$friendId';
  
  // Conversations endpoints
  static String get conversationsEndpoint => '$apiBaseUrl/conversations';
  static String getConversationMessagesEndpoint(String conversationId) => '$apiBaseUrl/conversations/$conversationId/messages';
  static String sendMessageEndpoint(String conversationId) => '$apiBaseUrl/conversations/$conversationId/messages';
  
  // Goals endpoints
  static String get goalsEndpoint => '$apiBaseUrl/goals';
  static String getGoalEndpoint(String goalId) => '$apiBaseUrl/goals/$goalId';
  static String updateGoalEndpoint(String goalId) => '$apiBaseUrl/goals/$goalId';
  static String addGoalContributionEndpoint(String goalId) => '$apiBaseUrl/goals/$goalId/contributions';
  static String addGoalMilestoneEndpoint(String goalId) => '$apiBaseUrl/goals/$goalId/milestones';
  
  // Posts endpoints
  static String get postsEndpoint => '$apiBaseUrl/posts';
  static String getPostEndpoint(String postId) => '$apiBaseUrl/posts/$postId';
  static String likePostEndpoint(String postId) => '$apiBaseUrl/posts/$postId/like';
  static String getPostCommentsEndpoint(String postId) => '$apiBaseUrl/posts/$postId/comments';
  static String addPostCommentEndpoint(String postId) => '$apiBaseUrl/posts/$postId/comments';
  
  // Stories endpoints
  static String get storiesEndpoint => '$apiBaseUrl/stories';
  
  // Notifications endpoints
  static String get notificationsEndpoint => '$apiBaseUrl/notifications';
  static String markNotificationReadEndpoint(String notificationId) => '$apiBaseUrl/notifications/$notificationId/read';
  static String get notificationPreferencesEndpoint => '$apiBaseUrl/notifications/preferences';
}

