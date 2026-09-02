import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'http_client_adapter_io.dart'
    if (dart.library.html) 'http_client_adapter_web.dart';
import 'local_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  // Ensure baseUrl always ends with a trailing slash for correct relative resolution
  String normalizedBaseUrl = config.baseUrl;
  if (!normalizedBaseUrl.endsWith('/')) {
    normalizedBaseUrl = '$normalizedBaseUrl/';
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: normalizedBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // On web with cookie-based auth, ensure credentials are sent with requests
  if (kIsWeb && config.useCookieAuth) {
    final adapter = createWebHttpClientAdapter(withCredentials: true);
    if (adapter != null) dio.httpClientAdapter = adapter;
  }

  // Single-flight refresh guard.
  //
  // On app open several providers fetch at once (/users/me, the movie stack,
  // stats...). If the 15-minute access token has expired they all 401 at the
  // same moment. The backend rotates refresh tokens and treats a second use
  // of an already-rotated token as theft (REFRESH_REUSE_DETECTED), so letting
  // each 401 fire its own refresh means one succeeds and the rest come back
  // 401 — which used to land in a catch-all that wiped secure storage,
  // logging the user out on almost every launch. Only one refresh may be in
  // flight; everyone else awaits the same future and retries with its result.
  Future<bool>? refreshInFlight;

  /// Returns true when a fresh access token has been stored, false when the
  /// server explicitly rejected the refresh (session genuinely dead).
  /// Throws for transport failures, where the session's validity is unknown.
  Future<bool> runRefresh() async {
    // Sent through the same client (and therefore the same adapter, cookie
    // settings and base URL) as everything else; `isRefresh` keeps the error
    // interceptor below from treating a failed refresh as a request to
    // refresh again.
    final refreshOptions = Options(extra: const {'isRefresh': true});

    final rt = await secureStorage.read(key: 'refresh_token');
    Response res;
    try {
      if (rt != null && rt.isNotEmpty) {
        res = await dio.post(
          'auth/refresh',
          data: {'refresh_token': rt, 'refreshToken': rt},
          options: refreshOptions,
        );
      } else if (config.useCookieAuth) {
        res = await dio.post('auth/refresh', options: refreshOptions);
      } else {
        // Nothing to refresh with at all.
        return false;
      }
    } on DioException catch (err) {
      final status = err.response?.statusCode;
      if (status != null && status >= 400 && status < 500) {
        // The server answered and refused — the refresh token really is
        // expired, revoked, or already rotated.
        return false;
      }
      // Timeout, offline, 5xx: says nothing about the session.
      rethrow;
    }

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      final newAccess = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (newAccess != null && newAccess.isNotEmpty) {
        await secureStorage.write(key: 'access_token', value: newAccess);
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await secureStorage.write(key: 'refresh_token', value: newRefresh);
        }
        return true;
      }
    }
    return false;
  }

  Future<bool> refreshSession() {
    // No await between the null check and the assignment, so concurrent
    // callers in the same event loop all observe the same future.
    return refreshInFlight ??= runRefresh().whenComplete(() {
      refreshInFlight = null;
    });
  }

  // Auth interceptor: attach bearer if present; refresh on 401 if applicable
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Fix leading slash override bug:
        // If path starts with '/', strip it so that Dio resolves it relative to the normalized baseUrl's /v1/ sub-path
        if (options.path.startsWith('/')) {
          options.path = options.path.substring(1);
        }

        try {
          // Always try to attach token if we have one in secure storage
          // (even if useCookieAuth is true, as some environments might use both
          // or a mix during transition, and mobile NEVER uses cookies effectively)
          final token = await secureStorage.read(key: 'access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {}
        handler.next(options);
      },
      onError: (e, handler) async {
        // A failing refresh call must never re-enter the refresh logic.
        if (e.requestOptions.extra['isRefresh'] == true) {
          return handler.next(e);
        }
        if (e.response?.statusCode != 401) {
          return handler.next(e);
        }

        // Prevent infinite loops: a request that already came back from a
        // refresh-and-retry is not retried again.
        final original = e.requestOptions;
        if (original.extra['retried'] == true) {
          return handler.next(e);
        }

        bool refreshed;
        try {
          refreshed = await refreshSession();
        } catch (_) {
          // Couldn't reach /auth/refresh. The session may well still be valid,
          // so fail just this request rather than signing the user out for
          // what is probably a dropped connection.
          return handler.next(e);
        }

        if (!refreshed) {
          // The server rejected the refresh token: this session is really over.
          final storage = await LocalStorageService.getInstance();
          await storage.clearUserData();
          await secureStorage.deleteAll();
          return handler.next(e);
        }

        original.extra['retried'] = true;
        final token = await secureStorage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          original.headers['Authorization'] = 'Bearer $token';
        }
        try {
          final retryRes = await dio.fetch(original);
          return handler.resolve(retryRes);
        } catch (_) {
          return handler.next(e);
        }
      },
    ),
  );

  // Add logging interceptor in debug mode
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  return dio;
});
