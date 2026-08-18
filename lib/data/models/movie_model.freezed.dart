// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Movie _$MovieFromJson(Map<String, dynamic> json) {
  return _Movie.fromJson(json);
}

/// @nodoc
mixin _$Movie {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get overview => throw _privateConstructorUsedError;
  String? get posterUrl => throw _privateConstructorUsedError;
  String? get backdropUrl => throw _privateConstructorUsedError;
  List<String> get genres => throw _privateConstructorUsedError;
  String get releaseDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_average')
  double get voteAverage => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_count')
  int get voteCount => throw _privateConstructorUsedError;
  int get runtime => throw _privateConstructorUsedError;
  List<String> get cast => throw _privateConstructorUsedError;
  String get director => throw _privateConstructorUsedError;
  @JsonKey(name: 'trailer_key')
  String? get trailerKey => throw _privateConstructorUsedError;
  String? get reason =>
      throw _privateConstructorUsedError; // New field from Hybrid Hydra engine
  @JsonKey(name: 'similar_movies')
  List<int> get similarIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_liked')
  bool get isLiked => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_disliked')
  bool get isDisliked => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_super_liked')
  bool get isSuperLiked => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_watched')
  bool get isWatched => throw _privateConstructorUsedError;
  @JsonKey(name: 'liked_at')
  DateTime? get likedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'watched_at')
  DateTime? get watchedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MovieCopyWith<Movie> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieCopyWith<$Res> {
  factory $MovieCopyWith(Movie value, $Res Function(Movie) then) =
      _$MovieCopyWithImpl<$Res, Movie>;
  @useResult
  $Res call({
    int id,
    String title,
    String overview,
    String? posterUrl,
    String? backdropUrl,
    List<String> genres,
    String releaseDate,
    @JsonKey(name: 'vote_average') double voteAverage,
    @JsonKey(name: 'vote_count') int voteCount,
    int runtime,
    List<String> cast,
    String director,
    @JsonKey(name: 'trailer_key') String? trailerKey,
    String? reason,
    @JsonKey(name: 'similar_movies') List<int> similarIds,
    @JsonKey(name: 'is_liked') bool isLiked,
    @JsonKey(name: 'is_disliked') bool isDisliked,
    @JsonKey(name: 'is_super_liked') bool isSuperLiked,
    @JsonKey(name: 'is_watched') bool isWatched,
    @JsonKey(name: 'liked_at') DateTime? likedAt,
    @JsonKey(name: 'watched_at') DateTime? watchedAt,
  });
}

