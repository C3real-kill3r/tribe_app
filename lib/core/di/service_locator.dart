import 'package:get_it/get_it.dart';
import 'package:tribe/core/theme/theme_provider.dart';
import 'package:tribe/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tribe/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tribe/features/auth/domain/repositories/auth_repository.dart';
import 'package:tribe/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Theme Provider
  sl.registerLazySingleton<ThemeProvider>(() => ThemeProvider());

  // Bloc
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => MockAuthRemoteDataSourceImpl(),
  );
}
