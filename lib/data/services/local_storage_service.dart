import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../../core/constants/app_constants.dart';

/// Service for managing local storage of user data and preferences
class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Save user authentication state
  Future<void> saveAuthUser(User user) async {
    await _preferences!.setString(
      AppConstants.userDataKey,
      json.encode(user.toJson()),
    );
    await _preferences!.setBool('is_authenticated', true);
  }

  /// Get saved user data
  Future<User?> getSavedUser() async {
    final userJson = _preferences!.getString(AppConstants.userDataKey);
    if (userJson == null) return null;

    try {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      // Clear corrupted data
      await clearUserData();
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _preferences!.getBool('is_authenticated') ?? false;
  }

  /// Save user preferences
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _preferences!.setString(
      AppConstants.userPreferencesKey,
      json.encode(preferences.toJson()),
    );
  }

  /// Get user preferences
  Future<UserPreferences?> getUserPreferences() async {
    final preferencesJson = _preferences!.getString(
      AppConstants.userPreferencesKey,
    );
    if (preferencesJson == null) return null;

    try {
      final preferencesMap =
          json.decode(preferencesJson) as Map<String, dynamic>;
      return UserPreferences.fromJson(preferencesMap);
    } catch (e) {
      return null;
    }
  }

  /// Save theme preference
  Future<void> saveThemeMode(bool isDarkTheme) async {
    await _preferences!.setBool(AppConstants.themeKey, isDarkTheme);
  }

  /// Get theme preference
  Future<bool> getThemeMode() async {
    return _preferences!.getBool(AppConstants.themeKey) ??
        true; // Default to dark
  }

  /// Check if user is first time user
  Future<bool> isFirstTimeUser() async {
    return _preferences!.getBool(AppConstants.firstTimeUserKey) ?? true;
  }

  /// Mark user as not first time
  Future<void> setFirstTimeUserCompleted() async {
    await _preferences!.setBool(AppConstants.firstTimeUserKey, false);
  }

  /// Whether the pre-auth intro carousel has already been shown on this device.
  Future<bool> hasSeenOnboardingIntro() async {
    return _preferences!.getBool(AppConstants.onboardingIntroSeenKey) ?? false;
  }

  /// Mark the intro carousel as seen so it isn't shown again on next launch.
  Future<void> setOnboardingIntroSeen() async {
    await _preferences!.setBool(AppConstants.onboardingIntroSeenKey, true);
  }

  /// Save liked movies list
  Future<void> saveLikedMovies(List<String> movieIds) async {
    await _preferences!.setStringList(AppConstants.likedMoviesKey, movieIds);
  }

  /// Get liked movies list
  Future<List<String>> getLikedMovies() async {
    return _preferences!.getStringList(AppConstants.likedMoviesKey) ?? [];
  }

  /// Save disliked movies list
  Future<void> saveDislikedMovies(List<String> movieIds) async {
    await _preferences!.setStringList(AppConstants.dislikedMoviesKey, movieIds);
  }

  /// Get disliked movies list
  Future<List<String>> getDislikedMovies() async {
    return _preferences!.getStringList(AppConstants.dislikedMoviesKey) ?? [];
  }

  /// Save watch history
  Future<void> saveWatchHistory(List<String> movieIds) async {
    await _preferences!.setStringList(AppConstants.watchHistoryKey, movieIds);
  }

  /// Get watch history
  Future<List<String>> getWatchHistory() async {
    return _preferences!.getStringList(AppConstants.watchHistoryKey) ?? [];
  }

  /// Save watchlist
  Future<void> saveWatchlist(List<String> movieIds) async {
    await _preferences!.setStringList('watchlist_movies', movieIds);
  }

  /// Get watchlist
  Future<List<String>> getWatchlist() async {
    return _preferences!.getStringList('watchlist_movies') ?? [];
  }

  /// Clear all user data (logout)
  Future<void> clearUserData() async {
    await _preferences!.remove(AppConstants.userDataKey);
    await _preferences!.remove('is_authenticated');
    await _preferences!.remove(AppConstants.userPreferencesKey);
    await _preferences!.remove(AppConstants.likedMoviesKey);
    await _preferences!.remove(AppConstants.dislikedMoviesKey);
    await _preferences!.remove(AppConstants.watchHistoryKey);
    // Note: We keep theme preference and first-time user flag
  }

  /// Clear all app data (reset app)
  Future<void> clearAllData() async {
    await _preferences!.clear();
  }

  // ==== Auth tokens ====
  Future<void> saveAccessToken(String token) async {
    await _preferences!.setString('access_token', token);
  }

  String? getAccessToken() {
    return _preferences!.getString('access_token');
  }

  Future<void> saveRefreshToken(String token) async {
    await _preferences!.setString('refresh_token', token);
  }

  String? getRefreshToken() {
    return _preferences!.getString('refresh_token');
  }

  Future<void> clearTokens() async {
    await _preferences!.remove('access_token');
    await _preferences!.remove('refresh_token');
  }

  /// Save generic key-value pair
  Future<void> saveString(String key, String value) async {
    await _preferences!.setString(key, value);
  }

  /// Get generic string value
  String? getString(String key) {
    return _preferences!.getString(key);
  }

  /// Save generic boolean
  Future<void> saveBool(String key, bool value) async {
    await _preferences!.setBool(key, value);
  }

  /// Get generic boolean value
  bool getBool(String key, {bool defaultValue = false}) {
    return _preferences!.getBool(key) ?? defaultValue;
  }

  /// Save generic integer
  Future<void> saveInt(String key, int value) async {
    await _preferences!.setInt(key, value);
  }

  /// Get generic integer value
  int getInt(String key, {int defaultValue = 0}) {
    return _preferences!.getInt(key) ?? defaultValue;
  }

  /// Save generic double
  Future<void> saveDouble(String key, double value) async {
    await _preferences!.setDouble(key, value);
  }

  /// Get generic double value
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _preferences!.getDouble(key) ?? defaultValue;
  }

  // Recent searches (serialized JSON list)
  Future<void> saveRecentSearches(List<String> queries) async {
    await _preferences!.setString(
      'recent_searches',
      json.encode(queries.take(10).toList()),
    );
  }

  List<String> getRecentSearches() {
    final raw = _preferences!.getString('recent_searches');
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }
}