/// @nodoc
class _$MovieCopyWithImpl<$Res, $Val extends Movie>
    implements $MovieCopyWith<$Res> {
  _$MovieCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? overview = null,
    Object? posterUrl = freezed,
    Object? backdropUrl = freezed,
    Object? genres = null,
    Object? releaseDate = null,
    Object? voteAverage = null,
    Object? voteCount = null,
    Object? runtime = null,
    Object? cast = null,
    Object? director = null,
    Object? trailerKey = freezed,
    Object? reason = freezed,
    Object? similarIds = null,
    Object? isLiked = null,
    Object? isDisliked = null,
    Object? isSuperLiked = null,
    Object? isWatched = null,
    Object? likedAt = freezed,
    Object? watchedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            overview: null == overview
                ? _value.overview
                : overview // ignore: cast_nullable_to_non_nullable
                      as String,
            posterUrl: freezed == posterUrl
                ? _value.posterUrl
                : posterUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            backdropUrl: freezed == backdropUrl
                ? _value.backdropUrl
                : backdropUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            genres: null == genres
                ? _value.genres
                : genres // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            releaseDate: null == releaseDate
                ? _value.releaseDate
                : releaseDate // ignore: cast_nullable_to_non_nullable
                      as String,
            voteAverage: null == voteAverage
                ? _value.voteAverage
                : voteAverage // ignore: cast_nullable_to_non_nullable
                      as double,
            voteCount: null == voteCount
                ? _value.voteCount
                : voteCount // ignore: cast_nullable_to_non_nullable
                      as int,
            runtime: null == runtime
                ? _value.runtime
                : runtime // ignore: cast_nullable_to_non_nullable
                      as int,
            cast: null == cast
                ? _value.cast
                : cast // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            director: null == director
                ? _value.director
                : director // ignore: cast_nullable_to_non_nullable
                      as String,
            trailerKey: freezed == trailerKey
                ? _value.trailerKey
                : trailerKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            similarIds: null == similarIds
                ? _value.similarIds
                : similarIds // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            isLiked: null == isLiked
                ? _value.isLiked
                : isLiked // ignore: cast_nullable_to_non_nullable
                      as bool,
            isDisliked: null == isDisliked
                ? _value.isDisliked
                : isDisliked // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSuperLiked: null == isSuperLiked
                ? _value.isSuperLiked
                : isSuperLiked // ignore: cast_nullable_to_non_nullable
                      as bool,
            isWatched: null == isWatched
                ? _value.isWatched
                : isWatched // ignore: cast_nullable_to_non_nullable
                      as bool,
            likedAt: freezed == likedAt
                ? _value.likedAt
                : likedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            watchedAt: freezed == watchedAt
                ? _value.watchedAt
                : watchedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MovieImplCopyWith<$Res> implements $MovieCopyWith<$Res> {
  factory _$$MovieImplCopyWith(
    _$MovieImpl value,
    $Res Function(_$MovieImpl) then,
  ) = __$$MovieImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String overview,
    String? posterUrl,
    String? backdropUrl,
    List<String> genres,
    String releaseDate,
    @JsonKey(name: 'vote_average') double voteAverage,
    @JsonKey(name: 'vote_count') int voteCount,
    int runtime,
    List<String> cast,
    String director,
    @JsonKey(name: 'trailer_key') String? trailerKey,
    String? reason,
    @JsonKey(name: 'similar_movies') List<int> similarIds,
    @JsonKey(name: 'is_liked') bool isLiked,
    @JsonKey(name: 'is_disliked') bool isDisliked,
    @JsonKey(name: 'is_super_liked') bool isSuperLiked,
    @JsonKey(name: 'is_watched') bool isWatched,
    @JsonKey(name: 'liked_at') DateTime? likedAt,
    @JsonKey(name: 'watched_at') DateTime? watchedAt,
  });
}

