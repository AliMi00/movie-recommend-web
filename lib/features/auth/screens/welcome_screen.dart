import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/auth_logo.dart';
import '../widgets/private_project_banner.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
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

                            // Get Started Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () =>
                                    context.push(AppConstants.registerRoute),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.tertiary,
                                  foregroundColor: AppColors.onTertiary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Get Started',
                                      style: AppTextStyles.labelSmall.copyWith(
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

                            const SizedBox(height: 16),

                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () =>
                                    context.push(AppConstants.loginRoute),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.onSurface,
                                  side: BorderSide(
                                    color: AppColors.onSurface.withValues(
                                      alpha: 0.2,
                                    ),
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
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
    );
  }
}
