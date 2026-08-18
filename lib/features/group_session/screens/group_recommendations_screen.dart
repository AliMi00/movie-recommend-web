import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../discovery/screens/movie_details_modal.dart';
import '../providers/group_session_providers.dart';
import '../../../data/models/movie_model.dart';

class GroupRecommendationsScreen extends ConsumerStatefulWidget {
  final String code;

  const GroupRecommendationsScreen({super.key, required this.code});

  @override
  ConsumerState<GroupRecommendationsScreen> createState() =>
      _GroupRecommendationsScreenState();
}

class _GroupRecommendationsScreenState
    extends ConsumerState<GroupRecommendationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(groupRecommendationsProvider(widget.code).notifier)
          .loadRecommendations();
    }
  }

  void _showMovieDetails(int movieId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MovieDetailsModal(movieId: movieId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupRecommendationsProvider(widget.code));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'CONSENSUS MATCHES',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            // Glowing background ambient layer
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiary.withValues(alpha: 0.03),
                ),
              ),
            ),

            SafeArea(
              child: state.movies.isEmpty && state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                      ),
                    )
                  : state.error != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load group consensus.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(
                                    groupRecommendationsProvider(
                                      widget.code,
                                    ).notifier,
                                  )
                                  .refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.secondary,
                      onRefresh: () => ref
                          .read(
                            groupRecommendationsProvider(widget.code).notifier,
                          )
                          .refresh(),
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: AppColors.tertiary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'LEAST MISERY CONSENSUS',
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                              color: AppColors.tertiary,
                                              letterSpacing: 1.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Sorted to maximize collective agreement and prevent anyone from being disappointed!',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == state.movies.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  );
                                }

                                final groupMovie = state.movies[index];
                                final movie = groupMovie.movie;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _showMovieDetails(movie.id),
                                    child: GlassContainer(
                                      padding: const EdgeInsets.all(14),
                                      borderRadius: 24,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Movie Poster (Premium design)
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      movie.fullPosterPath,
                                                  width: 84,
                                                  height: 126,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        color: AppColors
                                                            .surfaceContainerHigh,
                                                        child: const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: AppColors
                                                                    .secondary,
                                                              ),
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Container(
                                                        color: AppColors
                                                            .surfaceContainerHigh,
                                                        child: const Icon(
                                                          Icons.movie_rounded,
                                                          color:
                                                              AppColors.outline,
                                                        ),
                                                      ),
                                                ),
                                              ).animate().scale(
                                                duration: 250.ms,
                                              ),
                                              const SizedBox(width: 16),

                                              // Details Column
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            movie.title,
                                                            style: AppTextStyles
                                                                .movieSubtitle
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 17,
                                                                ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: AppColors
                                                                .secondary
                                                                .withValues(
                                                                  alpha: 0.12,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                            border: Border.all(
                                                              color: AppColors
                                                                  .secondary
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Rank #${index + 1}',
                                                            style: AppTextStyles
                                                                .labelSmall
                                                                .copyWith(
                                                                  color: AppColors
                                                                      .secondary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 10,
                                                                  letterSpacing:
                                                                      0,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      '${movie.releaseYear} • ${movie.formattedRuntime} • ★ ${movie.formattedRating}',
                                                      style: AppTextStyles
                                                          .bodySmall
                                                          .copyWith(
                                                            color: AppColors
                                                                .onSurfaceVariant
                                                                .withValues(
                                                                  alpha: 0.8,
                                                                ),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Wrap(
                                                      spacing: 6,
                                                      children: movie.genres.take(2).map((
                                                        genre,
                                                      ) {
                                                        return Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 3,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: AppColors
                                                                .surfaceContainerHigh,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                            border: Border.all(
                                                              color: AppColors
                                                                  .glassBorder,
                                                              width: 0.5,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            genre,
                                                            style: AppTextStyles
                                                                .labelSmall
                                                                .copyWith(
                                                                  fontSize: 9,
                                                                  color: AppColors
                                                                      .onSurfaceVariant,
                                                                ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),

                                          // Consensus Score meter
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors
                                                  .surfaceContainerHigh
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: AppColors.glassBorder,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Group Agreement',
                                                      style: AppTextStyles
                                                          .labelSmall
                                                          .copyWith(
                                                            fontSize: 11,
                                                            color: AppColors
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                    Text(
                                                      '${(groupMovie.groupScore * 100).toStringAsFixed(0)}% Synergized',
                                                      style: AppTextStyles
                                                          .labelSmall
                                                          .copyWith(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color: AppColors
                                                                .secondary,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: LinearProgressIndicator(
                                                    value:
                                                        groupMovie.groupScore,
                                                    backgroundColor:
                                                        AppColors.background,
                                                    valueColor:
                                                        const AlwaysStoppedAnimation(
                                                          AppColors.secondary,
                                                        ),
                                                    minHeight: 6,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),

                                                // Individual Scores
                                                Column(
                                                  children: groupMovie.userScores.entries.map((
                                                    entry,
                                                  ) {
                                                    final email = entry.key;
                                                    final score = entry.value;

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 4,
                                                          ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              email,
                                                              style: AppTextStyles
                                                                  .bodySmall
                                                                  .copyWith(
                                                                    fontSize:
                                                                        11,
                                                                    color: AppColors
                                                                        .onSurfaceVariant
                                                                        .withValues(
                                                                          alpha:
                                                                              0.8,
                                                                        ),
                                                                  ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${(score * 100).toStringAsFixed(0)}%',
                                                            style: AppTextStyles
                                                                .bodySmall
                                                                .copyWith(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColors
                                                                      .onSurface,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // AI explanation synergy reason
                                          if (groupMovie
                                              .groupReason
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppColors.tertiary
                                                    .withValues(alpha: 0.04),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: AppColors.tertiary
                                                      .withValues(alpha: 0.15),
                                                ),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 2,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .auto_awesome_rounded,
                                                      color: AppColors.tertiary,
                                                      size: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      groupMovie.groupReason,
                                                      style: AppTextStyles
                                                          .bodySmall
                                                          .copyWith(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .onSurface
                                                                .withValues(
                                                                  alpha: 0.9,
                                                                ),
                                                            height: 1.4,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount:
                                  state.movies.length + (state.hasMore ? 1 : 0),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 32)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
