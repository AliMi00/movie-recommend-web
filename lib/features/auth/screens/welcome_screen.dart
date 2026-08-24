import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_logo.dart';
import '../widgets/private_project_banner.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  /// Tracks only *this screen's* demo sign-in, deliberately not the global
  /// auth state. AuthNotifier runs a "am I already signed in?" check on
  /// startup, so watching its isLoading would blank the landing page behind
  /// a spinner every cold start — and on a slow or unreachable API it would
  /// never clear.
  bool _demoLoading = false;

  /// Signs in with the shared demo credentials configured for this
  /// deployment. This is the landing screen's primary action: most visitors
  /// are evaluating the project rather than signing up, so the shortest path
  /// to a working app is one tap with no form to fill in.
  Future<void> _handleDemoLogin() async {
    final config = ref.read(appConfigProvider);
    if (!config.hasDemoAccount || _demoLoading) return;

    setState(() => _demoLoading = true);
    try {
      final success = await ref
          .read(authProvider.notifier)
          .login(config.demoEmail, config.demoPassword);

      if (!success || !mounted) return;

      final authState = ref.read(authProvider);
      context.go(authState.isFirstTimeUser ? '/preferences' : '/home');
    } finally {
      if (mounted) setState(() => _demoLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDemo = ref.watch(appConfigProvider).hasDemoAccount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingOverlay(
        isLoading: _demoLoading,
        child: Stack(
          children: [
            // Ambient top glow
            Positioned(
              top: -100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 0.8,
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              const Spacer(flex: 3),

                              // Gold Clapperboard Logo
                              const AuthLogo(size: 80),

                              const SizedBox(height: 32),

                              // Subtitle
                              Text(
                                'Your Movie\nMatchmaker.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Description
                              Text(
                                'Discover curated films tailored perfectly to your current mood in our premium screening room.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant.withValues(
                                    alpha: 0.8,
                                  ),
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 24),
                              const PrivateProjectBanner(),

                              const Spacer(flex: 2),

                              // Primary action: try the app immediately. Only
                              // the demo button is filled, so the hierarchy
                              // reads at a glance even though three actions
                              // are offered.
                              if (hasDemo) ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: _demoLoading
                                        ? null
                                        : _handleDemoLogin,
                                    icon: const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 22,
                                    ),
                                    label: Text(
                                      'Try the Demo Account',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.tertiary,
                                      foregroundColor: AppColors.onTertiary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No sign-up needed — explore the full app instantly',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Create an account
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: hasDemo
                                    ? OutlinedButton(
                                        onPressed: () => context.push(
                                          AppConstants.registerRoute,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.onSurface,
                                          side: BorderSide(
                                            color: AppColors.onSurface
                                                .withValues(alpha: 0.2),
                                            width: 1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Create an Account',
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      )
                                    // With no demo configured this is the
                                    // primary action, so it keeps the filled
                                    // treatment it had before.
                                    : ElevatedButton(
                                        onPressed: () => context.push(
                                          AppConstants.registerRoute,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.tertiary,
                                          foregroundColor: AppColors.onTertiary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Get Started',
                                              style: AppTextStyles.labelSmall
                                                  .copyWith(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 12),

                              // Sign In — a text link rather than a third
                              // button, so the two real choices above stay
                              // visually distinct.
                              TextButton(
                                onPressed: () =>
                                    context.push(AppConstants.loginRoute),
                                child: Text(
                                  'Already have an account?  Sign In',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
