// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? username,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'preferred_genres') @Default([]) List<String> preferredGenres,
    @JsonKey(name: 'is_first_time_user') @Default(false) bool isFirstTimeUser,
    @JsonKey(name: 'min_rating') @Default(7.0) double minRating,
    @JsonKey(name: 'is_dark_theme') @Default(true) bool isDarkTheme,
    // Defaults true (not false) so a User object cached locally before this
    // field existed — which will be missing the key entirely — doesn't
    // suddenly show every existing user an "unverified" nag on next launch.
    // The real value overwrites this on the next successful profile fetch.
    @JsonKey(name: 'email_verified') @Default(true) bool emailVerified,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'last_active_at') DateTime? lastActiveAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @JsonKey(name: 'preferred_genres') @Default([]) List<String> preferredGenres,
    @JsonKey(name: 'min_rating') @Default(7.0) double minRating,
    @JsonKey(name: 'is_dark_theme') @Default(true) bool isDarkTheme,
    @JsonKey(name: 'enable_notifications') @Default(true) bool enableNotifications,
    @JsonKey(name: 'enable_autoplay') @Default(true) bool enableAutoplay,
    @Default('en') String language,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) => 
      _$UserPreferencesFromJson(json);
}

@freezed
class UserState with _$UserState {
  const factory UserState({
    User? user,
    @JsonKey(name: 'is_authenticated') @Default(false) bool isAuthenticated,
    @JsonKey(name: 'preferred_genres') @Default([]) List<String> preferredGenres,
    UserPreferences? preferences,
    @JsonKey(name: 'is_loading') @Default(false) bool isLoading,
    String? error,
  }) = _UserState;

  factory UserState.fromJson(Map<String, dynamic> json) => 
      _$UserStateFromJson(json);
}
