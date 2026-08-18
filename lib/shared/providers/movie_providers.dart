import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../../core/config/app_config.dart';
import '../../data/services/api_client.dart';

/// Movie repository provider
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = ref.watch(dioProvider);
  return ApiMovieRepository(dio, config);
});

/// Movies state provider
final moviesProvider = StateNotifierProvider<MoviesNotifier, MoviesState>((
  ref,
) {
  final repository = ref.watch(movieRepositoryProvider);
  return MoviesNotifier(repository);
});

/// Movies state class
class MoviesState {
  final List<Movie> currentStack;
  final List<Movie> likedMovies;
  final List<Movie> dislikedMovies;
  final bool isLoading;
  final String? error;
  final bool hasMoreMovies;

  const MoviesState({
    this.currentStack = const [],
    this.likedMovies = const [],
    this.dislikedMovies = const [],
    this.isLoading = false,
    this.error,
    this.hasMoreMovies = true,
  });

  MoviesState copyWith({
    List<Movie>? currentStack,
    List<Movie>? likedMovies,
    List<Movie>? dislikedMovies,
    bool? isLoading,
    String? error,
    bool? hasMoreMovies,
  }) {
    return MoviesState(
      currentStack: currentStack ?? this.currentStack,
      likedMovies: likedMovies ?? this.likedMovies,
      dislikedMovies: dislikedMovies ?? this.dislikedMovies,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMoreMovies: hasMoreMovies ?? this.hasMoreMovies,
    );
  }
}

/// Movies state notifier
class MoviesNotifier extends StateNotifier<MoviesState> {
  final MovieRepository _repository;
  int _currentPage = 1;

  MoviesNotifier(this._repository) : super(const MoviesState()) {
    _loadInitialMovies();
  }

  /// Load initial movies
  Future<void> _loadInitialMovies() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final movies = await _repository.getRecommendations(page: 1, limit: 10);
      state = state.copyWith(
        currentStack: movies,
        isLoading: false,
        hasMoreMovies: movies.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load more movies for the stack
  Future<void> loadMoreMovies() async {
    if (state.isLoading || !state.hasMoreMovies) return;

    try {
      _currentPage++;
      final newMovies = await _repository.getRecommendations(
        page: _currentPage,
        limit: 10,
      );

      if (newMovies.isEmpty) {
        state = state.copyWith(hasMoreMovies: false);
      } else {
        state = state.copyWith(
          currentStack: [...state.currentStack, ...newMovies],
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Like a movie
  Future<void> likeMovie(Movie movie) async {
    try {
      await _repository.likeMovie(movie.id);

      // Remove from current stack
      final updatedStack = List<Movie>.from(state.currentStack);
      updatedStack.removeWhere((m) => m.id == movie.id);

      // Add to liked movies
      final updatedLiked = [
        movie.withUserInteraction(UserInteraction.liked),
        ...state.likedMovies,
      ];

      state = state.copyWith(
        currentStack: updatedStack,
        likedMovies: updatedLiked,
      );

      // Load more movies if stack is getting low
      if (updatedStack.length < 3) {
        loadMoreMovies();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Dislike a movie
  Future<void> dislikeMovie(Movie movie) async {
    try {
      await _repository.dislikeMovie(movie.id);

      // Remove from current stack
      final updatedStack = List<Movie>.from(state.currentStack);
      updatedStack.removeWhere((m) => m.id == movie.id);

      // Add to disliked movies
      final updatedDisliked = [
        movie.withUserInteraction(UserInteraction.disliked),
        ...state.dislikedMovies,
      ];

      state = state.copyWith(
        currentStack: updatedStack,
        dislikedMovies: updatedDisliked,
      );

      // Load more movies if stack is getting low
      if (updatedStack.length < 3) {
        loadMoreMovies();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Super like a movie
  Future<void> superLikeMovie(Movie movie) async {
    try {
      await _repository.superLikeMovie(movie.id);

      // Remove from current stack
      final updatedStack = List<Movie>.from(state.currentStack);
      updatedStack.removeWhere((m) => m.id == movie.id);

      // Add to liked movies
      final updatedLiked = [
        movie.withUserInteraction(UserInteraction.superLiked),
        ...state.likedMovies,
      ];

      state = state.copyWith(
        currentStack: updatedStack,
        likedMovies: updatedLiked,
      );

      // Load more movies if stack is getting low
      if (updatedStack.length < 3) {
        loadMoreMovies();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Refresh the movie stack
  Future<void> refresh() async {
    _currentPage = 1;
    state = const MoviesState();
    await _loadInitialMovies();
  }

  /// Undo last swipe
  Future<void> undoLastSwipe() async {
    // This would need more complex logic to track the last swiped movie
    // For now, just refresh
    await refresh();
  }
}

/// Provider for liked movies (basic version)
final basicLikedMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getLikedMovies();
});

/// Provider for watch history (basic version)
final basicWatchHistoryProvider = FutureProvider<List<Movie>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getWatchHistory();
});

/// Provider for movie details (basic version)
final basicMovieDetailsProvider = FutureProvider.family<Movie?, int>((
  ref,
  movieId,
) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getMovieDetails(movieId);
});

/// Provider for movie search (basic version)
final basicMovieSearchProvider = FutureProvider.family<List<Movie>, String>((
  ref,
  query,
) async {
  final repository = ref.watch(movieRepositoryProvider);
  if (query.trim().isEmpty) return [];
  return repository.searchMovies(query);
});
