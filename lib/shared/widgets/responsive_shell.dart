import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Constrains the app to a phone-width column on wide (desktop) viewports.
///
/// The UI underneath (swipe cards, bottom nav, auth forms) was built
/// mobile-first and assumes a narrow column — rather than reflowing every
/// screen, this letterboxes it: below [breakpoint] it's a no-op (phones,
/// narrow browser windows), above it the app renders in a fixed-width,
/// centered column against the page background, like Tinder's own web
/// client does for the same swipe-card layout.
class ResponsiveShell extends StatelessWidget {
  final Widget? child;
  static const double breakpoint = 600;
  static const double maxContentWidth = 480;

  const ResponsiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final content = child ?? const SizedBox.shrink();
    final width = MediaQuery.sizeOf(context).width;
    if (width <= breakpoint) return content;

    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Container(
          width: maxContentWidth,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 32,
                spreadRadius: 0,
              ),
            ],
          ),
          child: content,
        ),
      ),
    );
  }
}
