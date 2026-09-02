import '../../data/models/user_model.dart';
import '../services/local_storage_service.dart';
import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Result of an authentication operation
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult.success(this.user) : success = true, error = null;
  AuthResult.failure(this.error) : success = false, user = null;
}

/// Repository interface for authentication
abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register(String email, String password, String username);
  Future<void> logout();
  Future<bool> deleteAccount();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> saveUserPreferences(UserPreferences preferences);
  Future<UserPreferences?> getUserPreferences();
  Future<Map<String, dynamic>> getUserStats();

  /// Always succeeds from the caller's point of view — the backend responds
  /// identically whether or not the email is registered, so this can't be
  /// used to check who has an account. Returns false only on a genuine
  /// network/request failure, not a "no such email" case (there is no such
  /// case visible to the client).
  Future<bool> forgotPassword(String email);

  /// Same no-enumeration shape as [forgotPassword].
  Future<bool> resendVerificationEmail(String email);
}

// ... (MockAuthRepository unchanged except adding getUserStats)

/// API-based implementation of AuthRepository
class ApiAuthRepository implements AuthRepository {
  final Dio _dio;
  final AppConfig _config;
  final FlutterSecureStorage _secureStorage;

  ApiAuthRepository(this._dio, this._config, this._secureStorage);

  User _mapUser(Map<String, dynamic> u) {
    return User(
      id: (u['id'] ?? u['userId'] ?? 'me').toString(),
      email: (u['email'] ?? 'user@cinreco').toString(),
      username: u['username'] as String?,
      fullName: u['fullName'] as String? ?? u['full_name'] as String?,
      avatarUrl: u['avatarUrl'] as String? ?? u['avatar_url'] as String?,
      preferredGenres: List<String>.from(
        u['preferredGenres'] ?? u['preferred_genres'] ?? const [],
      ),
      isFirstTimeUser:
          (u['isFirstTimeUser'] as bool?) ??
          (u['is_first_time_user'] as bool?) ??
          false,
      minRating:
          (u['minRating'] as num?)?.toDouble() ??
          (u['min_rating'] as num?)?.toDouble() ??
          7.0,
      isDarkTheme:
          (u['isDarkTheme'] as bool?) ?? (u['is_dark_theme'] as bool?) ?? true,
      // Login's embedded user payload doesn't include this — only
      // GET /users/me does — so it stays at the model's safe default (true,
      // no false "unverified" nag) until the next profile fetch corrects it.
      emailVerified:
          (u['emailVerified'] as bool?) ??
          (u['email_verified'] as bool?) ??
          true,
      createdAt: u['createdAt'] != null
          ? DateTime.tryParse(u['createdAt'])
          : null,
      lastActiveAt: u['lastActiveAt'] != null
          ? DateTime.tryParse(u['lastActiveAt'])
          : null,
    );
  }

  Future<void> _persistAuth(
    User user, {
    String? access,
    String? refresh,
  }) async {
    final storage = await LocalStorageService.getInstance();
    await storage.saveAuthUser(user);
    if (!_config.useCookieAuth) {
      if (access != null && access.isNotEmpty) {
        await _secureStorage.write(key: 'access_token', value: access);
      }
      if (refresh != null && refresh.isNotEmpty) {
        await _secureStorage.write(key: 'refresh_token', value: refresh);
      }
    }
  }

