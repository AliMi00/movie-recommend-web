import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/movie_repository.dart';
import '../../../shared/providers/movie_providers.dart'
    show movieRepositoryProvider;

/// State notifier that manages the watchlist list of movies reactively
class WatchlistNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final MovieRepository _repository;

  WatchlistNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadWatchlist();
  }

  /// Load watchlisted movies
  Future<void> loadWatchlist() async {
    state = const AsyncValue.loading();
    try {
      final movies = await _repository.getWatchlist();
      state = AsyncValue.data(movies);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Check if a movie is currently in the watchlist
  bool isInWatchlist(int movieId) {
    if (state is AsyncData<List<Movie>>) {
      return state.value!.any((m) => m.id == movieId);
    }
    return false;
  }

  /// Remove a movie from the watchlist
  Future<void> removeFromWatchlist(int movieId) async {
    try {
      await _repository.removeFromWatchlist(movieId);

      if (state is AsyncData<List<Movie>>) {
        final currentList = state.value!;
        state = AsyncValue.data(
          currentList.where((m) => m.id != movieId).toList(),
        );
      }
    } catch (e) {
      // ignore
    }
  }

  /// Add a movie to the watchlist
  Future<void> addToWatchlist(Movie movie) async {
    try {
      await _repository.addToWatchlist(movie.id);

      if (state is AsyncData<List<Movie>>) {
        final currentList = state.value!;
        if (!currentList.any((m) => m.id == movie.id)) {
          state = AsyncValue.data([
            ...currentList,
            movie.copyWith(isLiked: true),
          ]);
        }
      } else {
        state = AsyncValue.data([movie.copyWith(isLiked: true)]);
      }
    } catch (e) {
      // ignore
    }
  }

  /// Toggle a movie's watchlist status
  Future<void> toggleWatchlist(Movie movie) async {
    if (isInWatchlist(movie.id)) {
      await removeFromWatchlist(movie.id);
    } else {
      await addToWatchlist(movie);
    }
  }
}

/// Provider for reactive watchlist movies
final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, AsyncValue<List<Movie>>>((ref) {
      final repository = ref.watch(movieRepositoryProvider);
      return WatchlistNotifier(repository);
    });
