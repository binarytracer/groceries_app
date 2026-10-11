import 'package:groceries_app/services/auth_api_service.dart';
import 'package:groceries_app/services/token_storage.dart';

/// The signed-in session: the access token lives in memory only, the refresh
/// token in secure storage.
class AuthSession {
  AuthSession(this._storage, this._api);

  final TokenStorage _storage;
  final AuthApiService _api;

  String? accessToken;

  /// Called when the session can no longer be refreshed.
  void Function()? onExpired;

  Future<bool>? _refreshing;

  /// On app start: signs back in from the stored refresh token, if any.
  /// Throws [AuthException] on network failure, and keeps the token.
  Future<bool> restore() async {
    if (await _storage.readRefreshToken() == null) return false;
    return refresh();
  }

  Future<void> login(String username, String password) async {
    final tokens = await _api.login(username, password);
    accessToken = tokens.accessToken;
    await _storage.writeRefreshToken(tokens.refreshToken);
  }

  /// Gets a new access token. Concurrent callers share one request.
  /// Returns false when there is no refresh token or the server rejects it
  /// (the stored session is then cleared).
  Future<bool> refresh() =>
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  Future<bool> _refresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) return false;
    try {
      final tokens = await _api.refresh(refreshToken);
      accessToken = tokens.accessToken;
      await _storage.writeRefreshToken(tokens.refreshToken);
      return true;
    } on AuthException catch (e) {
      if (!e.rejected) rethrow;
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    accessToken = null;
    await _storage.clear();
  }
}
