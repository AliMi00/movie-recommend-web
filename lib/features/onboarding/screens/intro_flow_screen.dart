import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/movie_model.dart';
import '../../discovery/providers/movie_providers.dart'
    show movieRepositoryProvider;
import '../../../data/services/local_storage_service.dart';
import '../../auth/widgets/auth_button.dart';
import '../../auth/widgets/auth_logo.dart';
import '../pending_preferences.dart';

/// The guided intro: what the app does, what you like, a live taste of the
/// thing that makes it different, and only then a sign-up.
///
/// The ordering is the point. Asking for an account first means asking
/// someone to commit before they have seen anything work; the discover step
/// exists so the sign-up request lands *after* the product has proved
/// itself. That is also why it uses the real search rather than a canned
/// list — a faked demo would make the first real query a disappointment.
///
/// Genre and rating answers can't be saved when they're given: the
/// preferences endpoint needs a verified account, which doesn't exist until
/// two steps later. They're parked in [PendingPreferences] and pushed after
/// verification.
class IntroFlowScreen extends ConsumerStatefulWidget {
  const IntroFlowScreen({super.key});

  @override
  ConsumerState<IntroFlowScreen> createState() => _IntroFlowScreenState();
}

class _IntroFlowScreenState extends ConsumerState<IntroFlowScreen> {
  final PageController _controller = PageController();
  int _step = 0;

  static const int _stepCount = 6;

  final Set<String> _genres = <String>{};
  double _minRating = 6.0;

  @override
  void initState() {
    super.initState();
    AnalyticsService.trackEvent('intro_flow_started');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    if (step < 0 || step >= _stepCount) return;
    _controller.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    // Parked rather than saved: PUT /users/me/preferences needs a verified
    // account, and the next step is where the account gets created.
    await PendingPreferences.save(
      PendingPreferences(
        genres: _genres.toList()..sort(),
        minRating: _minRating,
      ),
    );
    final storage = await LocalStorageService.getInstance();
    await storage.saveBool(AppConstants.onboardingIntroSeenKey, true);

    AnalyticsService.trackEvent(
      'intro_flow_completed',
      properties: {'genre_count': _genres.length, 'min_rating': _minRating},
    );

    if (!mounted) return;
    context.go(AppConstants.registerRoute);
  }

