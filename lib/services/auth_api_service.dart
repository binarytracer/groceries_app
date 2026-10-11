import 'package:dio/dio.dart';
import 'package:groceries_app/services/api_errors.dart';
import 'package:groceries_app/services/dto/auth_tokens_dto.dart';

class AuthException implements Exception {
  AuthException(this.message, {this.rejected = false});

  final String message;

  /// The server answered 401: the credentials or refresh token are no good.
  /// False for network failures, where retrying later may work.
  final bool rejected;

  @override
  String toString() => message;
}

/// Login and token refresh. Uses a Dio without the auth interceptor, so a
/// failing refresh can never trigger another refresh.
class AuthApiService {
  AuthApiService(this._dio);

  final Dio _dio;

  Future<AuthTokensDto> login(String username, String password) => _send(
    'Invalid username or password.',
    () => _dio.post<Map<String, Object?>>(
      '/auth',
      data: {'username': username, 'password': password},
    ),
  );

  Future<AuthTokensDto> refresh(String refreshToken) => _send(
    'Your session expired. Please sign in again.',
    () => _dio.post<Map<String, Object?>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    ),
  );

  Future<AuthTokensDto> _send(
    String rejectedMessage,
    Future<Response<Map<String, Object?>>> Function() request,
  ) async {
    try {
      return AuthTokensDto.fromJson((await request()).data!);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) throw AuthException(rejectedMessage, rejected: true);
      throw AuthException(
        status != null ? 'Sign in failed ($status).' : transportErrorMessage(e),
      );
    }
  }
}
