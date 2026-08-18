import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/genre_chip.dart';

/// PostHog feature flag key driving the onboarding A/B test between the
/// full form (control) and a genres-only flow (streamlined). See the
/// "Streamlined onboarding (genres-only) vs full preferences form"
/// experiment in the cinejo PostHog project.
const String _onboardingFlagKey = 'onboarding-variant';
const String _onboardingControlVariant = 'control';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  String _variant = _onboardingControlVariant;
  final List<String> _availableGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Biography',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Sport',
    'Thriller',
    'War',
    'Western',
  ];

  final Set<String> _selectedGenres = {};
  double _minRating = 6.0;

  bool get _isStreamlined => _variant != _onboardingControlVariant;

  @override
  void initState() {
    super.initState();
    _resolveVariant();
  }

  Future<void> _resolveVariant() async {
    final variant = await AnalyticsService.getFeatureFlagVariant(
      _onboardingFlagKey,
      defaultValue: _onboardingControlVariant,
    );
    AnalyticsService.trackEvent(
      'onboarding_started',
      properties: {'variant': variant},
    );
    if (mounted) {
      setState(() => _variant = variant);
    }
  }

  Future<void> _handleSavePreferences() async {
    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one genre')),
      );
      return;
    }

    if (_selectedGenres.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least 3 genres for better recommendations',
          ),
        ),
      );
      return;
    }

    final preferences = UserPreferences(
      preferredGenres: _selectedGenres.toList(),
      minRating: _minRating,
      // Single light clay theme — no user choice to persist.
      isDarkTheme: false,
    );

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.saveUserPreferences(preferences);

    if (success) {
      AnalyticsService.trackEvent(
        'onboarding_completed',
        properties: {
          'variant': _variant,
          'genreCount': _selectedGenres.length,
          'skipped': false,
        },
      );
    }

    if (success && mounted) {
      context.go('/home');
    }
  }

  void _handleSkip() {
    AnalyticsService.trackEvent(
      'onboarding_skipped',
      properties: {'variant': _variant},
    );
    // Save default preferences and continue
    final defaultPreferences = UserPreferences(
      preferredGenres: ['Action', 'Comedy', 'Drama'],
      minRating: 5.0,
      isDarkTheme: true,
    );

    ref
        .read(authProvider.notifier)
        .saveUserPreferences(defaultPreferences)
        .then((success) {
          if (success && mounted) {
            context.go('/home');
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Setup Your Profile',
          style: AppTextStyles.titleLarge.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: authState.isLoading ? null : _handleSkip,
            child: Text(
              'Skip',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: 0.8, // 80% complete after this step
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),

              const SizedBox(height: 32),

              // Welcome text
              Text(
                'Almost there! 🎬',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Help us personalize your movie recommendations by selecting your preferences.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 40),

              // Genre selection
              Text(
                'What genres do you love?',
                style: AppTextStyles.titleLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Select at least 3 genres (${_selectedGenres.length} selected)',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),

              // Genre chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableGenres.map((genre) {
                  final isSelected = _selectedGenres.contains(genre);
                  return GenreChip(
                    genre: genre,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedGenres.remove(genre);
                        } else {
                          _selectedGenres.add(genre);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Minimum rating and theme are skipped in the "streamlined"
              // onboarding A/B test variant — sensible defaults (6.0, dark)
              // are used instead. See _onboardingFlagKey.
              if (!_isStreamlined) ...[
                // Minimum rating
                Text(
                  'Minimum Rating',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Only show movies with ratings above ${_minRating.toStringAsFixed(1)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    thumbColor: AppColors.primary,
                    inactiveTrackColor:
                        theme.colorScheme.surfaceContainerHighest,
                    overlayColor: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _minRating,
                    min: 0.0,
                    max: 10.0,
                    divisions: 20,
                    onChanged: (value) {
                      setState(() {
                        _minRating = value;
                      });
                    },
                  ),
                ),

                // Rating display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0.0',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            _minRating.toStringAsFixed(1),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '10.0',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 40),

              const SizedBox(height: 48),

              // Save preferences button
              AuthButton(
                text: 'Save Preferences',
                onPressed: _handleSavePreferences,
                isLoading: authState.isLoading,
              ),

              // Error message
              if (authState.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onErrorContainer,
                          size: 18,
                        ),
                        onPressed: () {
                          ref.read(authProvider.notifier).clearError();
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
