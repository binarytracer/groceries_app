import 'package:groceries_app/services/auth_api_service.dart';
import 'package:groceries_app/services/dto/auth_tokens_dto.dart';
import 'package:groceries_app/services/token_storage.dart';

class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage([this.refreshToken]);

  String? refreshToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> writeRefreshToken(String token) async => refreshToken = token;

  @override
  Future<void> clear() async => refreshToken = null;
}

/// Accepts one username/password pair and any refresh token starting with
/// `refresh-`. Counts calls so tests can check refreshes are shared.
class FakeAuthApiService implements AuthApiService {
  static const username = 'admin';
  static const password = 'secret';

  var loginCalls = 0;
  var refreshCalls = 0;

  /// Set to make refresh fail like a network error rather than a rejection.
  var networkDown = false;

  var _n = 0;

  AuthTokensDto _tokens() {
    _n++;
    return AuthTokensDto(
      accessToken: 'access-$_n',
      refreshToken: 'refresh-$_n',
    );
  }

  @override
  Future<AuthTokensDto> login(String user, String pass) async {
    loginCalls++;
    if (user != username || pass != password) {
      throw AuthException('Invalid username or password.', rejected: true);
    }
    return _tokens();
  }

  @override
  Future<AuthTokensDto> refresh(String refreshToken) async {
    refreshCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (networkDown) throw AuthException('Network error.');
    if (!refreshToken.startsWith('refresh-')) {
      throw AuthException('Session expired.', rejected: true);
    }
    return _tokens();
  }
}
