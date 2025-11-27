import 'package:get_it/get_it.dart';
import 'package:tribe/core/network/api_client.dart';
import 'package:tribe/core/storage/token_storage_service.dart';
import 'package:tribe/core/theme/theme_provider.dart';
import 'package:tribe/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tribe/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tribe/features/auth/domain/repositories/auth_repository.dart';
import 'package:tribe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tribe/features/user/data/datasources/user_remote_data_source.dart';
import 'package:tribe/features/user/data/repositories/user_repository_impl.dart';
import 'package:tribe/features/user/domain/repositories/user_repository.dart';
import 'package:tribe/features/user/presentation/bloc/user_bloc.dart';
import 'package:tribe/features/chat/data/datasources/conversation_remote_data_source.dart';
import 'package:tribe/features/chat/presentation/bloc/conversation_bloc.dart';
import 'package:tribe/features/chat/presentation/bloc/message_bloc.dart';
import 'package:tribe/features/goals/data/datasources/goal_remote_data_source.dart';
import 'package:tribe/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:tribe/features/friends/data/datasources/friend_remote_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core Services
  sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(tokenStorage: sl()));

  // Theme Provider
  sl.registerLazySingleton<ThemeProvider>(() => ThemeProvider());

  // Auth Bloc
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Auth Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      apiClient: sl(),
      tokenStorage: sl(),
    ),
  );

  // User Data Source
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(apiClient: sl()),
  );

  // User Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );

  // User Bloc
  sl.registerFactory(() => UserBloc(userRepository: sl()));

  // Conversation Data Source
  sl.registerLazySingleton<ConversationRemoteDataSource>(
    () => ConversationRemoteDataSourceImpl(apiClient: sl()),
  );

  // Conversation Bloc
  sl.registerFactory(() => ConversationBloc(conversationDataSource: sl()));

  // Message Bloc
  sl.registerFactory(() => MessageBloc(conversationDataSource: sl()));

  // Goal Data Source
  sl.registerLazySingleton<GoalRemoteDataSource>(
    () => GoalRemoteDataSourceImpl(apiClient: sl()),
  );

  // Post Data Source
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(apiClient: sl()),
  );

  // Friend Data Source
  sl.registerLazySingleton<FriendRemoteDataSource>(
    () => FriendRemoteDataSourceImpl(apiClient: sl()),
  );
}
