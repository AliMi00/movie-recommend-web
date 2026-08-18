import 'package:flutter/material.dart';

/// Typography system for the Movie Tinder app
/// Based on Montserrat for headlines and Inter for body/utility.
class AppTextStyles {
  static const String headlineFont = 'Montserrat';
  static const String bodyFont = 'Inter';

  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: headlineFont,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 56 / 48,
    letterSpacing: -0.02 * 48,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: headlineFont,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: headlineFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.01 * 32,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: headlineFont,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
  );

  static const TextStyle headlineLargeMobile = TextStyle(
    fontFamily: headlineFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: headlineFont,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 28 / 22,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: headlineFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  // Label styles
  static const TextStyle labelSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.05 * 12,
  );

  // Special styles for movie-specific content
  static const TextStyle movieTitle = TextStyle(
    fontFamily: headlineFont,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.1,
    height: 1.2,
  );

  static const TextStyle movieSubtitle = TextStyle(
    fontFamily: headlineFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static const TextStyle movieOverview = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
    height: 1.5,
  );

  static const TextStyle genreTag = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const TextStyle ratingText = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );
}
