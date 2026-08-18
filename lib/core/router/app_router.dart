import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';
import '../../features/group_session/providers/group_session_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/preferences_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/discovery/screens/discovery_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/watchlist/screens/watchlist_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/legal_policy_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/history/screens/watch_history_screen.dart';
import '../../features/group_session/screens/group_session_dashboard_screen.dart';
import '../../features/group_session/screens/group_session_lobby_screen.dart';
import '../../features/group_session/screens/group_recommendations_screen.dart';

// ... (other imports unchanged)

// For now, we'll use placeholder widgets until we create the actual screens
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(
              'This screen will be implemented in the next phase',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Application router configuration using GoRouter
final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.splashRoute,
  observers: [PosthogObserver()],
  routes: [
    // Splash/Welcome Route
    GoRoute(
      path: AppConstants.splashRoute,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Welcome Landing Route
    GoRoute(
      path: AppConstants.welcomeRoute,
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),

    // Onboarding Routes
    GoRoute(
      path: AppConstants.onboardingRoute,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Authentication Routes
    GoRoute(
      path: AppConstants.loginRoute,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppConstants.registerRoute,
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Forgot Password Route
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Genre Selection Route (User Preferences)
    GoRoute(
      path: '/preferences',
      name: 'preferences',
      builder: (context, state) => const PreferencesScreen(),
    ),

    // Profile Route
    GoRoute(
      path: AppConstants.profileRoute,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    // Main App Routes
    GoRoute(
      path: AppConstants.homeRoute,
      name: 'home',
      builder: (context, state) => const MainNavigationWrapper(),
    ),

    // Movie Details Route with parameter
    GoRoute(
      path: '${AppConstants.movieDetailsRoute}/:movieId',
      name: 'movie-details',
      builder: (context, state) {
        final movieId = state.pathParameters['movieId'] ?? '0';
        return PlaceholderScreen(title: 'Movie Details - $movieId');
      },
    ),

    // Trailer Route with parameter
    GoRoute(
      path: '${AppConstants.trailerRoute}/:movieId',
      name: 'trailer',
      builder: (context, state) {
        final movieId = state.pathParameters['movieId'] ?? '0';
        return PlaceholderScreen(title: 'Trailer - $movieId');
      },
    ),

    // Settings Route
    GoRoute(
      path: AppConstants.settingsRoute,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    // Terms of Service Route
    GoRoute(
      path: AppConstants.termsRoute,
      name: 'terms',
      builder: (context, state) => const LegalPolicyScreen(
        title: 'Terms of Service',
        assetPath: 'assets/legal/terms_of_service.md',
      ),
    ),

    // Privacy Policy Route
    GoRoute(
      path: AppConstants.privacyRoute,
      name: 'privacy',
      builder: (context, state) => const LegalPolicyScreen(
        title: 'Privacy Policy',
        assetPath: 'assets/legal/privacy_policy.md',
      ),
    ),

    // Accessibility Statement Route
    GoRoute(
      path: AppConstants.accessibilityRoute,
      name: 'accessibility',
      builder: (context, state) => const LegalPolicyScreen(
        title: 'Accessibility Statement',
        assetPath: 'assets/legal/accessibility_statement.md',
      ),
    ),

    // Watch History Route
    GoRoute(
      path: AppConstants.watchHistoryRoute,
      name: 'watch-history',
      builder: (context, state) => const WatchHistoryScreen(),
    ),

    // Group Session Routes
    GoRoute(
      path: '/group-session',
      name: 'group-session',
      builder: (context, state) => const GroupSessionDashboardScreen(),
    ),
    GoRoute(
      path: '/group-session/lobby/:code',
      name: 'group-session-lobby',
      builder: (context, state) {
        final code = state.pathParameters['code'] ?? '';
        return GroupSessionLobbyScreen(code: code);
      },
    ),
    GoRoute(
      path: '/group-session/recommendations/:code',
      name: 'group-session-recommendations',
      builder: (context, state) {
        final code = state.pathParameters['code'] ?? '';
        return GroupRecommendationsScreen(code: code);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page not found!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'The page you are looking for does not exist.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppConstants.homeRoute),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);

/// Main navigation wrapper with bottom navigation
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DiscoveryScreen(),
    const GroupSessionDashboardScreen(),
    const WatchlistScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody:
          true, // Crucial for letting content render behind the glass navigation bar
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _GlassBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _GlassBottomNavigationBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _GlassBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final invitesAsync = ref.watch(pendingInvitationsProvider);
    final inviteCount = invitesAsync.value?.length ?? 0;

    // A raised clay bar rather than the previous dark blurred glass panel:
    // translucent black chrome reads as a foreign slab against the pale
    // surfaces the rest of the app now uses.
    return Container(
      height: 72 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          // Only the upward highlight/shadow pair matters here — the bar is
          // flush to the bottom edge, so a downward shadow would be clipped.
          BoxShadow(
            color: AppColors.clayShadowColor,
            offset: Offset(0, -6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.explore_outlined, Icons.explore, 'Discover'),
          _buildNavItem(
            1,
            Icons.people_alt_outlined,
            Icons.people_alt,
            'Group',
            badgeCount: inviteCount,
          ),
          _buildNavItem(
            2,
            Icons.bookmark_border_rounded,
            Icons.bookmark_rounded,
            'Watchlist',
          ),
          _buildNavItem(
            3,
            Icons.person_outline_rounded,
            Icons.person_rounded,
            'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData outlineIcon,
    IconData filledIcon,
    String label, {
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.secondary : AppColors.onSurfaceVariant;

    // `label` was already being threaded through to every call site and
    // computed here, but never actually reached the user — there is no
    // visible text under the icon, and nothing declared it to a screen
    // reader either, so this tab was silent to VoiceOver/TalkBack. Semantics
    // is a non-visual layer, so this doesn't change how the bar looks.
    return Expanded(
      child: Semantics(
        label: label,
        button: true,
        selected: isSelected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: isSelected
                    ? Matrix4.translationValues(0, -2, 0)
                    : Matrix4.identity(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? filledIcon : outlineIcon,
                      color: color,
                      size: 24,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -8,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.tertiary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '$badgeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              if (isSelected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.8),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(
                  height: 5,
                ), // Spacer to maintain vertical alignment
            ],
          ),
        ),
      ),
    );
  }
}
