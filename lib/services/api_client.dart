import 'package:dio/dio.dart';
import 'package:groceries_app/services/auth_interceptor.dart';
import 'package:groceries_app/services/auth_session.dart';

/// Base URL of the groceries API, set at run time from the env file:
/// `--dart-define-from-file=env/dev.json` (key `API_URL`).
const _apiUrl = String.fromEnvironment('API_URL');

/// A Dio with no interceptors. Used for login and refresh.
Dio createBareClient() => Dio(
  BaseOptions(
    baseUrl: _apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ),
);

/// The shared Dio for authenticated calls. Cross-cutting concerns (auth,
/// logging) belong here as interceptors, not in the services.
Dio createApiClient(AuthSession session) {
  final dio = createBareClient();
  dio.interceptors.add(AuthInterceptor(session, dio));
  return dio;
}
