import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the refresh token lives between app launches.
abstract interface class TokenStorage {
  Future<String?> readRefreshToken();
  Future<void> writeRefreshToken(String token);
  Future<void> clear();
}

/// Keystore (Android) / Keychain (iOS) backed storage.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _refreshKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _refreshKey, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _refreshKey);
}