/// @nodoc
class __$$MovieImplCopyWithImpl<$Res>
    extends _$MovieCopyWithImpl<$Res, _$MovieImpl>
    implements _$$MovieImplCopyWith<$Res> {
  __$$MovieImplCopyWithImpl(
    _$MovieImpl _value,
    $Res Function(_$MovieImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? overview = null,
    Object? posterUrl = freezed,
    Object? backdropUrl = freezed,
    Object? genres = null,
    Object? releaseDate = null,
    Object? voteAverage = null,
    Object? voteCount = null,
    Object? runtime = null,
    Object? cast = null,
    Object? director = null,
    Object? trailerKey = freezed,
    Object? reason = freezed,
    Object? similarIds = null,
    Object? isLiked = null,
    Object? isDisliked = null,
    Object? isSuperLiked = null,
    Object? isWatched = null,
    Object? likedAt = freezed,
    Object? watchedAt = freezed,
  }) {
    return _then(
      _$MovieImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        overview: null == overview
            ? _value.overview
            : overview // ignore: cast_nullable_to_non_nullable
                  as String,
        posterUrl: freezed == posterUrl
            ? _value.posterUrl
            : posterUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        backdropUrl: freezed == backdropUrl
            ? _value.backdropUrl
            : backdropUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        genres: null == genres
            ? _value._genres
            : genres // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        releaseDate: null == releaseDate
            ? _value.releaseDate
            : releaseDate // ignore: cast_nullable_to_non_nullable
                  as String,
        voteAverage: null == voteAverage
            ? _value.voteAverage
            : voteAverage // ignore: cast_nullable_to_non_nullable
                  as double,
        voteCount: null == voteCount
            ? _value.voteCount
            : voteCount // ignore: cast_nullable_to_non_nullable
                  as int,
        runtime: null == runtime
            ? _value.runtime
            : runtime // ignore: cast_nullable_to_non_nullable
                  as int,
        cast: null == cast
            ? _value._cast
            : cast // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        director: null == director
            ? _value.director
            : director // ignore: cast_nullable_to_non_nullable
                  as String,
        trailerKey: freezed == trailerKey
            ? _value.trailerKey
            : trailerKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        similarIds: null == similarIds
            ? _value._similarIds
            : similarIds // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        isLiked: null == isLiked
            ? _value.isLiked
            : isLiked // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDisliked: null == isDisliked
            ? _value.isDisliked
            : isDisliked // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSuperLiked: null == isSuperLiked
            ? _value.isSuperLiked
            : isSuperLiked // ignore: cast_nullable_to_non_nullable
                  as bool,
        isWatched: null == isWatched
            ? _value.isWatched
            : isWatched // ignore: cast_nullable_to_non_nullable
                  as bool,
        likedAt: freezed == likedAt
            ? _value.likedAt
            : likedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        watchedAt: freezed == watchedAt
            ? _value.watchedAt
            : watchedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MovieImpl implements _Movie {
  const _$MovieImpl({
    required this.id,
    required this.title,
    required this.overview,
    this.posterUrl,
    this.backdropUrl,
    final List<String> genres = const [],
    this.releaseDate = '1970-01-01',
    @JsonKey(name: 'vote_average') this.voteAverage = 0.0,
    @JsonKey(name: 'vote_count') this.voteCount = 0,
    this.runtime = 0,
    final List<String> cast = const [],
    this.director = '',
    @JsonKey(name: 'trailer_key') this.trailerKey,
    this.reason,
    @JsonKey(name: 'similar_movies') final List<int> similarIds = const [],
    @JsonKey(name: 'is_liked') this.isLiked = false,
    @JsonKey(name: 'is_disliked') this.isDisliked = false,
    @JsonKey(name: 'is_super_liked') this.isSuperLiked = false,
    @JsonKey(name: 'is_watched') this.isWatched = false,
    @JsonKey(name: 'liked_at') this.likedAt,
    @JsonKey(name: 'watched_at') this.watchedAt,
  }) : _genres = genres,
       _cast = cast,
       _similarIds = similarIds;

  factory _$MovieImpl.fromJson(Map<String, dynamic> json) =>
      _$$MovieImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String overview;
  @override
  final String? posterUrl;
  @override
  final String? backdropUrl;
  final List<String> _genres;
  @override
  @JsonKey()
  List<String> get genres {
    if (_genres is EqualUnmodifiableListView) return _genres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genres);
  }

  @override
  @JsonKey()
  final String releaseDate;
  @override
  @JsonKey(name: 'vote_average')
  final double voteAverage;
  @override
  @JsonKey(name: 'vote_count')
  final int voteCount;
  @override
  @JsonKey()
  final int runtime;
  final List<String> _cast;
  @override
  @JsonKey()
  List<String> get cast {
    if (_cast is EqualUnmodifiableListView) return _cast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cast);
  }

  @override
  @JsonKey()
  final String director;
  @override
  @JsonKey(name: 'trailer_key')
  final String? trailerKey;
  @override
  final String? reason;
  // New field from Hybrid Hydra engine
  final List<int> _similarIds;
  // New field from Hybrid Hydra engine
  @override
  @JsonKey(name: 'similar_movies')
  List<int> get similarIds {
    if (_similarIds is EqualUnmodifiableListView) return _similarIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_similarIds);
  }

  @override
  @JsonKey(name: 'is_liked')
  final bool isLiked;
  @override
  @JsonKey(name: 'is_disliked')
  final bool isDisliked;
  @override
  @JsonKey(name: 'is_super_liked')
  final bool isSuperLiked;
  @override
  @JsonKey(name: 'is_watched')
  final bool isWatched;
  @override
  @JsonKey(name: 'liked_at')
  final DateTime? likedAt;
  @override
  @JsonKey(name: 'watched_at')
  final DateTime? watchedAt;

  @override
  String toString() {
    return 'Movie(id: $id, title: $title, overview: $overview, posterUrl: $posterUrl, backdropUrl: $backdropUrl, genres: $genres, releaseDate: $releaseDate, voteAverage: $voteAverage, voteCount: $voteCount, runtime: $runtime, cast: $cast, director: $director, trailerKey: $trailerKey, reason: $reason, similarIds: $similarIds, isLiked: $isLiked, isDisliked: $isDisliked, isSuperLiked: $isSuperLiked, isWatched: $isWatched, likedAt: $likedAt, watchedAt: $watchedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MovieImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.posterUrl, posterUrl) ||
                other.posterUrl == posterUrl) &&
            (identical(other.backdropUrl, backdropUrl) ||
                other.backdropUrl == backdropUrl) &&
            const DeepCollectionEquality().equals(other._genres, _genres) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.voteAverage, voteAverage) ||
                other.voteAverage == voteAverage) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount) &&
            (identical(other.runtime, runtime) || other.runtime == runtime) &&
            const DeepCollectionEquality().equals(other._cast, _cast) &&
            (identical(other.director, director) ||
                other.director == director) &&
            (identical(other.trailerKey, trailerKey) ||
                other.trailerKey == trailerKey) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            const DeepCollectionEquality().equals(
              other._similarIds,
              _similarIds,
            ) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked) &&
            (identical(other.isSuperLiked, isSuperLiked) ||
                other.isSuperLiked == isSuperLiked) &&
            (identical(other.isWatched, isWatched) ||
                other.isWatched == isWatched) &&
            (identical(other.likedAt, likedAt) || other.likedAt == likedAt) &&
            (identical(other.watchedAt, watchedAt) ||
                other.watchedAt == watchedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    overview,
    posterUrl,
    backdropUrl,
    const DeepCollectionEquality().hash(_genres),
    releaseDate,
    voteAverage,
    voteCount,
    runtime,
    const DeepCollectionEquality().hash(_cast),
    director,
    trailerKey,
    reason,
    const DeepCollectionEquality().hash(_similarIds),
    isLiked,
    isDisliked,
    isSuperLiked,
    isWatched,
    likedAt,
    watchedAt,
  ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MovieImplCopyWith<_$MovieImpl> get copyWith =>
      __$$MovieImplCopyWithImpl<_$MovieImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MovieImplToJson(this);
  }
}

