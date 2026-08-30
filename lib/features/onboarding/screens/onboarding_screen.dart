import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/local_storage_service.dart';

/// Content for a single intro slide.
@immutable
class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String body;
}

/// The intro slides, in order. Each one maps to a feature that actually
/// ships today — swiping, group sessions, mood search, and the watchlist —
/// so the intro never promises something the app can't do.
const List<OnboardingPageData> kOnboardingPages = <OnboardingPageData>[
  OnboardingPageData(
    icon: Icons.swipe_rounded,
    accent: AppColors.secondary,
    title: 'Swipe your way\nto movie night.',
    body:
        'Like what you love, skip what you don\'t. Every swipe sharpens your '
        'taste profile, so the next pick lands closer to the mark.',
  ),
  OnboardingPageData(
    icon: Icons.groups_rounded,
    accent: AppColors.tertiary,
    title: 'Settle it,\ntogether.',
    body:
        'Start a group session and everyone swipes at once. Cinreco blends '
        'your tastes and surfaces the films the whole room agrees on.',
  ),
  OnboardingPageData(
    icon: Icons.auto_awesome_rounded,
    accent: AppColors.secondary,
    title: 'Just say\nthe vibe.',
    body:
        '"Something funny but not stupid." Describe the mood you\'re in and '
        'let the recommendations come to you.',
  ),
  OnboardingPageData(
    icon: Icons.bookmark_rounded,
    accent: AppColors.like,
    title: 'Never lose\na good one.',
    body:
        'Save picks to your watchlist and pick up right where you left off, '
        'on any device you sign in from.',
  ),
];

/// First-run intro carousel, shown once per install before the welcome screen.
///
/// Analytics events are prefixed `intro_onboarding_*` rather than
/// `onboarding_*` on purpose: the latter is already taken by the preferences
/// setup A/B experiment in [PreferencesScreen], and reusing those names would
/// contaminate that experiment's funnel with pre-auth traffic.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.trackEvent('intro_onboarding_started');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLastPage => _index == kOnboardingPages.length - 1;

  Future<void> _finish({required bool skipped}) async {
    // Guards a double-tap from firing two navigations (and two events).
    if (_finishing) return;
    setState(() => _finishing = true);

    AnalyticsService.trackEvent(
      skipped ? 'intro_onboarding_skipped' : 'intro_onboarding_completed',
      properties: {'page_index': _index, 'page_count': kOnboardingPages.length},
    );

    try {
      final storage = await LocalStorageService.getInstance();
      await storage.setOnboardingIntroSeen();
    } catch (_) {
      // A storage failure shouldn't strand the user on the intro. Worst case
      // the carousel reappears next launch, which beats a dead-end button.
    }

    if (!mounted) return;
    // Replaying from Settings pushes this screen, so send the user back where
    // they came from. The first-run path arrives via go(), leaving nothing to
    // pop, and continues on to the welcome screen instead.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppConstants.welcomeRoute);
    }
  }

  void _onNextPressed() {
    if (_isLastPage) {
      _finish(skipped: false);
      return;
    }
    _controller.nextPage(
      duration: AppConstants.mediumAnimationDuration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient glow tinted to match the current slide's accent.
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.7),
                radius: 0.9,
                colors: [
                  kOnboardingPages[_index].accent.withValues(alpha: 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip — hidden on the last page, where the primary button
                // already finishes the flow.
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    opacity: _isLastPage ? 0 : 1,
                    duration: AppConstants.shortAnimationDuration,
                    child: IgnorePointer(
                      ignoring: _isLastPage,
                      child: TextButton(
                        onPressed: () => _finish(skipped: true),
                        child: Text(
                          'Skip',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: kOnboardingPages.length,
                    onPageChanged: (i) {
                      setState(() => _index = i);
                      AnalyticsService.trackEvent(
                        'intro_onboarding_page_viewed',
                        properties: {'page_index': i},
                      );
                    },
                    itemBuilder: (context, i) =>
                        _OnboardingSlide(data: kOnboardingPages[i]),
                  ),
                ),

                _OnboardingFooter(
                  index: _index,
                  pageCount: kOnboardingPages.length,
                  isLastPage: _isLastPage,
                  busy: _finishing,
                  onNext: _onNextPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.data});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    // Scrollable so the slide degrades gracefully on short screens and when
    // the OS text scale is turned up, rather than overflowing.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                        width: 132,
                        height: 132,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: data.accent.withValues(alpha: 0.12),
                          border: Border.all(
                            color: data.accent.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(data.icon, size: 60, color: data.accent),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 48),

                  Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineLargeMobile.copyWith(
                          color: AppColors.onSurface,
                          height: 1.25,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 120.ms, duration: 400.ms)
                      .slideY(begin: 0.15),

                  const SizedBox(height: 20),

                  Text(
                        data.body,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                          height: 1.6,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 220.ms, duration: 400.ms)
                      .slideY(begin: 0.15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingFooter extends StatelessWidget {
  const _OnboardingFooter({
    required this.index,
    required this.pageCount,
    required this.isLastPage,
    required this.busy,
    required this.onNext,
  });

  final int index;
  final int pageCount;
  final bool isLastPage;
  final bool busy;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (i) {
              final active = i == index;
              return AnimatedContainer(
                duration: AppConstants.shortAnimationDuration,
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.tertiary
                      : AppColors.onSurface.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: busy ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiary,
                foregroundColor: AppColors.onTertiary,
                disabledBackgroundColor: AppColors.tertiary.withValues(
                  alpha: 0.6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onTertiary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastPage ? 'Get Started' : 'Next',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
