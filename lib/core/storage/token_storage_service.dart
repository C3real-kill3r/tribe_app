import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: const IOSOptions(
      // Use 'first_unlock_this_device' to allow access after first unlock
      // This ensures tokens are available when the device is unlocked
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save user data as JSON string
  Future<void> saveUserData(String userJson) async {
    await _storage.write(key: _userKey, value: userJson);
  }

  /// Get user data
  Future<String?> getUserData() async {
    return await _storage.read(key: _userKey);
  }

  /// Clear user data only
  Future<void> clearUserData() async {
    await _storage.delete(key: _userKey);
  }

  /// Clear all tokens and user data
  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

