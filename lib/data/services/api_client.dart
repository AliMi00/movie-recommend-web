import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'http_client_adapter_io.dart'
  if (dart.library.html) 'http_client_adapter_web.dart';
import 'local_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  
  // Ensure baseUrl always ends with a trailing slash for correct relative resolution
  String normalizedBaseUrl = config.baseUrl;
  if (!normalizedBaseUrl.endsWith('/')) {
    normalizedBaseUrl = '$normalizedBaseUrl/';
  }
  
  final dio = Dio(BaseOptions(
    baseUrl: normalizedBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // On web with cookie-based auth, ensure credentials are sent with requests
  if (kIsWeb && config.useCookieAuth) {
    final adapter = createWebHttpClientAdapter(withCredentials: true);
    if (adapter != null) dio.httpClientAdapter = adapter;
  }

  // Auth interceptor: attach bearer if present; refresh on 401 if applicable
  dio.interceptors.add(InterceptorsWrapper(
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
      // Attempt refresh once on 401
      if (e.response?.statusCode == 401) {
        try {
          // Prevent infinite loops or multiple refresh attempts
          final original = e.requestOptions;
          if (original.extra['retried'] == true) {
            return handler.next(e);
          }
          
          final refreshDio = Dio(BaseOptions(baseUrl: normalizedBaseUrl));
          if (kIsWeb && config.useCookieAuth) {
            final adapter = createWebHttpClientAdapter(withCredentials: true);
            if (adapter != null) refreshDio.httpClientAdapter = adapter;
          }
          
          Response refreshRes;
          // Mobile/App typically uses Bearer tokens, Web typically uses Cookies
          // If we have a refresh token in secure storage, use it regardless of useCookieAuth
          final rt = await secureStorage.read(key: 'refresh_token');
          
          if (rt != null && rt.isNotEmpty) {
            // Priority: refresh_token from storage
            refreshRes = await refreshDio.post('auth/refresh', data: {'refresh_token': rt, 'refreshToken': rt});
          } else if (config.useCookieAuth) {
            // Fallback: Cookie-based refresh (web)
            refreshRes = await refreshDio.post('auth/refresh');
          } else {
            return handler.next(e);
          }

          if (refreshRes.statusCode == 200) {
            final data = refreshRes.data as Map<String, dynamic>;
            final newAccess = data['accessToken'] as String?;
            final newRefresh = data['refreshToken'] as String?;
            
            if (newAccess != null) {
              await secureStorage.write(key: 'access_token', value: newAccess);
              original.headers['Authorization'] = 'Bearer $newAccess';
            }
            if (newRefresh != null) {
              await secureStorage.write(key: 'refresh_token', value: newRefresh);
            }

            // Retry original request
            original.extra['retried'] = true;
            
            final retryRes = await dio.fetch(original);
            return handler.resolve(retryRes);
          }
        } catch (_) {
          // Refresh failed, clear session
          final storage = await LocalStorageService.getInstance();
          await storage.clearUserData();
          await secureStorage.deleteAll();
        }
      }
      handler.next(e);
    },
  ));

  // Add logging interceptor in debug mode
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ));
  }

  return dio;
});
