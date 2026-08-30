import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/movie_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/error_empty_state.dart';
import '../widgets/swipe_stack.dart';
import '../widgets/swipe_action_buttons.dart';
import '../widgets/mood_input_bar.dart';
import 'movie_details_modal.dart';
import '../../../data/models/movie_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';

// Filtering state
final selectedGenresProvider = StateProvider<Set<String>>((_) => {});
final minRatingFilterProvider = StateProvider<double>((_) => 0);

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});
  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  void _showDetails(Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MovieDetailsModal(movieId: movie.id),
    );
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterSheet(),
    );
  }

  final GlobalKey _swipeStackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(movieStackProvider);
    final top = state.stack.isEmpty ? null : state.stack.last;
    final mood = ref.watch(moodProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'CINRECO',
          style: AppTextStyles.displaySmall.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: const Icon(Icons.tune, color: AppColors.onSurfaceVariant),
          ),
          IconButton(
            tooltip: 'Watch History',
            onPressed: () => context.push(AppConstants.watchHistoryRoute),
            icon: const Icon(Icons.history, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            // Layer 1: Ambient Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.8, -0.6),
                    radius: 1.5,
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Layer 2: Main Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  MoodInputBar(
                    initialValue: mood,
                    onSubmitted: (v) {
                      ref.read(moodProvider.notifier).state = v;
                    },
                  ),

                  // Ambient popular vibe chips scrollable list
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _MoodChip(
                          label: '⚡ Neon Cyberpunk',
                          query: 'neon fast paced cyberpunk action',
                          currentMood: mood,
                          onTap: (q) =>
                              ref.read(moodProvider.notifier).state = q,
                        ),
                        const SizedBox(width: 8),
                        _MoodChip(
                          label: '🌃 Dark Gritty',
                          query: 'dark gritty cerebral thriller detective',
                          currentMood: mood,
                          onTap: (q) =>
                              ref.read(moodProvider.notifier).state = q,
                        ),
                        const SizedBox(width: 8),
                        _MoodChip(
                          label: '🍿 Cozy Feel-Good',
                          query: 'cozy feel good heartwarming comedy',
                          currentMood: mood,
                          onTap: (q) =>
                              ref.read(moodProvider.notifier).state = q,
                        ),
                        const SizedBox(width: 8),
                        _MoodChip(
                          label: '🌌 Mind-Bending',
                          query: 'mind bending space time travel sci-fi',
                          currentMood: mood,
                          onTap: (q) =>
                              ref.read(moodProvider.notifier).state = q,
                        ),
                        const SizedBox(width: 8),
                        _MoodChip(
                          label: '🕯️ Tragic Romance',
                          query: 'romantic tragic romance dramatic love story',
                          currentMood: mood,
                          onTap: (q) =>
                              ref.read(moodProvider.notifier).state = q,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ActiveFiltersBar(onTap: _openFilters),

                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 16,
                        child: ErrorEmptyState.error(
                          message: 'Connection issue: ${state.error}',
                          onRetry: () =>
                              ref.read(movieStackProvider.notifier).loadMore(),
                        ),
                      ),
                    ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: SwipeStack(
                        key: _swipeStackKey,
                        onSwipe: (m, a) {},
                        onTapDetails: _showDetails,
                      ),
                    ),
                  ),

                  // Bottom Actions (Layer 3)
                  if (top != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 12),
                      child: SwipeActionButtons(
                        onAction: (a) {
                          dynamic state = _swipeStackKey.currentState;
                          if (state != null) {
                            state.swipeTop(a);
                          } else {
                            ref.read(movieStackProvider.notifier).swipe(top, a);
                          }
                        },
                      ),
                    ),

                  if (state.canUndo)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextButton.icon(
                        onPressed: () =>
                            ref.read(movieStackProvider.notifier).undo(),
                        icon: const Icon(Icons.undo, size: 16),
                        label: const Text('UNDO last swipe'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                          textStyle: AppTextStyles.labelSmall.copyWith(
                            fontSize: 10,
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

class _ActiveFiltersBar extends ConsumerWidget {
  const _ActiveFiltersBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genres = ref.watch(selectedGenresProvider);
    final minRating = ref.watch(minRatingFilterProvider);

    if (genres.isEmpty && minRating == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              borderRadius: 20,
              opacity: 0.1,
              child: Row(
                children: [
                  const Icon(Icons.tune, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    '${genres.length} genres • ≥ ${minRating.toStringAsFixed(1)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              ref.read(selectedGenresProvider.notifier).state = {};
              ref.read(minRatingFilterProvider.notifier).state = 0;
            },
            child: Text(
              'CLEAR',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedGenresProvider);
    final minRating = ref.watch(minRatingFilterProvider);
    final allGenres = [
      'Action',
      'Adventure',
      'Drama',
      'Romance',
      'Comedy',
      'Science Fiction',
      'Horror',
      'Thriller',
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.tune, size: 20, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text('Filters', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Text('Genres', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allGenres.map((g) {
                final active = selected.contains(g);
                return FilterChip(
                  label: Text(g),
                  selected: active,
                  onSelected: (_) {
                    final set = {...selected};
                    if (active) {
                      set.remove(g);
                    } else {
                      set.add(g);
                    }
                    ref.read(selectedGenresProvider.notifier).state = set;
                  },
                  selectedColor: AppColors.secondaryContainer,
                  labelStyle: TextStyle(
                    color: active
                        ? AppColors.onSecondaryContainer
                        : AppColors.onSurface,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Minimum Rating (${minRating.toStringAsFixed(1)})',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Slider(
              value: minRating,
              min: 0,
              max: 10,
              divisions: 20,
              label: minRating.toStringAsFixed(1),
              activeColor: AppColors.secondary,
              inactiveColor: AppColors.outlineVariant,
              onChanged: (v) =>
                  ref.read(minRatingFilterProvider.notifier).state = v,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check),
                    label: const Text('Apply'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer,
                      foregroundColor: AppColors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String label;
  final String query;
  final String currentMood;
  final ValueChanged<String> onTap;

  const _MoodChip({
    required this.label,
    required this.query,
    required this.currentMood,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentMood == query;
    return GestureDetector(
      onTap: () => onTap(isSelected ? '' : query),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        borderRadius: 20,
        opacity: isSelected ? 0.35 : 0.08,
        border: Border.all(
          color: isSelected ? AppColors.secondary : AppColors.glassBorder,
          width: 1,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.secondary : AppColors.onSurface,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
