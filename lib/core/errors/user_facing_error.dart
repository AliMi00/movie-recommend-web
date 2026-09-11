import 'package:dio/dio.dart';

/// Turns a thrown error into something worth showing a user.
///
/// Providers used to store `e.toString()` and screens rendered it directly,
/// which for a DioException is a multi-line dump naming the exception class,
/// the request options and a link to the MDN status-code page. That text was
/// appearing on the discovery screen where the movie cards should be.
///
/// The mapping is deliberately coarse. A person looking at an empty screen
/// needs to know whether to retry, sign in, or wait — not which layer threw.
String userFacingError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;

    if (status != null) {
      // The API wraps failures as {"detail": {"error": {"code", "message"}}}.
      // Its own message is written for humans, so prefer it where present.
      final apiCode = _apiErrorCode(error.response?.data);

      if (apiCode == 'EMAIL_NOT_VERIFIED') {
        return 'Confirm your email address to start getting recommendations.';
      }
      if (status == 401) {
        return 'Your session has expired. Please sign in again.';
      }
      if (status == 403) {
        return "You don't have access to this.";
      }
      if (status == 404) {
        return 'We could not find that.';
      }
      if (status == 429) {
        return 'Too many requests. Give it a minute and try again.';
      }
      if (status >= 500) {
        return 'The server is having trouble. Please try again shortly.';
      }
      return 'That request could not be completed.';
    }

    // No response at all — the request never made it there and back.
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return "Can't reach the server. Check your connection and try again.";
      case DioExceptionType.cancel:
        return 'That request was cancelled.';
      default:
        return "Can't reach the server. Check your connection and try again.";
    }
  }

  return 'Something went wrong. Please try again.';
}

/// Digs the API's own error code out of a response body, tolerating the
/// shapes it actually returns rather than assuming one.
String? _apiErrorCode(dynamic data) {
  if (data is! Map) return null;
  final detail = data['detail'];
  if (detail is Map) {
    final err = detail['error'];
    if (err is Map && err['code'] is String) return err['code'] as String;
  }
  final err = data['error'];
  if (err is Map && err['code'] is String) return err['code'] as String;
  return null;
}