abstract class _Movie implements Movie {
  const factory _Movie({
    required final int id,
    required final String title,
    required final String overview,
    final String? posterUrl,
    final String? backdropUrl,
    final List<String> genres,
    final String releaseDate,
    @JsonKey(name: 'vote_average') final double voteAverage,
    @JsonKey(name: 'vote_count') final int voteCount,
    final int runtime,
    final List<String> cast,
    final String director,
    @JsonKey(name: 'trailer_key') final String? trailerKey,
    final String? reason,
    @JsonKey(name: 'similar_movies') final List<int> similarIds,
    @JsonKey(name: 'is_liked') final bool isLiked,
    @JsonKey(name: 'is_disliked') final bool isDisliked,
    @JsonKey(name: 'is_super_liked') final bool isSuperLiked,
    @JsonKey(name: 'is_watched') final bool isWatched,
    @JsonKey(name: 'liked_at') final DateTime? likedAt,
    @JsonKey(name: 'watched_at') final DateTime? watchedAt,
  }) = _$MovieImpl;

  factory _Movie.fromJson(Map<String, dynamic> json) = _$MovieImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get overview;
  @override
  String? get posterUrl;
  @override
  String? get backdropUrl;
  @override
  List<String> get genres;
  @override
  String get releaseDate;
  @override
  @JsonKey(name: 'vote_average')
  double get voteAverage;
  @override
  @JsonKey(name: 'vote_count')
  int get voteCount;
  @override
  int get runtime;
  @override
  List<String> get cast;
  @override
  String get director;
  @override
  @JsonKey(name: 'trailer_key')
  String? get trailerKey;
  @override
  String? get reason;
  @override // New field from Hybrid Hydra engine
  @JsonKey(name: 'similar_movies')
  List<int> get similarIds;
  @override
  @JsonKey(name: 'is_liked')
  bool get isLiked;
  @override
  @JsonKey(name: 'is_disliked')
  bool get isDisliked;
  @override
  @JsonKey(name: 'is_super_liked')
  bool get isSuperLiked;
  @override
  @JsonKey(name: 'is_watched')
  bool get isWatched;
  @override
  @JsonKey(name: 'liked_at')
  DateTime? get likedAt;
  @override
  @JsonKey(name: 'watched_at')
  DateTime? get watchedAt;
  @override
  @JsonKey(ignore: true)
  _$$MovieImplCopyWith<_$MovieImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
