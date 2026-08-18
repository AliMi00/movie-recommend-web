import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/watchlist_providers.dart';
import '../../discovery/screens/movie_details_modal.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/error_empty_state.dart';
import '../../../data/models/movie_model.dart';
import '../../../shared/providers/movie_providers.dart'
    show movieRepositoryProvider;

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = const [
    'All',
    'Sci-Fi',
    'Action',
    'Drama',
    'Romance',
    'Comedy',
  ];

  void _showMovieDetails(Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MovieDetailsModal(movieId: movie.id),
    ).then((_) {
      // Refresh list to capture modifications
      ref.read(watchlistProvider.notifier).loadWatchlist();
    });
  }

  void _removeFromWatchlist(int movieId) {
    ref.read(watchlistProvider.notifier).removeFromWatchlist(movieId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from Watchlist'),
        backgroundColor: AppColors.surfaceContainerLow,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.secondary,
          onPressed: () async {
            // Fetch movie to put back
            final repo = ref.read(movieRepositoryProvider);
            final m = await repo.getMovieDetails(movieId);
            if (m != null) {
              ref.read(watchlistProvider.notifier).addToWatchlist(m);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final watchlistAsync = ref.watch(watchlistProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            // Ambient glow
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.06),
                ),
              ),
            ),

            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App Bar / Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                    'My Watchlist',
                                    style: AppTextStyles.displaySmall.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
                                      letterSpacing: -0.5,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .slideX(begin: -0.1),
                              Text(
                                'Your private screening room collection.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ).animate().fadeIn(
                                delay: 100.ms,
                                duration: 400.ms,
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onPressed: () => ref
                                .read(watchlistProvider.notifier)
                                .loadWatchlist(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar inside watchlist
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: GlassContainer(
                        padding: EdgeInsets.zero,
                        borderRadius: 16,
                        opacity: 0.08,
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurface,
                          ),
                          cursorColor: AppColors.secondary,
                          decoration: InputDecoration(
                            hintText: 'Search within your watchlist...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Categories / Vibe tabs
                  SliverToBoxAdapter(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                            child: GlassContainer(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              borderRadius: 20,
                              opacity: isSelected ? 0.3 : 0.05,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.secondary
                                    : AppColors.glassBorder,
                                width: 1,
                              ),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isSelected
                                        ? AppColors.secondary
                                        : AppColors.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Watchlist Content (Grid of movie cards)
                  watchlistAsync.when(
                    data: (movies) {
                      // Filter by genre
                      var filteredMovies = movies.where((m) {
                        if (_selectedCategory == 'All') return true;
                        // Map shorthand categories
                        final catName = _selectedCategory == 'Sci-Fi'
                            ? 'science fiction'
                            : _selectedCategory.toLowerCase();
                        return m.genres.any((g) => g.toLowerCase() == catName);
                      }).toList();

                      // Filter by query
                      if (_searchQuery.trim().isNotEmpty) {
                        final q = _searchQuery.toLowerCase();
                        filteredMovies = filteredMovies
                            .where((m) => m.title.toLowerCase().contains(q))
                            .toList();
                      }

                      if (filteredMovies.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.bookmark_outline_rounded,
                                    size: 72,
                                    color: AppColors.outlineVariant,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isEmpty &&
                                            _selectedCategory == 'All'
                                        ? 'Your Watchlist is empty'
                                        : 'No movies match your filters',
                                    style: const TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _searchQuery.isEmpty &&
                                            _selectedCategory == 'All'
                                        ? 'Swipe right on Discover to save movies you want to watch!'
                                        : 'Try changing categories or search query.',
                                    style: const TextStyle(
                                      color: AppColors.outline,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.65,
                              ),
                          delegate: SliverChildBuilderDelegate((ctx, index) {
                            final movie = filteredMovies[index];
                            return _WatchlistGridTile(
                              movie: movie,
                              onTap: () => _showMovieDetails(movie),
                              onRemove: () => _removeFromWatchlist(movie.id),
                            ).animate().fadeIn(
                              delay: (index * 60).ms,
                              duration: 300.ms,
                            );
                          }, childCount: filteredMovies.length),
                        ),
                      );
                    },
                    loading: () => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    error: (e, _) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: ErrorEmptyState.error(
                          message: 'Error: $e',
                          onRetry: () => ref
                              .read(watchlistProvider.notifier)
                              .loadWatchlist(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistGridTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _WatchlistGridTile({
    required this.movie,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final matchScore = 86 + (movie.id % 14);
    final fallback = Container(color: AppColors.surfaceContainerHigh);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                        ? Image.network(
                            movie.fullPosterPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => fallback,
                          )
                        : fallback,
                  ),
                ),
                // Black bottom gradient for details readibility
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ),
                // Glowing Match Score Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    borderRadius: 12,
                    opacity: 0.25,
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                    child: Text(
                      '$matchScore% Match',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Delete button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white12, width: 0.5),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.onMedia,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              '${movie.releaseYear} • ${movie.formattedRuntime}',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
