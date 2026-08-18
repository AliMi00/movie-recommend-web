// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String? get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_genres')
  List<String> get preferredGenres => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_first_time_user')
  bool get isFirstTimeUser => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_rating')
  double get minRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_dark_theme')
  bool get isDarkTheme => throw _privateConstructorUsedError; // Defaults true (not false) so a User object cached locally before this
  // field existed — which will be missing the key entirely — doesn't
  // suddenly show every existing user an "unverified" nag on next launch.
  // The real value overwrites this on the next successful profile fetch.
  @JsonKey(name: 'email_verified')
  bool get emailVerified => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_active_at')
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String id,
    String email,
    String? username,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'preferred_genres') List<String> preferredGenres,
    @JsonKey(name: 'is_first_time_user') bool isFirstTimeUser,
    @JsonKey(name: 'min_rating') double minRating,
    @JsonKey(name: 'is_dark_theme') bool isDarkTheme,
    @JsonKey(name: 'email_verified') bool emailVerified,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'last_active_at') DateTime? lastActiveAt,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = freezed,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? preferredGenres = null,
    Object? isFirstTimeUser = null,
    Object? minRating = null,
    Object? isDarkTheme = null,
    Object? emailVerified = null,
    Object? createdAt = freezed,
    Object? lastActiveAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            fullName: freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            preferredGenres: null == preferredGenres
                ? _value.preferredGenres
                : preferredGenres // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isFirstTimeUser: null == isFirstTimeUser
                ? _value.isFirstTimeUser
                : isFirstTimeUser // ignore: cast_nullable_to_non_nullable
                      as bool,
            minRating: null == minRating
                ? _value.minRating
                : minRating // ignore: cast_nullable_to_non_nullable
                      as double,
            isDarkTheme: null == isDarkTheme
                ? _value.isDarkTheme
                : isDarkTheme // ignore: cast_nullable_to_non_nullable
                      as bool,
            emailVerified: null == emailVerified
                ? _value.emailVerified
                : emailVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastActiveAt: freezed == lastActiveAt
                ? _value.lastActiveAt
                : lastActiveAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String? username,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'preferred_genres') List<String> preferredGenres,
    @JsonKey(name: 'is_first_time_user') bool isFirstTimeUser,
    @JsonKey(name: 'min_rating') double minRating,
    @JsonKey(name: 'is_dark_theme') bool isDarkTheme,
    @JsonKey(name: 'email_verified') bool emailVerified,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'last_active_at') DateTime? lastActiveAt,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = freezed,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? preferredGenres = null,
    Object? isFirstTimeUser = null,
    Object? minRating = null,
    Object? isDarkTheme = null,
    Object? emailVerified = null,
    Object? createdAt = freezed,
    Object? lastActiveAt = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        preferredGenres: null == preferredGenres
            ? _value._preferredGenres
            : preferredGenres // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isFirstTimeUser: null == isFirstTimeUser
            ? _value.isFirstTimeUser
            : isFirstTimeUser // ignore: cast_nullable_to_non_nullable
                  as bool,
        minRating: null == minRating
            ? _value.minRating
            : minRating // ignore: cast_nullable_to_non_nullable
                  as double,
        isDarkTheme: null == isDarkTheme
            ? _value.isDarkTheme
            : isDarkTheme // ignore: cast_nullable_to_non_nullable
                  as bool,
        emailVerified: null == emailVerified
            ? _value.emailVerified
            : emailVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastActiveAt: freezed == lastActiveAt
            ? _value.lastActiveAt
            : lastActiveAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    required this.id,
    required this.email,
    this.username,
    @JsonKey(name: 'full_name') this.fullName,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
    @JsonKey(name: 'preferred_genres')
    final List<String> preferredGenres = const [],
    @JsonKey(name: 'is_first_time_user') this.isFirstTimeUser = false,
    @JsonKey(name: 'min_rating') this.minRating = 7.0,
    @JsonKey(name: 'is_dark_theme') this.isDarkTheme = true,
    @JsonKey(name: 'email_verified') this.emailVerified = true,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'last_active_at') this.lastActiveAt,
  }) : _preferredGenres = preferredGenres;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? username;
  @override
  @JsonKey(name: 'full_name')
  final String? fullName;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final List<String> _preferredGenres;
  @override
  @JsonKey(name: 'preferred_genres')
  List<String> get preferredGenres {
    if (_preferredGenres is EqualUnmodifiableListView) return _preferredGenres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredGenres);
  }

  @override
  @JsonKey(name: 'is_first_time_user')
  final bool isFirstTimeUser;
  @override
  @JsonKey(name: 'min_rating')
  final double minRating;
  @override
  @JsonKey(name: 'is_dark_theme')
  final bool isDarkTheme;
  // Defaults true (not false) so a User object cached locally before this
  // field existed — which will be missing the key entirely — doesn't
  // suddenly show every existing user an "unverified" nag on next launch.
  // The real value overwrites this on the next successful profile fetch.
  @override
  @JsonKey(name: 'email_verified')
  final bool emailVerified;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'last_active_at')
  final DateTime? lastActiveAt;

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, fullName: $fullName, avatarUrl: $avatarUrl, preferredGenres: $preferredGenres, isFirstTimeUser: $isFirstTimeUser, minRating: $minRating, isDarkTheme: $isDarkTheme, emailVerified: $emailVerified, createdAt: $createdAt, lastActiveAt: $lastActiveAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            const DeepCollectionEquality().equals(
              other._preferredGenres,
              _preferredGenres,
            ) &&
            (identical(other.isFirstTimeUser, isFirstTimeUser) ||
                other.isFirstTimeUser == isFirstTimeUser) &&
            (identical(other.minRating, minRating) ||
                other.minRating == minRating) &&
            (identical(other.isDarkTheme, isDarkTheme) ||
                other.isDarkTheme == isDarkTheme) &&
            (identical(other.emailVerified, emailVerified) ||
                other.emailVerified == emailVerified) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    username,
    fullName,
    avatarUrl,
    const DeepCollectionEquality().hash(_preferredGenres),
    isFirstTimeUser,
    minRating,
    isDarkTheme,
    emailVerified,
    createdAt,
    lastActiveAt,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    required final String id,
    required final String email,
    final String? username,
    @JsonKey(name: 'full_name') final String? fullName,
    @JsonKey(name: 'avatar_url') final String? avatarUrl,
    @JsonKey(name: 'preferred_genres') final List<String> preferredGenres,
    @JsonKey(name: 'is_first_time_user') final bool isFirstTimeUser,
    @JsonKey(name: 'min_rating') final double minRating,
    @JsonKey(name: 'is_dark_theme') final bool isDarkTheme,
    @JsonKey(name: 'email_verified') final bool emailVerified,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'last_active_at') final DateTime? lastActiveAt,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get username;
  @override
  @JsonKey(name: 'full_name')
  String? get fullName;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  @JsonKey(name: 'preferred_genres')
  List<String> get preferredGenres;
  @override
  @JsonKey(name: 'is_first_time_user')
  bool get isFirstTimeUser;
  @override
  @JsonKey(name: 'min_rating')
  double get minRating;
  @override
  @JsonKey(name: 'is_dark_theme')
  bool get isDarkTheme;
  @override // Defaults true (not false) so a User object cached locally before this
  // field existed — which will be missing the key entirely — doesn't
  // suddenly show every existing user an "unverified" nag on next launch.
  // The real value overwrites this on the next successful profile fetch.
  @JsonKey(name: 'email_verified')
  bool get emailVerified;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'last_active_at')
  DateTime? get lastActiveAt;
  @override
  @JsonKey(ignore: true)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  @JsonKey(name: 'preferred_genres')
  List<String> get preferredGenres => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_rating')
  double get minRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_dark_theme')
  bool get isDarkTheme => throw _privateConstructorUsedError;
  @JsonKey(name: 'enable_notifications')
  bool get enableNotifications => throw _privateConstructorUsedError;
  @JsonKey(name: 'enable_autoplay')
  bool get enableAutoplay => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
    UserPreferences value,
    $Res Function(UserPreferences) then,
  ) = _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call({
    @JsonKey(name: 'preferred_genres') List<String> preferredGenres,
    @JsonKey(name: 'min_rating') double minRating,
    @JsonKey(name: 'is_dark_theme') bool isDarkTheme,
    @JsonKey(name: 'enable_notifications') bool enableNotifications,
    @JsonKey(name: 'enable_autoplay') bool enableAutoplay,
    String language,
  });
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preferredGenres = null,
    Object? minRating = null,
    Object? isDarkTheme = null,
    Object? enableNotifications = null,
    Object? enableAutoplay = null,
    Object? language = null,
  }) {
    return _then(
      _value.copyWith(
            preferredGenres: null == preferredGenres
                ? _value.preferredGenres
                : preferredGenres // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            minRating: null == minRating
                ? _value.minRating
                : minRating // ignore: cast_nullable_to_non_nullable
                      as double,
            isDarkTheme: null == isDarkTheme
                ? _value.isDarkTheme
                : isDarkTheme // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableNotifications: null == enableNotifications
                ? _value.enableNotifications
                : enableNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableAutoplay: null == enableAutoplay
                ? _value.enableAutoplay
                : enableAutoplay // ignore: cast_nullable_to_non_nullable
                      as bool,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(
    _$UserPreferencesImpl value,
    $Res Function(_$UserPreferencesImpl) then,
  ) = __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'preferred_genres') List<String> preferredGenres,
    @JsonKey(name: 'min_rating') double minRating,
    @JsonKey(name: 'is_dark_theme') bool isDarkTheme,
    @JsonKey(name: 'enable_notifications') bool enableNotifications,
    @JsonKey(name: 'enable_autoplay') bool enableAutoplay,
    String language,
  });
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
    _$UserPreferencesImpl _value,
    $Res Function(_$UserPreferencesImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preferredGenres = null,
    Object? minRating = null,
    Object? isDarkTheme = null,
    Object? enableNotifications = null,
    Object? enableAutoplay = null,
    Object? language = null,
  }) {
    return _then(
      _$UserPreferencesImpl(
        preferredGenres: null == preferredGenres
            ? _value._preferredGenres
            : preferredGenres // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        minRating: null == minRating
            ? _value.minRating
            : minRating // ignore: cast_nullable_to_non_nullable
                  as double,
        isDarkTheme: null == isDarkTheme
            ? _value.isDarkTheme
            : isDarkTheme // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableNotifications: null == enableNotifications
            ? _value.enableNotifications
            : enableNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableAutoplay: null == enableAutoplay
            ? _value.enableAutoplay
            : enableAutoplay // ignore: cast_nullable_to_non_nullable
                  as bool,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl({
    @JsonKey(name: 'preferred_genres')
    final List<String> preferredGenres = const [],
    @JsonKey(name: 'min_rating') this.minRating = 7.0,
    @JsonKey(name: 'is_dark_theme') this.isDarkTheme = true,
    @JsonKey(name: 'enable_notifications') this.enableNotifications = true,
    @JsonKey(name: 'enable_autoplay') this.enableAutoplay = true,
    this.language = 'en',
  }) : _preferredGenres = preferredGenres;

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  final List<String> _preferredGenres;
  @override
  @JsonKey(name: 'preferred_genres')
  List<String> get preferredGenres {
    if (_preferredGenres is EqualUnmodifiableListView) return _preferredGenres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredGenres);
  }

  @override
  @JsonKey(name: 'min_rating')
  final double minRating;
  @override
  @JsonKey(name: 'is_dark_theme')
  final bool isDarkTheme;
  @override
  @JsonKey(name: 'enable_notifications')
  final bool enableNotifications;
  @override
  @JsonKey(name: 'enable_autoplay')
  final bool enableAutoplay;
  @override
  @JsonKey()
  final String language;

  @override
  String toString() {
    return 'UserPreferences(preferredGenres: $preferredGenres, minRating: $minRating, isDarkTheme: $isDarkTheme, enableNotifications: $enableNotifications, enableAutoplay: $enableAutoplay, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            const DeepCollectionEquality().equals(
              other._preferredGenres,
              _preferredGenres,
            ) &&
            (identical(other.minRating, minRating) ||
                other.minRating == minRating) &&
            (identical(other.isDarkTheme, isDarkTheme) ||
                other.isDarkTheme == isDarkTheme) &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            (identical(other.enableAutoplay, enableAutoplay) ||
                other.enableAutoplay == enableAutoplay) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_preferredGenres),
    minRating,
    isDarkTheme,
    enableNotifications,
    enableAutoplay,
    language,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(this);
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences({
    @JsonKey(name: 'preferred_genres') final List<String> preferredGenres,
    @JsonKey(name: 'min_rating') final double minRating,
    @JsonKey(name: 'is_dark_theme') final bool isDarkTheme,
    @JsonKey(name: 'enable_notifications') final bool enableNotifications,
    @JsonKey(name: 'enable_autoplay') final bool enableAutoplay,
    final String language,
  }) = _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  @JsonKey(name: 'preferred_genres')
  List<String> get preferredGenres;
  @override
  @JsonKey(name: 'min_rating')
  double get minRating;
  @override
  @JsonKey(name: 'is_dark_theme')
  bool get isDarkTheme;
  @override
  @JsonKey(name: 'enable_notifications')
  bool get enableNotifications;
  @override
  @JsonKey(name: 'enable_autoplay')
  bool get enableAutoplay;
  @override
  String get language;
  @override
  @JsonKey(ignore: true)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserState _$UserStateFromJson(Map<String, dynamic> json) {
  return _UserState.fromJson(json);
}

/// @nodoc
mixin _$UserState {
  User? get user => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_authenticated')
  bool get isAuthenticated => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_genres')
  List<String> get preferredGenres => throw _privateConstructorUsedError;
  UserPreferences? get preferences => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_loading')
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserStateCopyWith<UserState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStateCopyWith<$Res> {
  factory $UserStateCopyWith(UserState value, $Res Function(UserState) then) =
      _$UserStateCopyWithImpl<$Res, UserState>;
  @useResult
  $Res call({
    User? user,
    @JsonKey(name: 'is_authenticated') bool isAuthenticated,
    @JsonKey(name: 'preferred_genres') List<String> preferredGenres,
    UserPreferences? preferences,
    @JsonKey(name: 'is_loading') bool isLoading,
    String? error,
  });

  $UserCopyWith<$Res>? get user;
  $UserPreferencesCopyWith<$Res>? get preferences;
}

/// @nodoc
class _$UserStateCopyWithImpl<$Res, $Val extends UserState>
    implements $UserStateCopyWith<$Res> {
  _$UserStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? isAuthenticated = null,
    Object? preferredGenres = null,
    Object? preferences = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as User?,
            isAuthenticated: null == isAuthenticated
                ? _value.isAuthenticated
                : isAuthenticated // ignore: cast_nullable_to_non_nullable
                      as bool,
            preferredGenres: null == preferredGenres
                ? _value.preferredGenres
                : preferredGenres // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            preferences: freezed == preferences
                ? _value.preferences
                : preferences // ignore: cast_nullable_to_non_nullable
                      as UserPreferences?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesCopyWith<$Res>? get preferences {
    if (_value.preferences == null) {
      return null;
    }

    return $UserPreferencesCopyWith<$Res>(_value.preferences!, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserStateImplCopyWith<$Res>
    implements $UserStateCopyWith<$Res> {
  factory _$$UserStateImplCopyWith(
    _$UserStateImpl value,
    $Res Function(_$UserStateImpl) then,
  ) = __$$UserStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    User? user,
    @JsonKey(name: 'is_authenticated') bool isAuthenticated,
    @JsonKey(name: 'preferred_genres') List<String> preferredGenres,
    UserPreferences? preferences,
    @JsonKey(name: 'is_loading') bool isLoading,
    String? error,
  });

  @override
  $UserCopyWith<$Res>? get user;
  @override
  $UserPreferencesCopyWith<$Res>? get preferences;
}

/// @nodoc
class __$$UserStateImplCopyWithImpl<$Res>
    extends _$UserStateCopyWithImpl<$Res, _$UserStateImpl>
    implements _$$UserStateImplCopyWith<$Res> {
  __$$UserStateImplCopyWithImpl(
    _$UserStateImpl _value,
    $Res Function(_$UserStateImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? isAuthenticated = null,
    Object? preferredGenres = null,
    Object? preferences = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$UserStateImpl(
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User?,
        isAuthenticated: null == isAuthenticated
            ? _value.isAuthenticated
            : isAuthenticated // ignore: cast_nullable_to_non_nullable
                  as bool,
        preferredGenres: null == preferredGenres
            ? _value._preferredGenres
            : preferredGenres // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        preferences: freezed == preferences
            ? _value.preferences
            : preferences // ignore: cast_nullable_to_non_nullable
                  as UserPreferences?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStateImpl implements _UserState {
  const _$UserStateImpl({
    this.user,
    @JsonKey(name: 'is_authenticated') this.isAuthenticated = false,
    @JsonKey(name: 'preferred_genres')
    final List<String> preferredGenres = const [],
    this.preferences,
    @JsonKey(name: 'is_loading') this.isLoading = false,
    this.error,
  }) : _preferredGenres = preferredGenres;

  factory _$UserStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStateImplFromJson(json);

  @override
  final User? user;
  @override
  @JsonKey(name: 'is_authenticated')
  final bool isAuthenticated;
  final List<String> _preferredGenres;
  @override
  @JsonKey(name: 'preferred_genres')
  List<String> get preferredGenres {
    if (_preferredGenres is EqualUnmodifiableListView) return _preferredGenres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredGenres);
  }

  @override
  final UserPreferences? preferences;
  @override
  @JsonKey(name: 'is_loading')
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'UserState(user: $user, isAuthenticated: $isAuthenticated, preferredGenres: $preferredGenres, preferences: $preferences, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStateImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.isAuthenticated, isAuthenticated) ||
                other.isAuthenticated == isAuthenticated) &&
            const DeepCollectionEquality().equals(
              other._preferredGenres,
              _preferredGenres,
            ) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    user,
    isAuthenticated,
    const DeepCollectionEquality().hash(_preferredGenres),
    preferences,
    isLoading,
    error,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStateImplCopyWith<_$UserStateImpl> get copyWith =>
      __$$UserStateImplCopyWithImpl<_$UserStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStateImplToJson(this);
  }
}

abstract class _UserState implements UserState {
  const factory _UserState({
    final User? user,
    @JsonKey(name: 'is_authenticated') final bool isAuthenticated,
    @JsonKey(name: 'preferred_genres') final List<String> preferredGenres,
    final UserPreferences? preferences,
    @JsonKey(name: 'is_loading') final bool isLoading,
    final String? error,
  }) = _$UserStateImpl;

  factory _UserState.fromJson(Map<String, dynamic> json) =
      _$UserStateImpl.fromJson;

  @override
  User? get user;
  @override
  @JsonKey(name: 'is_authenticated')
  bool get isAuthenticated;
  @override
  @JsonKey(name: 'preferred_genres')
  List<String> get preferredGenres;
  @override
  UserPreferences? get preferences;
  @override
  @JsonKey(name: 'is_loading')
  bool get isLoading;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$UserStateImplCopyWith<_$UserStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
