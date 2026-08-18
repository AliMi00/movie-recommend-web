import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AuthLogo extends StatelessWidget {
  final double size;
  final bool showText;
  
  const AuthLogo({
    super.key,
    this.size = 80,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gold Clapperboard Icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.tertiary,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: AppColors.clayShadowAccent,
          ),
          // Mirrors the launcher icon: a play mark with the sparkle tucked
          // into its upper right, so the in-app logo and the home-screen
          // icon read as the same brand rather than two different ones.
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(right: size * 0.06),
                child: Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: size * 0.62,
                    color: AppColors.onTertiary,
                  ),
                ),
              ),
              Positioned(
                right: size * 0.13,
                top: size * 0.15,
                child: Icon(
                  Icons.auto_awesome,
                  size: size * 0.22,
                  color: AppColors.onTertiary,
                ),
              ),
            ],
          ),
        ),
        
        if (showText) ...[
          const SizedBox(height: 24),
          
          // App name
          Text(
            'CINEJO',
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: size * 0.4,
            ),
          ),
        ],
      ],
    );
  }
}
