import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:groceries_app/services/api_errors.dart';

String messageFor(DioExceptionType type) => transportErrorMessage(
  DioException(requestOptions: RequestOptions(), type: type),
);

void main() {
  test('connection failures and timeouts say the server is unreachable', () {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      expect(messageFor(type), startsWith("Can't reach the server"));
    }
  });

  test('a bad certificate gets its own message', () {
    expect(
      messageFor(DioExceptionType.badCertificate),
      contains('secure connection'),
    );
  });

  test('anything else gets a generic message, not Dio internals', () {
    expect(
      messageFor(DioExceptionType.unknown),
      'Something went wrong. Please try again.',
    );
  });
}
