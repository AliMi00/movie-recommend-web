import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' show ImageFilter;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A premium, cinematic-themed screen for displaying markdown legal policies.
class LegalPolicyScreen extends StatelessWidget {
  final String title;
  final String assetPath;

  const LegalPolicyScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: AppBar(
              backgroundColor: AppColors.surface.withValues(alpha: 0.85),
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.onSurface,
                  size: 20,
                ),
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: AppColors.glassBorder,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load policy',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your network or try again later.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final markdownData = snapshot.data ?? '';

          return SafeArea(
            bottom: false,
            child: Theme(
              data: Theme.of(context).copyWith(
                cardTheme: CardThemeData(
                  color: AppColors.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.glassBorder),
                  ),
                ),
              ),
              child: Markdown(
                data: markdownData,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  // Headings
                  h1: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                  h3: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  
                  // Body copy
                  p: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.6,
                  ),
                  pPadding: const EdgeInsets.only(bottom: 14.0),
                  
                  // Lists
                  listBullet: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                  listBulletPadding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                  
                  // Links
                  a: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.secondary,
                  ),
                  
                  // Bold & Italics
                  strong: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  em: AppTextStyles.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  
                  // Code
                  code: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.tertiary,
                    backgroundColor: AppColors.surfaceContainer,
                    fontFamily: 'monospace',
                  ),
                  
                  // Spacing
                  h1Padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                  h2Padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  h3Padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  horizontalRuleDecoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.glassBorder,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                onTapLink: (text, href, title) {
                  if (href != null) {
                    // In a production app, we would use url_launcher.
                    // For now, we can show a SnackBar or just handle it if web view support is added.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening link: $href'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
