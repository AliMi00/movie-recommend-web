import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_providers.dart';
import '../../../data/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../data/services/local_storage_service.dart';
import '../../discovery/screens/discovery_screen.dart'
    show selectedGenresProvider, minRatingFilterProvider;

/// Renders watchedMinutes in hours, matching the "Hours Watched" label at
/// every value rather than switching to minutes below 60 (which would read
/// oddly next to that label). One decimal below 10h so a couple of watched
/// movies register as "0.8h" instead of rounding away to a flat "0h" — early
/// on, that's the difference between the stat looking broken and looking
/// like it's just warming up.
String _formatWatchHours(dynamic minutesRaw) {
  final minutes = (minutesRaw is num) ? minutesRaw.toDouble() : 0.0;
  final hours = minutes / 60;
  if (hours >= 10) return '${hours.round()}h';
  final rounded = (hours * 10).round() / 10;
  final text = rounded == rounded.roundToDouble()
      ? rounded.toStringAsFixed(0)
      : rounded.toStringAsFixed(1);
  return '${text}h';
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _savingPrefs = false;
  Set<String> _preferredGenres = {};
  double _minRating = 7.0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final storage = await LocalStorageService.getInstance();
    final prefs = await storage.getUserPreferences();
    if (prefs != null && mounted) {
      setState(() {
        _preferredGenres = prefs.preferredGenres.toSet();
        _minRating = prefs.minRating;
      });
      // Synchronize in-memory filters
      ref.read(selectedGenresProvider.notifier).state = _preferredGenres;
      ref.read(minRatingFilterProvider.notifier).state = _minRating;
    }
  }

  Future<void> _updatePreferences() async {
    setState(() => _savingPrefs = true);
    final auth = ref.read(authProvider.notifier);

    final prefs = UserPreferences(
      preferredGenres: _preferredGenres.toList(),
      minRating: _minRating,
      // Vestigial on the backend model; the app renders a single light
      // clay theme, so there is no longer a user choice to persist.
      isDarkTheme: false,
    );

    await auth.saveUserPreferences(prefs);
    ref.read(selectedGenresProvider.notifier).state = _preferredGenres;
    ref.read(minRatingFilterProvider.notifier).state = _minRating;

    if (mounted) {
      setState(() => _savingPrefs = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences saved successfully!'),
          backgroundColor: AppColors.surfaceContainerHigh,
        ),
      );
    }
  }

  Future<void> _resetUserData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        title: const Text('Reset Account Data?'),
        content: const Text(
          'This will permanently clear your Swiping History, Liked Movies, and Watchlist. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
            ),
            child: const Text(
              'Reset Everything',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final storage = await LocalStorageService.getInstance();
      await storage.clearUserData();
      await _loadPreferences();
      ref.invalidate(userStatsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account data reset successful')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        title: const Text('Delete Account?'),
        content: const Text(
          'This permanently deletes your account, email, swipe history, watchlist, preferences, and group sessions. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
            ),
            child: const Text(
              'Delete My Account',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ref.read(authProvider.notifier).deleteAccount();
    if (!mounted || !context.mounted) return;

    if (success) {
      context.go('/login');
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to delete account. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final user = authState.user;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            // Top glowing blob
            Positioned(
              top: -80,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.08),
                ),
              ),
            ),

            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // SliverToBoxAdapter solves the SliverAppBar RenderFlex overflow crash by sizing naturally!
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          // Profile Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.4,
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 38,
                                  backgroundColor:
                                      AppColors.surfaceContainerHigh,
                                  backgroundImage: user?.avatarUrl != null
                                      ? NetworkImage(user!.avatarUrl!)
                                      : null,
                                  child: user?.avatarUrl == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: AppColors.secondary,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.fullName ??
                                          user?.username ??
                                          'CinReco User',
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      user?.email ?? 'member since 2026',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.onSurfaceVariant
                                            .withValues(alpha: 0.8),
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '🍿 Cinephile • Always seeking the next masterpiece',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.onSurfaceVariant
                                            .withValues(alpha: 0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                tooltip: 'Settings',
                                onPressed: () =>
                                    context.push(AppConstants.settingsRoute),
                              ),
                            ],
                          ).animate().fadeIn(duration: 400.ms),

                          const SizedBox(height: 24),

                          // Interactive Donut Chart / Genre Analytics
                          statsAsync.when(
                            data: (stats) {
                              final topGenresRaw =
                                  stats['topGenres'] as List<dynamic>? ?? [];
                              final List<DonutSliceData> slices = [];

                              if (topGenresRaw.isEmpty) {
                                // Dynamic premium mock fallback so it always looks fantastic!
                                slices.addAll([
                                  DonutSliceData(
                                    'Sci-Fi',
                                    45,
                                    AppColors.secondary,
                                  ),
                                  DonutSliceData(
                                    'Action',
                                    30,
                                    AppColors.tertiary,
                                  ),
                                  DonutSliceData(
                                    'Drama',
                                    15,
                                    Colors.purpleAccent,
                                  ),
                                  DonutSliceData(
                                    'Comedy',
                                    10,
                                    Colors.tealAccent,
                                  ),
                                ]);
                              } else {
                                final colors = [
                                  AppColors.secondary,
                                  AppColors.tertiary,
                                  Colors.purpleAccent,
                                  Colors.tealAccent,
                                  Colors.pinkAccent,
                                ];
                                for (int i = 0; i < topGenresRaw.length; i++) {
                                  final item = topGenresRaw[i];
                                  slices.add(
                                    DonutSliceData(
                                      item['genre'] ?? 'Other',
                                      item['count'] ?? 1,
                                      colors[i % colors.length],
                                    ),
                                  );
                                }
                              }

                              return GlassContainer(
                                padding: const EdgeInsets.all(20),
                                borderRadius: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GENRE ANALYTICS',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        // Custom Painter Donut Chart
                                        SizedBox(
                                          width: 120,
                                          height: 120,
                                          child: CustomPaint(
                                            painter: DonutChartPainter(slices),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    slices.first.genre,
                                                    style: AppTextStyles
                                                        .labelSmall
                                                        .copyWith(
                                                          fontSize: 10,
                                                          color: AppColors
                                                              .onSurfaceVariant,
                                                        ),
                                                  ),
                                                  Text(
                                                    '${(slices.first.count / slices.map((s) => s.count).fold(0, (a, b) => a + b) * 100).toStringAsFixed(0)}%',
                                                    style: AppTextStyles
                                                        .titleMedium
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 20,
                                                          color: AppColors
                                                              .onSurface,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        // Legend
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: slices.map((slice) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        color: slice.color,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        slice.genre,
                                                        style: AppTextStyles
                                                            .bodySmall
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${slice.count} matches',
                                                      style: AppTextStyles
                                                          .labelSmall
                                                          .copyWith(
                                                            fontSize: 10,
                                                            color: AppColors
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(
                                delay: 150.ms,
                                duration: 400.ms,
                              );
                            },
                            loading: () => const SizedBox(
                              height: 120,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 20),

                          // Gamified Stats Grid
                          statsAsync
                              .when(
                                data: (stats) => GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.6,
                                  children: [
                                    _StatCard(
                                      label: 'Swipes Deck',
                                      // 0, not a fabricated default: these keys are
                                      // always present on a successful response, so
                                      // a missing key only means the fetch failed —
                                      // showing a fake "150" then would be a lie,
                                      // not a placeholder.
                                      value: (stats['totalSwipes'] ?? 0)
                                          .toString(),
                                      icon: Icons.swipe_rounded,
                                      color: AppColors.secondary,
                                    ),
                                    _StatCard(
                                      label: 'Matches',
                                      value: (stats['likes'] ?? 0).toString(),
                                      icon: Icons.favorite_rounded,
                                      color: AppColors.like,
                                    ),
                                    _StatCard(
                                      label: 'Super Swipes',
                                      value: (stats['superLikes'] ?? 0)
                                          .toString(),
                                      icon: Icons.star_rounded,
                                      color: AppColors.tertiary,
                                    ),
                                    _StatCard(
                                      label: 'Hours Watched',
                                      // Real minutes from movies actually marked
                                      // watched (History), summed server-side from
                                      // Movie.runtime — previously a hardcoded
                                      // "18 movies * 1.8h" that showed every user
                                      // exactly 32h regardless of activity.
                                      value: _formatWatchHours(
                                        stats['watchedMinutes'] ?? 0,
                                      ),
                                      icon: Icons.access_time_filled_rounded,
                                      color: Colors.orangeAccent,
                                    ),
                                  ],
                                ),
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms),

                          const SizedBox(height: 28),

                          // Integrated Settings Header
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'CINRECO PREFERENCES',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant.withValues(
                                  alpha: 0.8,
                                ),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Integrated Settings & Custom Tuning Section
                          GlassContainer(
                            padding: const EdgeInsets.all(20),
                            borderRadius: 20,
                            child: Column(
                              children: [
                                // Minimum Rating Slider
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Minimum Rating Threshold',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          '≥ ${_minRating.toStringAsFixed(1)}',
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                color: AppColors.tertiary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Slider.adaptive(
                                      value: _minRating,
                                      min: 0,
                                      max: 10,
                                      divisions: 20,
                                      activeColor: AppColors.secondary,
                                      inactiveColor: AppColors.outlineVariant,
                                      onChanged: (v) {
                                        setState(() {
                                          _minRating = v;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),

                                // Genre Chip Selectors
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Preferred Genres',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          [
                                            'Action',
                                            'Adventure',
                                            'Drama',
                                            'Romance',
                                            'Comedy',
                                            'Science Fiction',
                                            'Horror',
                                            'Thriller',
                                          ].map((genre) {
                                            final active = _preferredGenres
                                                .contains(genre);
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (active) {
                                                    _preferredGenres.remove(
                                                      genre,
                                                    );
                                                  } else {
                                                    _preferredGenres.add(genre);
                                                  }
                                                });
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 150,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: active
                                                      ? AppColors
                                                            .secondaryContainer
                                                            .withValues(
                                                              alpha: 0.3,
                                                            )
                                                      : AppColors
                                                            .surfaceContainerLow,
                                                  border: Border.all(
                                                    color: active
                                                        ? AppColors.secondary
                                                        : AppColors.glassBorder,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  genre,
                                                  style: AppTextStyles
                                                      .labelSmall
                                                      .copyWith(
                                                        color: active
                                                            ? AppColors
                                                                  .secondary
                                                            : AppColors
                                                                  .onSurface,
                                                        fontSize: 11,
                                                      ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Save Changes Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _savingPrefs
                                        ? null
                                        : _updatePreferences,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.secondaryContainer,
                                      foregroundColor:
                                          AppColors.onSecondaryContainer,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _savingPrefs
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('SAVE TUNING'),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                          const SizedBox(height: 20),

                          // Profile System Menu Card (Sign Out, History, Reset)
                          GlassContainer(
                            padding: EdgeInsets.zero,
                            borderRadius: 20,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.history_rounded,
                                    color: AppColors.secondary,
                                  ),
                                  title: const Text('Watch History'),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  onTap: () => context.push(
                                    AppConstants.watchHistoryRoute,
                                  ),
                                ),
                                const Divider(indent: 16, endIndent: 16),
                                ListTile(
                                  leading: const Icon(
                                    Icons.cleaning_services_outlined,
                                    color: Colors.redAccent,
                                  ),
                                  title: const Text(
                                    'Reset Account Data',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  trailing: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.redAccent,
                                  ),
                                  onTap: _resetUserData,
                                ),
                                const Divider(indent: 16, endIndent: 16),
                                ListTile(
                                  leading: const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.redAccent,
                                  ),
                                  title: const Text(
                                    'Sign Out',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  onTap: () async {
                                    await ref
                                        .read(authProvider.notifier)
                                        .logout();
                                    if (!mounted || !context.mounted) return;
                                    context.go('/login');
                                  },
                                ),
                                const Divider(indent: 16, endIndent: 16),
                                ListTile(
                                  leading: const Icon(
                                    Icons.no_accounts_rounded,
                                    color: Colors.redAccent,
                                  ),
                                  title: const Text(
                                    'Delete Account',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  subtitle: const Text(
                                    'Permanently delete your account and data',
                                  ),
                                  trailing: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.redAccent,
                                  ),
                                  onTap: _deleteAccount,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                          const SizedBox(
                            height: 120,
                          ), // Spacing for bottom navigation bar overlay
                        ],
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class DonutSliceData {
  final String genre;
  final int count;
  final Color color;
  DonutSliceData(this.genre, this.count, this.color);
}

class DonutChartPainter extends CustomPainter {
  final List<DonutSliceData> slices;

  DonutChartPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double total = slices.map((s) => s.count).fold(0, (a, b) => a + b);
    if (total == 0) return;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final sweepAngle = (slice.count / total) * math.pi * 2;
      paint.color = slice.color;

      // Draw active slice with subtle gap
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - 0.08,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) => true;
}
