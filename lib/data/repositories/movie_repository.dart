import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/local_storage_service.dart';
import '../models/movie_model.dart';
import '../../core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';

/// Repository interface for movie data
abstract class MovieRepository {
  Future<List<Movie>> getRecommendations({int page = 1, int limit = 20, String? mood});
  Future<Movie?> getMovieDetails(int movieId);
  Future<List<Movie>> searchMovies(String query);
  Future<List<Movie>> getMoviesByGenre(String genre);
  Future<List<Movie>> getLikedMovies();
  Future<List<Movie>> getWatchHistory();
  Future<void> likeMovie(int movieId);
  Future<void> dislikeMovie(int movieId);
  Future<void> superLikeMovie(int movieId);
  Future<void> undoSwipe(int movieId);
  /// Manually add a movie to watch history (without liking). No-op if already present.
  Future<void> addToWatchlist(int movieId);
  Future<void> removeFromWatchlist(int movieId);
  Future<List<Movie>> getWatchlist({int page = 1, int limit = 20});
  Future<void> addToWatchHistory(int movieId);
}

/// Mock implementation of MovieRepository using local JSON data
class MockMovieRepository implements MovieRepository {
  static final MockMovieRepository _instance = MockMovieRepository._internal();
  factory MockMovieRepository() => _instance;
  MockMovieRepository._internal();

  List<Movie>? _cachedMovies;
  final List<Movie> _likedMovies = [];
  final List<Movie> _dislikedMovies = [];
  final List<Movie> _superLikedMovies = [];
  final List<Movie> _watchHistory = [];
  final List<Movie> _watchlist = [];
  bool _watchHistoryHydrated = false;
  bool simulateErrors = true; // can be toggled in settings later

  // Lazy storage
  LocalStorageService? _storage;
  Future<LocalStorageService> get _ensureStorage async => _storage ??= await LocalStorageService.getInstance();

  /// Load movies from assets
  Future<List<Movie>> _loadMovies() async {
    if (_cachedMovies != null) return _cachedMovies!;

    try {
      final String jsonString = await rootBundle.loadString(AppConstants.mockDataAssetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> moviesJson = jsonData['movies'];
      
      _cachedMovies = moviesJson.map((json) => Movie.fromJson(json)).toList();
      return _cachedMovies!;
    } catch (e) {
      // If loading from assets fails, return hardcoded movies
      return _getHardcodedMovies();
    }
  }

  /// Hardcoded movies as fallback
  List<Movie> _getHardcodedMovies() {
    return [
      const Movie(
        id: 1001,
        title: "The Stellar Journey",
        overview: "An epic space adventure following a crew of explorers as they venture beyond the known galaxy to discover new worlds and face unimaginable dangers in the depths of space.",
        posterUrl: "/assets/mock_posters/stellar_journey.jpg",
        backdropUrl: "/assets/mock_backdrops/stellar_journey.jpg",
        genres: ["Science Fiction", "Adventure", "Drama"],
        releaseDate: "2024-03-15",
        voteAverage: 8.2,
        voteCount: 12450,
        runtime: 142,
        cast: ["Emma Stone", "Ryan Gosling", "Michael Shannon"],
        director: "Christopher Nolan",
        trailerKey: "dQw4w9WgXcQ",
        reason: "Hybrid Hydra (Semantic + Graph)",
        similarIds: [1002, 1003, 1004],
      ),
      const Movie(
        id: 1002,
        title: "Midnight in Paris",
        overview: "A romantic comedy about a writer who mysteriously finds himself transported back to the 1920s literary scene in Paris every night at midnight.",
        posterUrl: "/assets/mock_posters/midnight_paris.jpg",
        backdropUrl: "/assets/mock_backdrops/midnight_paris.jpg",
        genres: ["Romance", "Comedy", "Fantasy"],
        releaseDate: "2024-01-20",
        voteAverage: 7.8,
        voteCount: 8920,
        runtime: 118,
        cast: ["Timothée Chalamet", "Saoirse Ronan", "Bill Murray"],
        director: "Greta Gerwig",
        trailerKey: "xyz123abc",
        reason: "Top Trending Romantic Fantasy",
        similarIds: [1001, 1003, 1005],
      ),
    ];
  }

  @override
  Future<List<Movie>> getRecommendations({int page = 1, int limit = 20, String? mood}) async {
    final movies = await _loadMovies();
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulated transient network error (10% chance) after first page
    if(simulateErrors && page > 1){
      final r = DateTime.now().microsecondsSinceEpoch % 10; // pseudo-random
      if(r==0){
        throw Exception('Simulated network error. Please retry.');
      }
    }
    
    // Filter out already swiped movies
    final swipedMovieIds = <int>{
      ..._likedMovies.map((m) => m.id),
      ..._dislikedMovies.map((m) => m.id),
      ..._superLikedMovies.map((m) => m.id),
    };
    
    final availableMovies = movies.where((movie) => !swipedMovieIds.contains(movie.id)).toList();
    
    // Shuffle for variety
    availableMovies.shuffle();
    
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= availableMovies.length) {
      return [];
    }
    
    return availableMovies.sublist(
      startIndex, 
      endIndex > availableMovies.length ? availableMovies.length : endIndex,
    );
  }

