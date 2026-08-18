import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/movie_model.dart';
import '../../discovery/providers/movie_providers.dart';

class WatchHistoryState {
  final List<Movie> movies;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;
  final bool refreshing;
  const WatchHistoryState({
    this.movies = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
    this.refreshing = false,
  });
  WatchHistoryState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    String? error = '_NO_',
    bool? hasMore,
    int? page,
    bool? refreshing,
  }) => WatchHistoryState(
    movies: movies ?? this.movies,
    isLoading: isLoading ?? this.isLoading,
    error: error == '_NO_' ? this.error : error,
    hasMore: hasMore ?? this.hasMore,
    page: page ?? this.page,
    refreshing: refreshing ?? this.refreshing,
  );
}

class WatchHistoryNotifier extends StateNotifier<WatchHistoryState> {
  WatchHistoryNotifier(this._ref) : super(const WatchHistoryState()) {
    loadInitial();
  }
  final Ref _ref;
  static const _pageSize = 10;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null, page: 1);
    try {
      final repo = _ref.read(movieRepositoryProvider);
      final all = await repo.getWatchHistory();
      state = state.copyWith(
        movies: all.take(_pageSize).toList(),
        isLoading: false,
        hasMore: all.length > _pageSize,
        page: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(movieRepositoryProvider);
      // Fetch only the next page from server if supported; fallback to full for now
      final all = await repo.getWatchHistory();
      final nextPage = state.page + 1;
      final end = nextPage * _pageSize;
      final newList = all.take(end).toList();
      final hasMore = newList.length < all.length;
      state = state.copyWith(
        movies: newList,
        isLoading: false,
        hasMore: hasMore,
        page: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(refreshing: true);
    await loadInitial();
    state = state.copyWith(refreshing: false);
  }

  /// Manually add a movie to the watch history and update state optimistically.
  Future<void> addMovie(Movie movie) async {
    // Prevent duplicates
    if (state.movies.any((m) => m.id == movie.id)) return;
    // Optimistic update (prepend newest)
    final updated = [
      movie.copyWith(isWatched: true, watchedAt: DateTime.now()),
      ...state.movies,
    ];
    state = state.copyWith(movies: updated);
    // Persist via repository
    final repo = _ref.read(movieRepositoryProvider);
    try {
      await repo.addToWatchHistory(movie.id);
    } catch (_) {
      /* ignore */
    }
  }
}

final watchHistoryProvider =
    StateNotifierProvider<WatchHistoryNotifier, WatchHistoryState>(
      (ref) => WatchHistoryNotifier(ref),
    );