  Future<void> _skip() async {
    final storage = await LocalStorageService.getInstance();
    await storage.saveBool(AppConstants.onboardingIntroSeenKey, true);
    AnalyticsService.trackEvent(
      'intro_flow_skipped',
      properties: {'step': _step},
    );
    if (!mounted) return;
    context.go(AppConstants.welcomeRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _IntroHeader(
              step: _step,
              stepCount: _stepCount,
              onSkip: _skip,
              onBack: _step == 0 ? null : () => _goTo(_step - 1),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                // Driven by the buttons: several steps are asks, and a stray
                // swipe past one loses the answer without the person noticing.
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _WelcomeStep(onNext: () => _goTo(1)),
                  _GenreStep(
                    selected: _genres,
                    onToggle: (g) => setState(() {
                      _genres.contains(g) ? _genres.remove(g) : _genres.add(g);
                    }),
                    onNext: () => _goTo(2),
                  ),
                  _RatingStep(
                    value: _minRating,
                    onChanged: (v) => setState(() => _minRating = v),
                    onNext: () => _goTo(3),
                  ),
                  _TryItStep(onNext: () => _goTo(4)),
                  _GroupStep(onNext: () => _goTo(5)),
                  _CreateAccountStep(
                    genreCount: _genres.length,
                    onFinish: _finish,
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

class _IntroHeader extends StatelessWidget {
  const _IntroHeader({
    required this.step,
    required this.stepCount,
    required this.onSkip,
    this.onBack,
  });

  final int step;
  final int stepCount;
  final VoidCallback onSkip;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: onBack == null
                ? Colors.transparent
                : AppColors.onSurfaceVariant,
            tooltip: onBack == null ? null : 'Back',
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(stepCount, (i) {
                final active = i <= step;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 4,
                  width: i == step ? 20 : 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.secondary
                        : AppColors.onSurfaceVariant.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared chrome so every step has the same rhythm: content, then one
/// obvious action at the bottom.
class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.actionLabel,
    required this.onAction,
    this.actionEnabled = true,
    this.footnote,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String actionLabel;
  final VoidCallback onAction;
  final bool actionEnabled;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
          if (footnote != null) ...[
            Text(
              footnote!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 8),
          ],
          AuthButton(
            text: actionLabel,
            onPressed: actionEnabled ? onAction : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Stop scrolling.\nStart watching.',
      subtitle:
          'CinReco learns what you actually like, then finds the film for '
          'right now — on your own or with everyone on the sofa.',
      actionLabel: 'Show me how',
      onAction: onNext,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            AuthLogo(size: 96),
            SizedBox(height: 32),
            _Beat(
              icon: Icons.swipe_rounded,
              text:
                  'Swipe films you like. Your taste profile sharpens with '
                  'every one.',
            ),
            SizedBox(height: 16),
            _Beat(
              icon: Icons.auto_awesome_rounded,
              text: 'Or just describe the mood you\'re in, in plain English.',
            ),
            SizedBox(height: 16),
            _Beat(
              icon: Icons.groups_rounded,
              text:
                  'Watching with others? Blend everyone\'s taste into one '
                  'shortlist.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Beat extends StatelessWidget {
  const _Beat({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _GenreStep extends StatelessWidget {
  const _GenreStep({
    required this.selected,
    required this.onToggle,
    required this.onNext,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onNext;

  static const List<String> _genres = [
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

  @override
  Widget build(BuildContext context) {
    final enough = selected.length >= 3;
    return _StepScaffold(
      title: 'What do you\nreach for?',
      subtitle:
          'Pick at least three. This is the starting point — swiping '
          'refines it from here.',
      actionLabel: enough ? 'Next' : 'Pick ${3 - selected.length} more',
      actionEnabled: enough,
      onAction: onNext,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _genres.map((g) {
            final on = selected.contains(g);
            return GestureDetector(
              onTap: () => onToggle(g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: on ? AppColors.secondary : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: on
                        ? AppColors.secondary
                        : AppColors.onSurfaceVariant.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  g,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: on ? Colors.white : AppColors.onSurface,
                    fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RatingStep extends StatelessWidget {
  const _RatingStep({
    required this.value,
    required this.onChanged,
    required this.onNext,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'How picky\nare you?',
      subtitle:
          'We\'ll leave out anything rated below this. You can move it '
          'later in settings.',
      actionLabel: 'Next',
      onAction: onNext,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toStringAsFixed(1),
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _describe(value),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Slider(
              value: value,
              min: 0,
              max: 9,
              divisions: 18,
              activeColor: AppColors.secondary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  static String _describe(double v) {
    if (v <= 3) return 'Anything goes.';
    if (v <= 5.5) return 'Skip the truly rough stuff.';
    if (v <= 7) return 'Solidly reviewed films.';
    if (v <= 8) return 'Only the well-regarded ones.';
    return 'Near-perfect or nothing.';
  }
}

/// The step that earns the sign-up: a real query against the real catalogue.
class _TryItStep extends ConsumerStatefulWidget {
  const _TryItStep({required this.onNext});
  final VoidCallback onNext;

  @override
  ConsumerState<_TryItStep> createState() => _TryItStepState();
}

class _TryItStepState extends ConsumerState<_TryItStep> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<Movie> _results = const [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  /// Long enough that typing a sentence is one request rather than twenty.
  /// Every uncached query is a paid embedding call on a public endpoint.
  static const _debounceMs = 600;
  static const _minChars = 3;

  static const List<String> _examples = [
    'something dark and gritty',
    'funny but not stupid',
    'a thriller that won\'t keep me up',
    'beautiful and slow',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < _minChars) {
      setState(() {
        _results = const [];
        _error = null;
        _searched = false;
      });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: _debounceMs),
      () => _run(value),
    );
  }

  Future<void> _run(String query) async {
    final q = query.trim();
    if (q.length < _minChars) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(movieRepositoryProvider);
      final movies = await repo.discoverMovies(q, limit: 8);
      if (!mounted) return;
      setState(() {
        _results = movies;
        _loading = false;
        _searched = true;
      });
      AnalyticsService.trackEvent(
        'intro_discover_query',
        properties: {'result_count': movies.length},
      );
    } catch (e) {
      if (!mounted) return;
      // Deliberately surfaced rather than swallowed: the most likely failure
      // is the endpoint's rate limit, and silently showing "no results" would
      // read as "this product doesn't work".
      setState(() {
        _error = userFacingError(e);
        _loading = false;
        _searched = true;
      });
    }
  }

  void _useExample(String example) {
    _controller.text = example;
    _debounce?.cancel();
    _run(example);
  }

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Try it.\nRight now.',
      subtitle:
          'Describe what you feel like watching, the way you\'d say it '
          'to a friend. No account needed for this bit.',
      actionLabel: _searched && _results.isNotEmpty
          ? 'Nice — what\'s next'
          : 'Skip for now',
      onAction: widget.onNext,
      child: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: _onChanged,
            onSubmitted: _run,
            textInputAction: TextInputAction.search,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'something dark and gritty…',
              prefixIcon: const Icon(Icons.auto_awesome_rounded, size: 20),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!_searched && !_loading)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _examples
                  .map(
                    (e) => GestureDetector(
                      onTap: () => _useExample(e),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          e,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 8),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ),
      );
    }
    if (_searched && _results.isEmpty) {
      return Center(
        child: Text(
          'Nothing matched that one. Try describing it differently.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }
    if (_results.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _ResultTile(movie: _results[i]),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.movie});
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 42,
              height: 60,
              child: Image.network(
                movie.fullPosterPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.surface),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  movie.overview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupStep extends StatelessWidget {
  const _GroupStep({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'The part that\nends arguments.',
      subtitle:
          'Start a session, share the code, and everyone swipes on '
          'their own phone. CinReco blends the tastes in the room and '
          'surfaces what you all actually agree on.',
      actionLabel: 'Got it',
      onAction: onNext,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.groups_rounded, size: 72, color: AppColors.tertiary),
            SizedBox(height: 28),
            _Beat(
              icon: Icons.qr_code_rounded,
              text: 'One person starts a room and shares a short code.',
            ),
            SizedBox(height: 14),
            _Beat(
              icon: Icons.swipe_rounded,
              text: 'Everyone swipes at the same time, on their own device.',
            ),
            SizedBox(height: 14),
            _Beat(
              icon: Icons.check_circle_rounded,
              text:
                  'You get the shortlist the whole group leans towards — '
                  'not one person\'s compromise.',
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateAccountStep extends StatelessWidget {
  const _CreateAccountStep({required this.genreCount, required this.onFinish});

  final int genreCount;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Save it\nto your taste.',
      subtitle: genreCount > 0
          ? 'Create an account and your $genreCount picks come with you — '
                'along with your watchlist, swipes and group sessions, on every '
                'device you sign in from.'
          : 'Create an account to keep your watchlist, swipes and group '
                'sessions across every device you sign in from.',
      actionLabel: 'Create my account',
      onAction: onFinish,
      footnote: 'Free, and takes under a minute.',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            AuthLogo(size: 80),
            SizedBox(height: 28),
            _Beat(
              icon: Icons.devices_rounded,
              text: 'Your taste profile follows you across devices.',
            ),
            SizedBox(height: 14),
            _Beat(
              icon: Icons.bookmark_rounded,
              text: 'Keep a watchlist that updates as your taste shifts.',
            ),
            SizedBox(height: 14),
            _Beat(
              icon: Icons.mark_email_read_rounded,
              text:
                  'We\'ll send one email to confirm it\'s you, then you\'re in.',
            ),
          ],
        ),
      ),
    );
  }
}
