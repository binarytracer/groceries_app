import 'package:dio/dio.dart';
import 'package:groceries_app/services/auth_session.dart';

/// Adds the Bearer token to every request. On a 401 it refreshes the token
/// once and retries the request; if the refresh is rejected the session is
/// over and [AuthSession.onExpired] fires.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._session, this._dio);

  final AuthSession _session;
  final Dio _dio;

  static const _retriedKey = 'auth_retried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _session.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 || request.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final bool refreshed;
    try {
      refreshed = await _session.refresh();
    } catch (_) {
      return handler.next(err); // Network trouble: keep the session.
    }
    if (!refreshed) {
      _session.onExpired?.call();
      return handler.next(err);
    }

    request.extra[_retriedKey] = true;
    try {
      handler.resolve(await _dio.fetch<Object?>(request));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
