import 'package:dio/dio.dart';
import 'package:tribe/core/config/api_config.dart';
import 'package:tribe/core/storage/token_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorageService _tokenStorage;

  ApiClient({TokenStorageService? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorageService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor to add access token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            try {
              // Try to refresh token
              final refreshToken = await _tokenStorage.getRefreshToken();
              if (refreshToken != null) {
                final newAccessToken = await _refreshAccessToken(refreshToken);
                if (newAccessToken != null) {
                  // Retry the original request with new token
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newAccessToken';
                  
                  final response = await _dio.fetch(opts);
                  return handler.resolve(response);
                }
              }
            } catch (e) {
              // Refresh failed, clear tokens and return error
              await _tokenStorage.clearAll();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    // Uncomment for debugging:
    // _dio.interceptors.add(
    //   LogInterceptor(
    //     requestBody: true,
    //     responseBody: true,
    //     error: true,
    //   ),
    // );
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      // Create a new Dio instance without interceptors for refresh token call
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.apiBaseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      final response = await refreshDio.post(
        ApiConfig.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String;
        await _tokenStorage.saveAccessToken(newAccessToken);
        return newAccessToken;
      }
    } catch (e) {
      // Refresh failed
    }
    return null;
  }

  /// Get the underlying Dio instance
  Dio get dio => _dio;

  /// Make a GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make a POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make a PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make a PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make a DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

