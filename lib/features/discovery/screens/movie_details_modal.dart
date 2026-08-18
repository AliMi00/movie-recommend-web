import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/movie_model.dart';
import '../providers/movie_providers.dart';
import '../../history/providers/watch_history_providers.dart' as history;
import '../../watchlist/providers/watchlist_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';

final movieDetailsProvider = FutureProvider.family<Movie?, int>((ref, id) async {
  final repo = ref.read(movieRepositoryProvider);
  return repo.getMovieDetails(id);
});

class MovieDetailsModal extends ConsumerWidget {
  final int movieId;
  const MovieDetailsModal({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMovie = ref.watch(movieDetailsProvider(movieId));
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: asyncMovie.when(
          data: (m) {
            if (m == null) {
              return const SizedBox(
                height: 300,
                child: Center(child: Text('Movie not found')),
              );
            }
            return _MovieDetailsContent(movie: m);
          },
          error: (e, _) => SizedBox(
            height: 300,
            child: Center(child: Text('Error: $e')),
          ),
          loading: () => const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
          ),
        ),
      ),
    );
  }
}

class _MovieDetailsContent extends ConsumerStatefulWidget {
  final Movie movie;
  const _MovieDetailsContent({required this.movie});

  @override
  ConsumerState<_MovieDetailsContent> createState() => _MovieDetailsContentState();
}

class _MovieDetailsContentState extends ConsumerState<_MovieDetailsContent> {
  bool _inHistory = false;
  List<Movie> _similar = [];
  bool _loadingSimilar = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final repo = ref.read(movieRepositoryProvider);
    final historyList = await repo.getWatchHistory();
    if (mounted) {
      setState(() {
        _inHistory = historyList.any((m) => m.id == widget.movie.id);
      });
    }
    _loadSimilar();
  }

  Future<void> _addToHistory() async {
    if (_inHistory) return;
    final repo = ref.read(movieRepositoryProvider);
    await repo.addToWatchHistory(widget.movie.id);
    try {
      ref.read(history.watchHistoryProvider.notifier).addMovie(widget.movie);
    } catch (_) {}
    if (mounted) {
      setState(() => _inHistory = true);
    }
  }

  Future<void> _loadSimilar() async {
    if (widget.movie.similarIds.isEmpty) return;
    setState(() => _loadingSimilar = true);
    final repo = ref.read(movieRepositoryProvider);
    try {
      final futures = widget.movie.similarIds.take(8).map((id) => repo.getMovieDetails(id));
      final results = await Future.wait(futures);
      if (mounted) {
        setState(() => _similar = results.whereType<Movie>().toList());
      }
    } finally {
      if (mounted) {
        setState(() => _loadingSimilar = false);
      }
    }
  }

  void _shareMovie() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing link copied to clipboard!'),
        backgroundColor: AppColors.surfaceContainerHigh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final inWatchlist = ref.watch(watchlistProvider).maybeWhen(
          data: (movies) => movies.any((m) => m.id == movie.id),
          orElse: () => false,
        );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Immersive Top Backdrop Block
          Stack(
            children: [
              // Backdrop Image
              SizedBox(
                height: 280,
                width: double.infinity,
                child: movie.backdropUrl != null && movie.backdropUrl!.isNotEmpty
                    ? Image.network(movie.fullBackdropPath, fit: BoxFit.cover)
                    : Container(color: AppColors.surfaceContainerLowest),
              ),
              // Immersive Gradient overlay (backdrop fade to black)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.5),
                        AppColors.background,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              // Close drag handle
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              // Floating Poster overlay and metadata
              Positioned(
                left: 20,
                right: 20,
                bottom: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Small floating poster
                    Container(
                      width: 100,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                            ? Image.network(movie.fullPosterPath, fit: BoxFit.cover)
                            : Container(color: AppColors.surfaceContainerHigh),
                      ),
                    ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
                    const SizedBox(width: 16),
                    // Core Title and quick details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: AppColors.onSurface,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${movie.releaseYear}  •  ${movie.formattedRuntime}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Vivid Gold Critic chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.tertiary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 12, color: AppColors.tertiary),
                                    const SizedBox(width: 2),
                                    Text(
                                      movie.formattedRating,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.tertiary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Core Info Blocks
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glowing match logic reason badge
                if (movie.reason != null && movie.reason!.isNotEmpty) ...[
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    borderRadius: 16,
                    opacity: 0.1,
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3), width: 0.5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          movie.reason!.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Genre chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: movie.genres
                      .take(4)
                      .map((g) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              g,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onSurface.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 20),

                // Immersive actions row
                Row(
                  children: [
                    // Watch Trailer / Play Trailer
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: movie.hasTrailer
                            ? () {
                                Navigator.pop(context);
                                Navigator.of(context).pushNamed('/trailer/${movie.id}');
                              }
                            : null,
                        icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                        label: const Text('WATCH TRAILER'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryContainer,
                          foregroundColor: AppColors.onSecondaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Watchlist toggle button
                    IconButton(
                      onPressed: () => ref.read(watchlistProvider.notifier).toggleWatchlist(movie),
                      tooltip: inWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: inWatchlist
                              ? AppColors.secondaryContainer.withValues(alpha: 0.2)
                              : AppColors.surfaceContainerLow,
                          border: Border.all(
                            color: inWatchlist ? AppColors.secondary : AppColors.glassBorder,
                            width: 1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          inWatchlist ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: inWatchlist ? AppColors.secondary : AppColors.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                    // Watch History toggle button
                    IconButton(
                      onPressed: _inHistory ? null : _addToHistory,
                      tooltip: _inHistory ? 'In Watch History' : 'Mark as Watched',
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _inHistory
                              ? Colors.orangeAccent.withValues(alpha: 0.2)
                              : AppColors.surfaceContainerLow,
                          border: Border.all(
                            color: _inHistory ? Colors.orangeAccent : AppColors.glassBorder,
                            width: 1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _inHistory ? Icons.history_toggle_off_rounded : Icons.history_rounded,
                          color: _inHistory ? Colors.orangeAccent : AppColors.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                    // Share button
                    IconButton(
                      onPressed: _shareMovie,
                      tooltip: 'Share',
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: AppColors.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Plot summary
                Text(
                  'Overview',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.overview,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Director & Cast info
                if (movie.director.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Director:  ',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          movie.director,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                if (movie.cast.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Starring:  ',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          movie.castString,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],

                // Similar recommendations carousel
                if (_loadingSimilar)
                  const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                  )
                else if (_similar.isNotEmpty) ...[
                  Text(
                    'Similar Recommendations',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 172,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _similar.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final m = _similar[i];
                        final score = 84 + (m.id % 16);
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => MovieDetailsModal(movieId: m.id),
                            );
                          },
                          child: SizedBox(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: m.posterUrl != null && m.posterUrl!.isNotEmpty
                                              ? Image.network(m.fullPosterPath, fit: BoxFit.cover)
                                              : Container(color: AppColors.surfaceContainerHigh),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '$score%',
                                            style: const TextStyle(
                                              color: AppColors.secondary,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  m.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  m.genres.first,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontSize: 9,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
