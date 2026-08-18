import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/error_empty_state.dart';
import '../../../data/models/movie_model.dart';
import '../../../shared/providers/movie_providers.dart'
    show movieRepositoryProvider;
import 'movie_details_modal.dart';

/// Provider to manage the current mood query
final moodSearchQueryProvider = StateProvider<String>((ref) => '');

/// FutureProvider that fetches recommendations based on the active mood query
final moodSearchResultsProvider = FutureProvider<List<Movie>>((ref) async {
  final query = ref.watch(moodSearchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repository = ref.watch(movieRepositoryProvider);
  return repository.getRecommendations(page: 1, limit: 15, mood: query);
});

class MoodSearchScreen extends ConsumerStatefulWidget {
  const MoodSearchScreen({super.key});

  @override
  ConsumerState<MoodSearchScreen> createState() => _MoodSearchScreenState();
}

class _MoodSearchScreenState extends ConsumerState<MoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  final List<Map<String, String>> _suggestedMoods = const [
    {
      'label': 'Neon & fast-paced ⚡',
      'query': 'neon fast paced cyberpunk action',
    },
    {
      'label': 'Dark, gritty & cerebral 🌃',
      'query': 'dark gritty cerebral thriller detective',
    },
    {
      'label': 'Cozy & feel-good 🍿',
      'query': 'cozy feel good heartwarming comedy',
    },
    {
      'label': 'Mind-bending sci-fi 🌌',
      'query': 'mind bending space time travel sci-fi',
    },
    {
      'label': 'Romantic with a twist 🕯️',
      'query': 'romantic tragic romance dramatic love story',
    },
    {
      'label': 'High-octane adrenaline 🏎️',
      'query': 'high octane adrenaline action explosion speed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitMood(String mood) {
    _searchController.text = mood;
    ref.read(moodSearchQueryProvider.notifier).state = mood;
    _focusNode.unfocus();
  }

  void _showMovieDetails(Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MovieDetailsModal(movieId: movie.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(moodSearchQueryProvider);
    final resultsAsync = ref.watch(moodSearchResultsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            // Ambient Radial Glow for High-Fidelity atmosphere
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiary.withValues(alpha: 0.04),
                ),
              ),
            ),

            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Conversational UI Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                                'Mood Explorer',
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
                          const SizedBox(height: 6),
                          Text(
                            'Type how you feel, or select a vibe below to discover tailored movies.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                        ],
                      ),
                    ),
                  ),

                  // Search Field with Glow effect
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child:
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow.withValues(
                                alpha: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isFocused
                                    ? AppColors.secondary
                                    : AppColors.glassBorder,
                                width: _isFocused ? 1.5 : 1,
                              ),
                              boxShadow: _isFocused
                                  ? [
                                      BoxShadow(
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                onSubmitted: _submitMood,
                                textInputAction: TextInputAction.search,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.onSurface,
                                ),
                                cursorColor: AppColors.secondary,
                                decoration: InputDecoration(
                                  hintText: 'How are you feeling tonight?',
                                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.auto_awesome,
                                    color: _isFocused
                                        ? AppColors.secondary
                                        : AppColors.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            ref
                                                    .read(
                                                      moodSearchQueryProvider
                                                          .notifier,
                                                    )
                                                    .state =
                                                '';
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ).animate().scale(
                            delay: 150.ms,
                            duration: 300.ms,
                            curve: Curves.easeOut,
                          ),
                    ),
                  ),

                  // Mood suggestions horizontal scroll
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Text(
                            'POPULAR VIBES',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 52,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _suggestedMoods.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final item = _suggestedMoods[index];
                              final isSelected = query == item['query'];
                              return GestureDetector(
                                onTap: () => _submitMood(item['query']!),
                                child: GlassContainer(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  borderRadius: 24,
                                  opacity: isSelected ? 0.35 : 0.08,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.secondary
                                        : AppColors.glassBorder,
                                    width: 1,
                                  ),
                                  child: Center(
                                    child: Text(
                                      item['label']!,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: isSelected
                                            ? AppColors.secondary
                                            : AppColors.onSurface,
                                        fontSize: 12,
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
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Results Grid/State Section
                  query.isEmpty
                      ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bubble_chart_outlined,
                                  size: 72,
                                  color: AppColors.outlineVariant,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Ready to explore?',
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try typing "mind bending mystery" or choose a vibe above!',
                                  style: TextStyle(
                                    color: AppColors.outline,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : resultsAsync.when(
                          data: (movies) {
                            if (movies.isEmpty) {
                              return const SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.movie_creation_outlined,
                                        size: 64,
                                        color: AppColors.outlineVariant,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No matches found',
                                        style: TextStyle(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your description or pick a different mood.',
                                        style: TextStyle(
                                          color: AppColors.outline,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                100,
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: 0.65,
                                    ),
                                delegate: SliverChildBuilderDelegate((
                                  ctx,
                                  index,
                                ) {
                                  final movie = movies[index];
                                  return _MoodResultTile(
                                    movie: movie,
                                    onTap: () => _showMovieDetails(movie),
                                  ).animate().fadeIn(
                                    delay: (index * 50).ms,
                                    duration: 350.ms,
                                  );
                                }, childCount: movies.length),
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
                                message: 'Search failed: $e',
                                onRetry: () =>
                                    ref.refresh(moodSearchResultsProvider),
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

class _MoodResultTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _MoodResultTile({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Generate a random match score between 88% and 99% based on movie id for consistency
    final int matchScore = 85 + (movie.id % 15);
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
                // Gradient Overlay
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
                  right: 8,
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
              movie.genresString,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
