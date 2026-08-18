import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/discovery_screen.dart' show selectedGenresProvider, minRatingFilterProvider;
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/movie_repository.dart';
import '../../../data/services/local_storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../data/services/api_client.dart';
import '../../profile/providers/profile_providers.dart';
import '../../../core/analytics/analytics_service.dart';

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = ref.watch(dioProvider);
  return ApiMovieRepository(dio, config);
});

class MovieStackState {
  final List<Movie> stack; // top card is last element
  final List<Movie> buffer; // prefetched movies to fill stack when depleted
  final bool isLoading;
  final String? error;
  final int page;
  final bool canUndo;
  const MovieStackState({this.stack = const [], this.buffer = const [], this.isLoading = false, this.error, this.page = 1, this.canUndo = false});
  MovieStackState copyWith({List<Movie>? stack, List<Movie>? buffer, bool? isLoading, String? error = '_NO_', int? page, bool? canUndo}) => MovieStackState(
        stack: stack ?? this.stack,
        buffer: buffer ?? this.buffer,
        isLoading: isLoading ?? this.isLoading,
        error: error == '_NO_' ? this.error : error,
        page: page ?? this.page,
        canUndo: canUndo ?? this.canUndo,
      );
}

final moodProvider = StateProvider<String>((ref) => '');

class MovieStackNotifier extends StateNotifier<MovieStackState> {
  MovieStackNotifier(this._ref) : super(const MovieStackState()) { _init(); }
  final Ref _ref;
  static const _prefetchThreshold = 3; static const _pageSize = 10;
  final List<_SwipeRecord> _history = [];
  LocalStorageService? _storage;
  bool _hasMore = true;
  int _emptyPageStreak = 0; // stop after a couple of empty/filtered pages

