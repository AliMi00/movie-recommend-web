import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinreco/core/config/app_config.dart';
import 'package:cinreco/data/repositories/auth_repository.dart';

/// Signing in must fetch the profile with the *new* session's token.
///
/// login() used to call GET /users/me before writing the tokens it had just
/// been issued. The request interceptor attaches whatever access token is in
/// storage, so that request went out carrying the previous session's token and
/// came back with the previous user's profile — which was then saved next to
/// the new user's tokens. Reproduced in the real app: registering a second
/// account showed the first account's address on the confirm-your-email
/// screen, because registration auto-logs-in.
class _FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> values;
  _FakeSecureStorage(this.values);

  @override
  Future<String?> read({
    required String key,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async => values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Answers /users/me according to the bearer token it actually receives, so
/// the test fails if login asks before storing the new one.
class _TokenAwareAdapter implements HttpClientAdapter {
  final List<String?> meRequestTokens = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('/auth/login')) {
      return ResponseBody.fromString(
        '{"accessToken":"token-for-user-B","refreshToken":"refresh-B"}',
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    }

    if (options.path.contains('/users/me')) {
      final auth = options.headers['Authorization'] as String?;
      meRequestTokens.add(auth);
      // Whoever the token belongs to is who this returns.
      final isB = auth != null && auth.contains('token-for-user-B');
      final body = isB
          ? '{"id":2,"email":"userB@example.com","emailVerified":false}'
          : '{"id":1,"email":"userA@example.com","emailVerified":true}';
      return ResponseBody.fromString(
        body,
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    }

    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('login fetches the profile with the newly issued token', () async {
    // A previous session's token is already sitting in storage, exactly as it
    // would be for someone signing in as a second account without logging out.
    final secure = _FakeSecureStorage({
      'access_token': 'token-for-user-A',
      'refresh_token': 'refresh-A',
    });

    final adapter = _TokenAwareAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/v1'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secure.read(key: 'access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    const config = AppConfig(
      baseUrl: 'https://api.example.test/v1',
      useCookieAuth: false,
    );
    final repo = ApiAuthRepository(dio, config, secure);

    final result = await repo.login('userB@example.com', 'Secret123!');

    expect(result.success, isTrue);
    expect(
      adapter.meRequestTokens.single,
      contains('token-for-user-B'),
      reason: 'profile must be fetched with the new session token',
    );
    expect(
      result.user!.email,
      'userB@example.com',
      reason: 'signing in as B must not return A\'s profile',
    );
    expect(result.user!.emailVerified, isFalse);
  });
}
