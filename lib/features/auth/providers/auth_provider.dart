import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../core/config/app_config.dart';
import '../../../data/services/api_client.dart';
import '../../../core/analytics/analytics_service.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiAuthRepository(dio, config, secureStorage);
});

/// Authentication state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Authentication state class
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final bool isFirstTimeUser;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.isFirstTimeUser = true,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool? isFirstTimeUser,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFirstTimeUser: isFirstTimeUser ?? this.isFirstTimeUser,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.user == user &&
        other.isAuthenticated == isAuthenticated &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.isFirstTimeUser == isFirstTimeUser;
  }

  @override
  int get hashCode {
    return Object.hash(
      user,
      isAuthenticated,
      isLoading,
      error,
      isFirstTimeUser,
    );
  }
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// Check current authentication status
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _repository.getCurrentUser();
      final isAuthenticated = await _repository.isLoggedIn();
      
      state = state.copyWith(
        user: user,
        isAuthenticated: isAuthenticated,
        isFirstTimeUser: user?.isFirstTimeUser ?? true,
        isLoading: false,
      );
      
      if (user != null) {
        // Identify by user ID only — the privacy policy promises PostHog
        // never receives your email, so don't send it as a property here.
        AnalyticsService.identifyUser(user.id);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _repository.login(email, password);
      
      if (result.success && result.user != null) {
        final user = result.user!;
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isFirstTimeUser: user.isFirstTimeUser,
          isLoading: false,
        );
        
        // Identify by user ID only — the privacy policy promises PostHog
        // never receives your email, so don't send it as a property here.
        AnalyticsService.identifyUser(user.id);
        AnalyticsService.trackEvent('login_success', properties: {
          'method': 'email',
          'is_first_time': user.isFirstTimeUser,
        });
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error ?? 'Login failed',
        );
        
        AnalyticsService.trackEvent('login_failed', properties: {
          'reason': result.error ?? 'Unknown error',
        });
        
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      
      AnalyticsService.trackEvent('login_failed', properties: {
        'reason': e.toString(),
      });
      
      return false;
    }
  }

  /// Register user
  Future<bool> register(String email, String password, String username) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _repository.register(email, password, username);
      
      if (result.success && result.user != null) {
        final user = result.user!;
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isFirstTimeUser: true, // New users are always first time
          isLoading: false,
        );
        
        // Identify by user ID only — the privacy policy promises PostHog
        // never receives your email, so don't send it as a property here.
        AnalyticsService.identifyUser(user.id);
        AnalyticsService.trackEvent('registration_success', properties: {
          'username': user.username,
        });
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error ?? 'Registration failed',
        );
        
        AnalyticsService.trackEvent('registration_failed', properties: {
          'reason': result.error ?? 'Unknown error',
        });
        
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      
      AnalyticsService.trackEvent('registration_failed', properties: {
        'reason': e.toString(),
      });
      
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.logout();
      state = const AuthState(); // Reset to initial state
      
      AnalyticsService.trackEvent('logout');
      AnalyticsService.reset();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Permanently delete the current account and all server-side data
  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _repository.deleteAccount();
      if (success) {
        state = const AuthState();
        AnalyticsService.trackEvent('account_deleted');
        AnalyticsService.reset();
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete account. Please check your connection and try again.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Requests a password reset email. Doesn't touch [AuthState] — there is
  /// no session to change yet, the user isn't logged in on this screen —
  /// and deliberately doesn't distinguish "no such account" from "sent":
  /// the backend responds identically either way, so the UI must too.
  Future<bool> forgotPassword(String email) => _repository.forgotPassword(email);

  /// Requests a fresh verification email for the current account.
  Future<bool> resendVerificationEmail(String email) =>
      _repository.resendVerificationEmail(email);

  /// Save user preferences (usually after onboarding)
  Future<bool> saveUserPreferences(UserPreferences preferences) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.saveUserPreferences(preferences);
      
      // Update user state to reflect completed onboarding
      if (state.user != null) {
        final updatedUser = state.user!.copyWith(
          preferredGenres: preferences.preferredGenres,
          minRating: preferences.minRating,
          isDarkTheme: preferences.isDarkTheme,
          isFirstTimeUser: false,
        );
        
        state = state.copyWith(
          user: updatedUser,
          isFirstTimeUser: false,
          isLoading: false,
        );
      }
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? username,
    String? avatarUrl,
  }) async {
    if (state.user == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // In a real app, this would make an API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedUser = state.user!.copyWith(
        fullName: fullName ?? state.user!.fullName,
        username: username ?? state.user!.username,
        avatarUrl: avatarUrl ?? state.user!.avatarUrl,
      );
      
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear any error messages
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Force refresh authentication state
  Future<void> refresh() async {
    await _checkAuthStatus();
  }
}

/// Provider for checking username availability
/// Provider for user preferences
final userPreferencesProvider = FutureProvider<UserPreferences?>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getUserPreferences();
});
