// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie_model.freezed.dart';
part 'movie_model.g.dart';

@freezed
class Movie with _$Movie {
  const factory Movie({
    required int id,
    required String title,
    required String overview,
    String? posterUrl,
    String? backdropUrl,
    @Default([]) List<String> genres,
    @Default('1970-01-01') String releaseDate,
    @JsonKey(name: 'vote_average') @Default(0.0) double voteAverage,
    @JsonKey(name: 'vote_count') @Default(0) int voteCount,
    @Default(0) int runtime,
    @Default([]) List<String> cast,
    @Default('') String director,
    @JsonKey(name: 'trailer_key') String? trailerKey,
    String? reason, // New field from Hybrid Hydra engine
    @JsonKey(name: 'similar_movies') @Default([]) List<int> similarIds,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,
    @JsonKey(name: 'is_disliked') @Default(false) bool isDisliked,
    @JsonKey(name: 'is_super_liked') @Default(false) bool isSuperLiked,
    @JsonKey(name: 'is_watched') @Default(false) bool isWatched,
    @JsonKey(name: 'liked_at') DateTime? likedAt,
    @JsonKey(name: 'watched_at') DateTime? watchedAt,
  }) = _Movie;

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
}

/// Extension to add utility methods to Movie
extension MovieExtension on Movie {
  /// Get the full poster URL with optional base URL host
  String getFullPosterPath([String? baseUrlHost]) {
    if (posterUrl == null || posterUrl!.isEmpty) {
      return 'assets/images/movie_poster_placeholder.png';
    }
    if (posterUrl!.startsWith('http')) {
      return posterUrl!;
    }
    if (posterUrl!.startsWith('/')) {
      final host = (baseUrlHost != null && baseUrlHost.isNotEmpty) ? baseUrlHost.replaceAll(RegExp(r'/v1/?$'), '') : '';
      return '$host$posterUrl';
    }
    return 'https://image.tmdb.org/t/p/w500/$posterUrl';
  }

  String get fullPosterPath => getFullPosterPath();

  /// Get the full backdrop URL with optional base URL host
  String getFullBackdropPath([String? baseUrlHost]) {
    if (backdropUrl == null || backdropUrl!.isEmpty) {
      return 'assets/images/movie_backdrop_placeholder.png';
    }
    if (backdropUrl!.startsWith('http')) {
      return backdropUrl!;
    }
    if (backdropUrl!.startsWith('/')) {
      final host = (baseUrlHost != null && baseUrlHost.isNotEmpty) ? baseUrlHost.replaceAll(RegExp(r'/v1/?$'), '') : '';
      return '$host$backdropUrl';
    }
    return 'https://image.tmdb.org/t/p/w1280/$backdropUrl';
  }

  String get fullBackdropPath => getFullBackdropPath();

  /// Get the release year
  String get releaseYear {
    try {
      return DateTime.parse(releaseDate).year.toString();
    } catch (e) {
      return 'TBA';
    }
  }

  /// Get formatted runtime
  String get formattedRuntime {
    if (runtime <= 0) return 'Unknown';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get formatted rating
  String get formattedRating {
    return voteAverage.toStringAsFixed(1);
  }

  /// Get genres as a single string
  String get genresString {
    return genres.take(3).join(', ');
  }

  /// Get primary cast as string
  String get castString {
    return cast.take(3).join(', ');
  }

  /// Check if movie has trailer
  bool get hasTrailer {
    return trailerKey != null && trailerKey!.isNotEmpty;
  }

  /// Get YouTube trailer URL
  String get youtubeTrailerUrl {
    if (!hasTrailer) return '';
    return 'https://www.youtube.com/watch?v=$trailerKey';
  }

  /// Get user interaction status
  UserInteraction get userInteraction {
    if (isSuperLiked) return UserInteraction.superLiked;
    if (isLiked) return UserInteraction.liked;
    if (isDisliked) return UserInteraction.disliked;
    return UserInteraction.none;
  }

  /// Create a copy with user interaction
  Movie withUserInteraction(UserInteraction interaction) {
    switch (interaction) {
      case UserInteraction.liked:
        return copyWith(
          isLiked: true,
          isDisliked: false,
          isSuperLiked: false,
          likedAt: DateTime.now(),
        );
      case UserInteraction.disliked:
        return copyWith(
          isLiked: false,
          isDisliked: true,
          isSuperLiked: false,
          likedAt: null,
        );
      case UserInteraction.superLiked:
        return copyWith(
          isLiked: true,
          isDisliked: false,
          isSuperLiked: true,
          likedAt: DateTime.now(),
        );
      case UserInteraction.none:
        return copyWith(
          isLiked: false,
          isDisliked: false,
          isSuperLiked: false,
          likedAt: null,
        );
    }
  }
}

enum UserInteraction {
  none,
  liked,
  disliked,
  superLiked,
}