  @override
  Future<AuthResult> login(String email, String password) async {
    try {
      final res = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = res.data as Map<String, dynamic>;
      final userMap = data['user'] as Map<String, dynamic>?;

      User user;
      if (userMap != null) {
        user = _mapUser(userMap);
      } else {
        // Fallback: fetch me
        try {
          final me = await _dio.get('/users/me');
          user = _mapUser(me.data as Map<String, dynamic>);
        } catch (_) {
          user = User(id: 'me', email: email, isFirstTimeUser: false);
        }
      }

      await _persistAuth(
        user,
        access: data['accessToken'] as String?,
        refresh: data['refreshToken'] as String?,
      );

      return AuthResult.success(user);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data, 'Login failed');
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  @override
  Future<AuthResult> register(
    String email,
    String password,
    String username,
  ) async {
    try {
      final res = await _dio.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'username': username},
      );

      final data = res.data as Map<String, dynamic>;
      final userMap = data['user'] as Map<String, dynamic>?;

      User user;
      if (userMap != null) {
        user = _mapUser(userMap);
      } else if (data['id'] != null || data['email'] != null) {
        user = _mapUser(data);
      } else {
        user = User(
          id: 'me',
          email: email,
          username: username,
          isFirstTimeUser: true,
        );
      }

      final access =
          data['accessToken'] as String? ?? data['access_token'] as String?;
      final refresh =
          data['refreshToken'] as String? ?? data['refresh_token'] as String?;

      if (access != null && access.isNotEmpty) {
        await _persistAuth(user, access: access, refresh: refresh);
        return AuthResult.success(user);
      } else {
        // Registration succeeded. Perform auto-login to obtain Bearer tokens.
        final loginRes = await login(email, password);
        if (loginRes.success && loginRes.user != null) {
          return AuthResult.success(
            loginRes.user!.copyWith(isFirstTimeUser: true),
          );
        }
        await _persistAuth(user);
        return AuthResult.success(user);
      }
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e.response?.data,
        'Registration failed',
      );
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  String _extractErrorMessage(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      if (data['detail'] is Map<String, dynamic>) {
        final err = data['detail']['error'];
        if (err is Map<String, dynamic> && err['message'] is String) {
          return err['message'] as String;
        }
      } else if (data['detail'] is String) {
        return data['detail'] as String;
      } else if (data['error'] is Map<String, dynamic> &&
          data['error']['message'] is String) {
        return data['error']['message'] as String;
      } else if (data['error'] is String) {
        return data['error'] as String;
      } else if (data['message'] is String) {
        return data['message'] as String;
      }
    }
    return fallback;
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    final storage = await LocalStorageService.getInstance();
    await _secureStorage.deleteAll();
    await storage.clearUserData();
  }

  // Local session data is only cleared on success, so a failed request
  // leaves the user still logged in rather than silently signing them out.
  @override
  Future<bool> deleteAccount() async {
    try {
      await _dio.delete('/users/me');
    } on DioException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
    final storage = await LocalStorageService.getInstance();
    await _secureStorage.deleteAll();
    await storage.clearUserData();
    return true;
  }

  @override
  Future<bool> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> resendVerificationEmail(String email) async {
    try {
      await _dio.post('/auth/resend-verification', data: {'email': email});
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final res = await _dio.get('/users/me');
      final user = _mapUser(res.data as Map<String, dynamic>);
      final storage = await LocalStorageService.getInstance();
      await storage.saveAuthUser(user);
      return user;
    } catch (_) {
      final storage = await LocalStorageService.getInstance();
      return storage.getSavedUser();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    if (_config.useCookieAuth) {
      final storage = await LocalStorageService.getInstance();
      return (await storage.getSavedUser()) != null;
    } else {
      final token = await _secureStorage.read(key: 'access_token');
      return token != null && token.isNotEmpty;
    }
  }

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      await _dio.put(
        '/users/me/preferences',
        data: {
          'preferredGenres': preferences.preferredGenres,
          'minRating': preferences.minRating,
          'language': preferences.language,
          'theme': preferences.isDarkTheme ? 'dark' : 'light',
        },
      );
    } catch (_) {}
    final storage = await LocalStorageService.getInstance();
    await storage.saveUserPreferences(preferences);
    await storage.setFirstTimeUserCompleted();
  }

  @override
  Future<UserPreferences?> getUserPreferences() async {
    try {
      final res = await _dio.get('/users/me/preferences');
      final d = res.data as Map<String, dynamic>;
      return UserPreferences(
        preferredGenres: List<String>.from(d['preferredGenres'] ?? const []),
        minRating: (d['minRating'] as num?)?.toDouble() ?? 7.0,
        isDarkTheme: (d['theme'] as String?) == 'dark',
        language: (d['language'] as String?) ?? 'en',
      );
    } catch (_) {
      final storage = await LocalStorageService.getInstance();
      return storage.getUserPreferences();
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final res = await _dio.get('/users/me/stats');
      return res.data as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

enum PasswordStrength { weak, medium, strong }

extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  double get value {
    switch (this) {
      case PasswordStrength.weak:
        return 0.3;
      case PasswordStrength.medium:
        return 0.6;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}
