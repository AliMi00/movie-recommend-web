import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_logo.dart';
import '../../../data/services/local_storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  /// Whether the first-run intro carousel has already been shown on this
  /// device. Cached in a field so the auth listener below — which runs
  /// synchronously — can pick a destination without awaiting storage.
  /// Defaults to true: if the lookup somehow hasn't finished, sending a
  /// visitor to the welcome screen is a safer miss than replaying the intro
  /// to someone who has already seen it.
  bool _introSeen = true;
  late final Future<void> _introSeenLoaded = _loadIntroSeen();

  /// Where an unauthenticated visitor should land.
  String get _unauthenticatedRoute =>
      _introSeen ? AppConstants.welcomeRoute : AppConstants.onboardingRoute;

  Future<void> _loadIntroSeen() async {
    try {
      final storage = await LocalStorageService.getInstance();
      _introSeen = await storage.hasSeenOnboardingIntro();
    } catch (_) {
      // Keep the default; see the field doc above.
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // Check authentication status after a brief delay
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for the animation to finish and for the intro flag to load, so the
    // destination below is decided from real storage rather than the default.
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 2000)),
      // Capped so a stalled storage read can never strand the visitor on the
      // splash screen forever; falling back to the default just means the
      // intro is skipped rather than the app hanging.
      _introSeenLoaded.timeout(const Duration(seconds: 3), onTimeout: () {}),
    ]);

    if (!mounted) return;

    final authState = ref.read(authProvider);

    // Navigate based on authentication state
    if (authState.isAuthenticated && authState.user != null) {
      if (authState.isFirstTimeUser) {
        context.go('/preferences');
      } else {
        context.go('/home');
      }
    } else {
      context.go(_unauthenticatedRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Listen to auth state for real-time updates
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!next.isLoading && mounted) {
        if (next.isAuthenticated && next.user != null) {
          if (next.isFirstTimeUser) {
            context.go('/preferences');
          } else {
            context.go('/home');
          }
        } else if (previous?.isLoading == true) {
          // Only navigate away if we were previously loading
          context.go(_unauthenticatedRoute);
        }
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.1),
              AppColors.primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: const AuthLogo(size: 120),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Loading indicator
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Loading your movie experience...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
