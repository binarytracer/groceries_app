import 'package:dio/dio.dart';

/// A readable message for a request that got no HTTP response at all.
String transportErrorMessage(DioException e) => switch (e.type) {
  DioExceptionType.connectionError ||
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout =>
    "Can't reach the server. Check that the API is running and you are "
        'online.',
  DioExceptionType.badCertificate =>
    "Couldn't make a secure connection to the server.",
  _ => 'Something went wrong. Please try again.',
};
