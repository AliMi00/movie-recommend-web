// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MovieImpl _$$MovieImplFromJson(Map<String, dynamic> json) => _$MovieImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterUrl: json['posterUrl'] as String?,
      backdropUrl: json['backdropUrl'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      releaseDate: json['releaseDate'] as String? ?? '1970-01-01',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      runtime: (json['runtime'] as num?)?.toInt() ?? 0,
      cast:
          (json['cast'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      director: json['director'] as String? ?? '',
      trailerKey: json['trailer_key'] as String?,
      reason: json['reason'] as String?,
      similarIds: (json['similar_movies'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      isLiked: json['is_liked'] as bool? ?? false,
      isDisliked: json['is_disliked'] as bool? ?? false,
      isSuperLiked: json['is_super_liked'] as bool? ?? false,
      isWatched: json['is_watched'] as bool? ?? false,
      likedAt: json['liked_at'] == null
          ? null
          : DateTime.parse(json['liked_at'] as String),
      watchedAt: json['watched_at'] == null
          ? null
          : DateTime.parse(json['watched_at'] as String),
    );

Map<String, dynamic> _$$MovieImplToJson(_$MovieImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'overview': instance.overview,
      'posterUrl': instance.posterUrl,
      'backdropUrl': instance.backdropUrl,
      'genres': instance.genres,
      'releaseDate': instance.releaseDate,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'runtime': instance.runtime,
      'cast': instance.cast,
      'director': instance.director,
      'trailer_key': instance.trailerKey,
      'reason': instance.reason,
      'similar_movies': instance.similarIds,
      'is_liked': instance.isLiked,
      'is_disliked': instance.isDisliked,
      'is_super_liked': instance.isSuperLiked,
      'is_watched': instance.isWatched,
      'liked_at': instance.likedAt?.toIso8601String(),
      'watched_at': instance.watchedAt?.toIso8601String(),
    };
