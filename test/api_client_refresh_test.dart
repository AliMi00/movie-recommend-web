import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinreco/core/config/app_config.dart';
import 'package:cinreco/data/services/api_client.dart';

/// In-memory stand-in for the platform keystore.
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
  Future<void> deleteAll({
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async => values.clear();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Serves 401 for protected paths until a refresh has happened, and records
/// how many times /auth/refresh was actually called.
class _FakeAdapter implements HttpClientAdapter {
  int refreshCalls = 0;
  int protectedCalls = 0;
  bool tokenRotated = false;

  /// Completer used to hold the refresh response open, guaranteeing the four
  /// protected requests really are in flight at the same time. Without this
  /// the test could pass by accident on a fast sequential run.
  final Completer<void> releaseRefresh = Completer<void>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('auth/refresh')) {
      refreshCalls++;
      await releaseRefresh.future;
      tokenRotated = true;
      return ResponseBody.fromString(
        '{"accessToken":"new-access","refreshToken":"new-refresh"}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    protectedCalls++;
    final auth = options.headers['Authorization'];
    if (auth == 'Bearer new-access') {
      return ResponseBody.fromString(
        '{"ok":true}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      '{"detail":{"error":{"code":"TOKEN_EXPIRED"}}}',
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 401s the protected call, then fails the refresh at the transport level.
class _OfflineAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('auth/refresh')) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'no network',
      );
    }
    return ResponseBody.fromString(
      '{"detail":{"error":{"code":"TOKEN_EXPIRED"}}}',
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'concurrent 401s trigger exactly one refresh and all requests recover',
    () async {
      final store = <String, String>{
        'access_token': 'stale-access',
        'refresh_token': 'valid-refresh',
      };
      final adapter = _FakeAdapter();

      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              baseUrl: 'https://api.example.test/v1',
              useCookieAuth: false,
            ),
          ),
          secureStorageProvider.overrideWithValue(_FakeSecureStorage(store)),
        ],
      );
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      dio.httpClientAdapter = adapter;

      // Four parallel calls, exactly like several providers fetching on app open.
      final inFlight = Future.wait([
        dio.get('/users/me'),
        dio.get('/movies/recommendations'),
        dio.get('/users/me/stats'),
        dio.get('/users/me/preferences'),
      ]);

      // Let all four reach the 401 + refresh stage before the refresh resolves.
      await Future.delayed(const Duration(milliseconds: 50));
      adapter.releaseRefresh.complete();

      final responses = await inFlight;

      // The whole point: the rotating refresh token is spent once, not four
      // times. Spending it more than once is what the backend flags as
      // REFRESH_REUSE_DETECTED, which wiped the session and forced re-login.
      expect(adapter.refreshCalls, 1);
      for (final r in responses) {
        expect(r.statusCode, 200);
      }
      expect(store['access_token'], 'new-access');
      expect(store['refresh_token'], 'new-refresh');
    },
  );

  test(
    'a transport failure during refresh does not wipe the session',
    () async {
      final store = <String, String>{
        'access_token': 'stale-access',
        'refresh_token': 'valid-refresh',
      };

      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              baseUrl: 'https://api.example.test/v1',
              useCookieAuth: false,
            ),
          ),
          secureStorageProvider.overrideWithValue(_FakeSecureStorage(store)),
        ],
      );
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      dio.httpClientAdapter = _OfflineAdapter();

      await expectLater(dio.get('/users/me'), throwsA(isA<DioException>()));

      // Being offline says nothing about whether the session is still good, so
      // the tokens must survive — otherwise opening the app without a
      // connection silently logs the user out.
      expect(store['refresh_token'], 'valid-refresh');
    },
  );
}