  @override
  Future<Movie?> getMovieDetails(int movieId) async {
    final movies = await _loadMovies();
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return movies.firstWhere((movie) => movie.id == movieId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    
    final movies = await _loadMovies();
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    final lowercaseQuery = query.toLowerCase();
    return movies.where((movie) {
      return movie.title.toLowerCase().contains(lowercaseQuery) ||
             movie.overview.toLowerCase().contains(lowercaseQuery) ||
             movie.director.toLowerCase().contains(lowercaseQuery) ||
             movie.cast.any((actor) => actor.toLowerCase().contains(lowercaseQuery)) ||
             movie.genres.any((genre) => genre.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  @override
  Future<List<Movie>> getMoviesByGenre(String genre) async {
    final movies = await _loadMovies();
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    return movies.where((movie) => 
      movie.genres.any((g) => g.toLowerCase() == genre.toLowerCase())
    ).toList();
  }

  @override
  Future<List<Movie>> getLikedMovies() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_likedMovies)..sort((a, b) => (b.likedAt ?? DateTime.now()).compareTo(a.likedAt ?? DateTime.now()));
  }

  @override
  Future<List<Movie>> getWatchHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Hydrate from persistence once
    if(!_watchHistoryHydrated){
      try {
        final storage = await _ensureStorage;
        final ids = await storage.getWatchHistory();
        for(final idStr in ids){
          final id = int.tryParse(idStr);
            if(id!=null && !_watchHistory.any((m)=> m.id==id)){
              final m = await getMovieDetails(id);
              if(m!=null){
                _watchHistory.add(m.copyWith(isWatched: true));
              }
            }
        }
      } catch(_){ /* ignore */ }
      _watchHistoryHydrated = true;
    }
    return List.from(_watchHistory)..sort((a, b) => (b.watchedAt ?? DateTime.now()).compareTo(a.watchedAt ?? DateTime.now()));
  }

  @override
  Future<void> likeMovie(int movieId) async {
    final movie = await getMovieDetails(movieId);
    if (movie != null) {
      final likedMovie = movie.copyWith(
        isLiked: true,
        isDisliked: false,
        isSuperLiked: false,
        likedAt: DateTime.now(),
      );
      
      // Remove from other lists
      _dislikedMovies.removeWhere((m) => m.id == movieId);
      _superLikedMovies.removeWhere((m) => m.id == movieId);
      _likedMovies.removeWhere((m) => m.id == movieId);
      
      // Add to liked list
      _likedMovies.add(likedMovie);
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> dislikeMovie(int movieId) async {
    final movie = await getMovieDetails(movieId);
    if (movie != null) {
      final dislikedMovie = movie.copyWith(
        isLiked: false,
        isDisliked: true,
        isSuperLiked: false,
        likedAt: null,
      );
      
      // Remove from other lists
      _likedMovies.removeWhere((m) => m.id == movieId);
      _superLikedMovies.removeWhere((m) => m.id == movieId);
      _dislikedMovies.removeWhere((m) => m.id == movieId);
      
      // Add to disliked list
      _dislikedMovies.add(dislikedMovie);
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> superLikeMovie(int movieId) async {
    final movie = await getMovieDetails(movieId);
    if (movie != null) {
      final superLikedMovie = movie.copyWith(
        isLiked: true,
        isDisliked: false,
        isSuperLiked: true,
        likedAt: DateTime.now(),
      );
      
      // Remove from other lists
      _dislikedMovies.removeWhere((m) => m.id == movieId);
      _likedMovies.removeWhere((m) => m.id == movieId);
      _superLikedMovies.removeWhere((m) => m.id == movieId);
      
      // Add to super liked list
      _superLikedMovies.add(superLikedMovie);
      
      // Also add to liked movies
      _likedMovies.add(superLikedMovie);
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> undoSwipe(int movieId) async {
    // Remove from all swipe lists
    _likedMovies.removeWhere((m) => m.id == movieId);
    _dislikedMovies.removeWhere((m) => m.id == movieId);
    _superLikedMovies.removeWhere((m) => m.id == movieId);
    
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<List<Movie>> getWatchlist({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_watchlist);
  }

  @override
  Future<void> addToWatchlist(int movieId) async {
    if (_watchlist.any((m) => m.id == movieId)) return;
    final movie = await getMovieDetails(movieId);
    if (movie != null) {
      _watchlist.add(movie.copyWith(isLiked: true));
    }
  }

  @override
  Future<void> removeFromWatchlist(int movieId) async {
    _watchlist.removeWhere((m) => m.id == movieId);
  }

  @override
  Future<void> addToWatchHistory(int movieId) async {
    // If already in history, just return
    if(_watchHistory.any((m)=> m.id == movieId)) return;
    final movie = await getMovieDetails(movieId);
    if(movie == null) return; // silently ignore invalid id
    _watchHistory.add(movie.copyWith(isWatched: true, watchedAt: DateTime.now()));
    try {
      final storage = await _ensureStorage; 
      await storage.saveWatchHistory(_watchHistory.map((m)=> m.id.toString()).toList());
    } catch(_){ /* ignore persistence errors */ }
  }

  /// Get user statistics
  Map<String, int> getUserStats() {
    return {
      'total_swipes': _likedMovies.length + _dislikedMovies.length,
      'liked_movies': _likedMovies.length,
      'disliked_movies': _dislikedMovies.length,
      'super_liked_movies': _superLikedMovies.length,
      'watched_movies': _watchHistory.length,
    };
  }

  /// Reset all user data (useful for testing)
  void resetUserData() {
    _likedMovies.clear();
    _dislikedMovies.clear();
    _superLikedMovies.clear();
    _watchHistory.clear();
  _watchHistoryHydrated = false;
  () async { try { final storage = await _ensureStorage; await storage.saveWatchHistory([]); } catch(_){ } }();
  }
}

/// API implementation using Dio and the external REST API (v1)
class ApiMovieRepository implements MovieRepository {
  final Dio _dio;
  final AppConfig _config;
  ApiMovieRepository(this._dio, this._config);

  @override
  Future<List<Movie>> getRecommendations({int page = 1, int limit = 20, String? mood}) async {
    try {
      final res = await _dio.get('/movies/recommendations', queryParameters: {
        'page': page,
        'page_size': limit,
        if (mood != null && mood.isNotEmpty) 'mood': mood,
      });
      final data = res.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Movie?> getMovieDetails(int movieId) async {
    try {
      final res = await _dio.get('/movies/$movieId');
      if (res.statusCode == 200) {
        // Handle both wrapped and unwrapped response
        final data = res.data is Map && res.data['data'] != null 
            ? res.data['data'] 
            : res.data;
        return Movie.fromJson(data as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final res = await _dio.get('/movies/search', queryParameters: {
        'q': query,
        'page': 1,
        'page_size': _config.defaultPageSize,
      });
      final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>? ?? [];
      return data.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Movie>> getMoviesByGenre(String genre) async {
    try {
      final res = await _dio.get('/movies', queryParameters: {
        'genre': genre,
        'page': 1,
        'page_size': _config.defaultPageSize,
      });
      final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>? ?? [];
      return data.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Movie>> getLikedMovies() async {
    // Backend doesn't have a direct list liked movies endpoint in v1
    // Fallback to local storage
    final storage = await LocalStorageService.getInstance();
    final ids = await storage.getLikedMovies();
    final List<Movie> movies = [];
    for (final id in ids) {
      final m = await getMovieDetails(int.parse(id));
      if (m != null) movies.add(m);
    }
    return movies;
  }

  @override
  Future<List<Movie>> getWatchHistory() async {
    try {
      final res = await _dio.get('/users/me/history', queryParameters: {
        'page': 1,
        'page_size': 50,
      });
      final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>? ?? [];
      return data.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      final storage = await LocalStorageService.getInstance();
      final ids = await storage.getWatchHistory();
      final List<Movie> movies = [];
      for (final id in ids) {
        final m = await getMovieDetails(int.parse(id));
        if (m != null) movies.add(m);
      }
      return movies;
    }
  }

  @override
  Future<List<Movie>> getWatchlist({int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get('/users/me/watchlist', queryParameters: {
        'page': page,
        'page_size': limit,
      });
      final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>? ?? [];
      return data.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      final storage = await LocalStorageService.getInstance();
      final ids = await storage.getWatchlist();
      final List<Movie> movies = [];
      for (final id in ids) {
        final m = await getMovieDetails(int.parse(id));
        if (m != null) movies.add(m.copyWith(isLiked: true));
      }
      return movies;
    }
  }

  @override
  Future<void> addToWatchlist(int movieId) async {
    try {
      await _dio.post('/users/me/watchlist', data: {'movieId': movieId});
    } catch (_) {}
    final storage = await LocalStorageService.getInstance();
    final list = await storage.getWatchlist();
    if (!list.contains(movieId.toString())) {
      list.add(movieId.toString());
      await storage.saveWatchlist(list);
    }
  }

  @override
  Future<void> removeFromWatchlist(int movieId) async {
    try {
      await _dio.delete('/users/me/watchlist/$movieId');
    } catch (_) {}
    final storage = await LocalStorageService.getInstance();
    final list = await storage.getWatchlist();
    list.remove(movieId.toString());
    await storage.saveWatchlist(list);
  }

  @override
  Future<void> likeMovie(int movieId) async {
    await _dio.post('/interactions/swipe', data: {
      'movieId': movieId,
      'action': 'like',
    });
    final storage = await LocalStorageService.getInstance();
    final liked = await storage.getLikedMovies();
    if (!liked.contains(movieId.toString())) {
      liked.add(movieId.toString());
      await storage.saveLikedMovies(liked);
    }
  }

  @override
  Future<void> dislikeMovie(int movieId) async {
    await _dio.post('/interactions/swipe', data: {
      'movieId': movieId,
      'action': 'dislike',
    });
  }

  @override
  Future<void> superLikeMovie(int movieId) async {
    await _dio.post('/interactions/swipe', data: {
      'movieId': movieId,
      'action': 'super_like',
    });
    final storage = await LocalStorageService.getInstance();
    final liked = await storage.getLikedMovies();
    if (!liked.contains(movieId.toString())) {
      liked.add(movieId.toString());
      await storage.saveLikedMovies(liked);
    }
  }

  @override
  Future<void> undoSwipe(int movieId) async {
    await _dio.post('/interactions/undo');
    final storage = await LocalStorageService.getInstance();
    final liked = await storage.getLikedMovies();
    liked.remove(movieId.toString());
    await storage.saveLikedMovies(liked);
  }

  @override
  Future<void> addToWatchHistory(int movieId) async {
    try {
      await _dio.post('/users/me/history', data: {'movieId': movieId});
    } catch (_) {}
    final storage = await LocalStorageService.getInstance();
    final history = await storage.getWatchHistory();
    if (!history.contains(movieId.toString())) {
      history.add(movieId.toString());
      await storage.saveWatchHistory(history);
    }
  }
}
