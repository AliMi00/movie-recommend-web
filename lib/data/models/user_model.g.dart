// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  username: json['username'] as String?,
  fullName: json['full_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  preferredGenres:
      (json['preferred_genres'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isFirstTimeUser: json['is_first_time_user'] as bool? ?? false,
  minRating: (json['min_rating'] as num?)?.toDouble() ?? 7.0,
  isDarkTheme: json['is_dark_theme'] as bool? ?? true,
  emailVerified: json['email_verified'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  lastActiveAt: json['last_active_at'] == null
      ? null
      : DateTime.parse(json['last_active_at'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
      'preferred_genres': instance.preferredGenres,
      'is_first_time_user': instance.isFirstTimeUser,
      'min_rating': instance.minRating,
      'is_dark_theme': instance.isDarkTheme,
      'email_verified': instance.emailVerified,
      'created_at': instance.createdAt?.toIso8601String(),
      'last_active_at': instance.lastActiveAt?.toIso8601String(),
    };

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
  Map<String, dynamic> json,
) => _$UserPreferencesImpl(
  preferredGenres:
      (json['preferred_genres'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  minRating: (json['min_rating'] as num?)?.toDouble() ?? 7.0,
  isDarkTheme: json['is_dark_theme'] as bool? ?? true,
  enableNotifications: json['enable_notifications'] as bool? ?? true,
  enableAutoplay: json['enable_autoplay'] as bool? ?? true,
  language: json['language'] as String? ?? 'en',
);

Map<String, dynamic> _$$UserPreferencesImplToJson(
  _$UserPreferencesImpl instance,
) => <String, dynamic>{
  'preferred_genres': instance.preferredGenres,
  'min_rating': instance.minRating,
  'is_dark_theme': instance.isDarkTheme,
  'enable_notifications': instance.enableNotifications,
  'enable_autoplay': instance.enableAutoplay,
  'language': instance.language,
};

_$UserStateImpl _$$UserStateImplFromJson(Map<String, dynamic> json) =>
    _$UserStateImpl(
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      isAuthenticated: json['is_authenticated'] as bool? ?? false,
      preferredGenres:
          (json['preferred_genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferences: json['preferences'] == null
          ? null
          : UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>,
            ),
      isLoading: json['is_loading'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$UserStateImplToJson(_$UserStateImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'is_authenticated': instance.isAuthenticated,
      'preferred_genres': instance.preferredGenres,
      'preferences': instance.preferences,
      'is_loading': instance.isLoading,
      'error': instance.error,
    };