  Future<void> _init() async { 
    _storage = await LocalStorageService.getInstance(); 
    _setupListeners(); 
    await loadMore(); 
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return; 
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(movieRepositoryProvider);
      final mood = _ref.read(moodProvider);
      final movies = await repo.getRecommendations(
        page: state.page, 
        limit: _pageSize,
        mood: mood.isNotEmpty ? mood : null,
      );
      final weighted = _applyPreferenceWeighting(movies);
      final filtered = _applyActiveFilters(weighted);

      // Track empties to avoid infinite fetching
      if (filtered.isEmpty) {
        _emptyPageStreak += 1;
        if (movies.isEmpty || _emptyPageStreak >= 2) {
          _hasMore = false;
        }
      } else {
        _emptyPageStreak = 0;
      }

      state = state.copyWith(
        buffer: [...state.buffer, ...filtered],
        isLoading: false,
        page: state.page + 1,
      );
      _ensureStackFilled();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  List<Movie> _applyPreferenceWeighting(List<Movie> movies){ final authState = _ref.read(authProvider); final prefsGenres = authState.user?.preferredGenres ?? []; if(prefsGenres.isEmpty) return movies; final genreSet = prefsGenres.map((g)=> g.toLowerCase()).toSet(); final scored = movies.map((m){ final match = m.genres.where((g)=> genreSet.contains(g.toLowerCase())).length; return MapEntry(m, match); }).toList(); scored.sort((a,b)=> b.value.compareTo(a.value)); return scored.map((e)=> e.key).toList(); }

  void _ensureStackFilled(){
    final needed = 5 - state.stack.length; 
    if(needed>0 && state.buffer.isNotEmpty){ 
      final toAdd = state.buffer.take(needed).toList(); 
      state = state.copyWith(stack: [...toAdd.reversed, ...state.stack], buffer: state.buffer.skip(toAdd.length).toList()); 
    }
    if(state.buffer.length < _prefetchThreshold && _hasMore){ 
      loadMore(); 
    }
  }

  List<Movie> _applyActiveFilters(List<Movie> movies){ final genres = _ref.read(selectedGenresProvider); final minRating = _ref.read(minRatingFilterProvider); if(genres.isEmpty && minRating==0) return movies; return movies.where((m){ final matchGenres = genres.isEmpty || m.genres.any((g)=> genres.contains(g)); final matchRating = m.voteAverage >= minRating; return matchGenres && matchRating; }).toList(); }

  void _onParamsChanged(){ 
    _hasMore = true; 
    _emptyPageStreak = 0; 
    state = state.copyWith(stack: [], buffer: [], page: 1, error: null); 
    loadMore(); 
  }

  void _setupListeners(){ 
    _ref.listen<Set<String>>(selectedGenresProvider, (_, __)=> _onParamsChanged()); 
    _ref.listen<double>(minRatingFilterProvider, (_, __)=> _onParamsChanged()); 
    _ref.listen<String>(moodProvider, (_, __) => _onParamsChanged());
  }

  Movie? get topMovie => state.stack.isEmpty ? null : state.stack.last;

  Future<void> swipe(Movie movie, UserInteraction interaction) async {
    // 1. Optimistically update stack immediately so UI is perfectly fluid
    final newStack = [...state.stack]..removeWhere((m)=>m.id==movie.id);
    _history.add(_SwipeRecord(movie: movie, interaction: interaction));
    state = state.copyWith(stack: newStack, canUndo: true);
    _persistInteraction(movie.id, interaction);
    _ensureStackFilled();

    // Track swipe event
    AnalyticsService.trackEvent('movie_swiped', properties: {
      'movie_id': movie.id,
      'movie_title': movie.title,
      'interaction': interaction.name,
    });

    // 2. Perform network request asynchronously in the background
    final repo = _ref.read(movieRepositoryProvider);
    try {
      switch(interaction){
        case UserInteraction.liked: await repo.likeMovie(movie.id); break;
        case UserInteraction.disliked: await repo.dislikeMovie(movie.id); break;
        case UserInteraction.superLiked: await repo.superLikeMovie(movie.id); break;
        case UserInteraction.none: break;
      }
    } catch (e) {
      debugPrint("Background swipe request failed: $e");
    }
    
    // Reactively refresh user profile stats
    _ref.invalidate(userStatsProvider);
  }

  Future<void> undo() async {
    if(_history.isEmpty) return;
    final last = _history.removeLast();
    final newStack = [...state.stack, last.movie];
    state = state.copyWith(stack: newStack, canUndo: _history.isNotEmpty);
    if(last.interaction != UserInteraction.none){
      _removePersistedInteraction(last.movie.id, last.interaction);
    }
    
    // Track undo event
    AnalyticsService.trackEvent('movie_swipe_undone', properties: {
      'movie_id': last.movie.id,
      'movie_title': last.movie.title,
      'interaction': last.interaction.name,
    });

    // Reactively refresh user profile stats
    _ref.invalidate(userStatsProvider);
  }

  Future<void> _persistInteraction(int movieId, UserInteraction interaction) async { if(_storage==null) return; if(interaction == UserInteraction.none) return; final idStr = movieId.toString(); if(interaction == UserInteraction.liked || interaction == UserInteraction.superLiked){ final liked = await _storage!.getLikedMovies(); if(!liked.contains(idStr)){ liked.add(idStr); await _storage!.saveLikedMovies(liked); } } else if(interaction == UserInteraction.disliked){ final disliked = await _storage!.getDislikedMovies(); if(!disliked.contains(idStr)){ disliked.add(idStr); await _storage!.saveDislikedMovies(disliked); } } }

  Future<void> _removePersistedInteraction(int movieId, UserInteraction interaction) async { if(_storage==null) return; final idStr = movieId.toString(); if(interaction == UserInteraction.liked || interaction == UserInteraction.superLiked){ final liked = await _storage!.getLikedMovies(); liked.remove(idStr); await _storage!.saveLikedMovies(liked); } else if(interaction == UserInteraction.disliked){ final disliked = await _storage!.getDislikedMovies(); disliked.remove(idStr); await _storage!.saveDislikedMovies(disliked); } }
}

final movieStackProvider = StateNotifierProvider<MovieStackNotifier, MovieStackState>((ref) => MovieStackNotifier(ref));

class _SwipeRecord { final Movie movie; final UserInteraction interaction; _SwipeRecord({required this.movie, required this.interaction}); }
