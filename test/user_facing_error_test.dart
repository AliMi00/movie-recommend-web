import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinreco/core/errors/user_facing_error.dart';

/// Providers used to store `e.toString()` and screens rendered it verbatim,
/// so a failed request put a multi-line DioException dump on the discovery
/// screen where the movie cards belong. These pin that the user never sees
/// exception-speak again.
void main() {
  Response<dynamic> res(int status, [dynamic data]) => Response(
    requestOptions: RequestOptions(path: '/v1/movies/recommendations'),
    statusCode: status,
    data: data,
  );

  DioException dio(int? status, {dynamic data, DioExceptionType? type}) =>
      DioException(
        requestOptions: RequestOptions(path: '/v1/movies/recommendations'),
        response: status == null ? null : res(status, data),
        type: type ?? DioExceptionType.badResponse,
      );

  group('never leaks exception-speak', () {
    test('no message contains DioException or stack-trace wording', () {
      final samples = <Object>[
        dio(
          403,
          data: {
            'detail': {
              'error': {'code': 'EMAIL_NOT_VERIFIED', 'message': 'x'},
            },
          },
        ),
        dio(401),
        dio(404),
        dio(429),
        dio(500),
        dio(418),
        dio(null, type: DioExceptionType.connectionError),
        dio(null, type: DioExceptionType.receiveTimeout),
        Exception('kaboom'),
        StateError('bad state'),
      ];

      for (final s in samples) {
        final msg = userFacingError(s);
        expect(msg, isNotEmpty);
        expect(msg.toLowerCase(), isNot(contains('dioexception')));
        expect(msg.toLowerCase(), isNot(contains('requestoptions')));
        expect(msg.toLowerCase(), isNot(contains('exception')));
        expect(msg, isNot(contains('\n')), reason: 'must be one line: $msg');
      }
    });
  });

  group('maps the cases that matter', () {
    test('EMAIL_NOT_VERIFIED explains what to do', () {
      final msg = userFacingError(
        dio(
          403,
          data: {
            'detail': {
              'error': {'code': 'EMAIL_NOT_VERIFIED', 'message': 'x'},
            },
          },
        ),
      );
      expect(msg.toLowerCase(), contains('confirm'));
      expect(msg.toLowerCase(), contains('email'));
    });

    test('401 tells them to sign in rather than blaming the network', () {
      expect(userFacingError(dio(401)).toLowerCase(), contains('sign in'));
    });

    test('no response reads as a connectivity problem', () {
      final msg = userFacingError(
        dio(null, type: DioExceptionType.connectionError),
      );
      expect(msg.toLowerCase(), contains('connection'));
    });

    test('5xx blames the server, not the user', () {
      expect(userFacingError(dio(503)).toLowerCase(), contains('server'));
    });

    test('a plain 403 without the API code stays generic', () {
      // Must not claim the email is unverified when that is not the reason.
      final msg = userFacingError(dio(403)).toLowerCase();
      expect(msg, isNot(contains('email')));
    });

    test('tolerates unexpected body shapes without throwing', () {
      for (final body in <dynamic>[
        null,
        'plain string',
        <String, dynamic>{'detail': 'not a map'},
        <String, dynamic>{'error': 'not a map'},
        <String, dynamic>{'detail': <String, dynamic>{}},
      ]) {
        expect(() => userFacingError(dio(403, data: body)), returnsNormally);
      }
    });
  });
}
