import 'package:flutter/material.dart';

/// App color palette for the "Soft Clay" design system — a light, tactile
/// white-and-blue surface language matching the cinejo marketing site.
///
/// Claymorphism builds depth from paired shadows rather than borders or blur:
/// a soft blue-grey shadow at bottom-right, a white highlight at top-left, so
/// surfaces read as puffy extrusions of the background. Elevation is therefore
/// expressed through [clayShadow] / [claySurfaceDecoration], not Material's
/// `elevation` property, which is left at 0 throughout the theme.
class AppColors {
  // Foundational Neutrals
  static const Color background = Color(0xFFEAF1FC); // Pale blue page base
  static const Color surface = Color(0xFFFFFFFF);    // Raised clay surface
  static const Color surfaceDim = Color(0xFFE0E9F7);
  static const Color surfaceBright = Color(0xFFFFFFFF);

  // Surface Containers.
  // Higher tiers read as *recessed* here: on a white raised card, depth is
  // conveyed by a slightly deeper blue tint rather than by getting lighter
  // the way it did on the old dark palette.
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF7FAFE);
  static const Color surfaceContainerHigh = Color(0xFFF2F7FD);
  static const Color surfaceContainerHighest = Color(0xFFE6EEFB);

  // On Surface
  static const Color onSurface = Color(0xFF1B2740);        // Deep navy ink
  // Muted slate blue. Darkened from the design's original 0xFF6B7A99, which
  // measured 3.8:1 against the page background and 4.31:1 against white
  // surfaces — both below WCAG AA's 4.5:1 minimum for normal-size text. This
  // shade clears 4.5:1 against both.
  static const Color onSurfaceVariant = Color(0xFF606D89);
  static const Color inverseSurface = Color(0xFF1B2740);
  static const Color inverseOnSurface = Color(0xFFEAF1FC);
  static const Color surfaceTint = Color(0xFF3B82F6);
  static const Color outline = Color(0xFF9AACC9);
  static const Color outlineVariant = Color(0xFFD5E2F5);

  // Primary (Blue — the core brand accent)
  static const Color primary = Color(0xFF3B82F6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFDCEAFF);
  static const Color onPrimaryContainer = Color(0xFF102A56);

  // Secondary (Blue — interaction & AI accents)
  static const Color secondary = Color(0xFF3B82F6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF1D4ED8);
  static const Color onSecondaryContainer = Color(0xFFFFFFFF);

  // Tertiary (Deep blue — primary CTAs and "premium" moments).
  // Was gold on the cinematic palette; gold fights a white-and-blue clay
  // surface, so the emphasis role moved onto the deeper end of the blues.
  static const Color tertiary = Color(0xFF1D4ED8);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFDCEAFF);
  static const Color onTertiaryContainer = Color(0xFF102A56);

  // Functional Colors
  static const Color error = Color(0xFFD92D20);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFE4E1);
  static const Color onErrorContainer = Color(0xFF7A1710);

  // Interaction Accents (Gestural feedback).
  // Like/dislike stay green/red: they signal a gesture's meaning, and
  // recolouring them to fit the palette would cost more in legibility than
  // it gains in cohesion. Super-like joins the blues.
  static const Color like = Color(0xFF12A150);    // Emerald
  static const Color dislike = Color(0xFFE5484D); // Coral red
  static const Color superLike = tertiary;

  // Text and icons sitting directly on poster or backdrop artwork. Media is
  // dark regardless of how pale the surrounding chrome is, so these stay
  // light — using onSurface there would put navy text on a dark scrim.
  static const Color onMedia = Color(0xFFFFFFFF);
  static const Color onMediaVariant = Color(0xB3FFFFFF); // 70% white
  static const Color onMediaFaint = Color(0x80FFFFFF);   // 50% white

  // ===========================================================================
  // Claymorphism depth tokens
  // ===========================================================================

  /// Bottom-right shadow — a desaturated blue rather than grey, so shadows
  /// sit in the same family as the surfaces casting them.
  static const Color clayShadowColor = Color(0x73A3B9DE); // 45% #A3B9DE

  /// Top-left highlight that gives clay its inflated look.
  static const Color clayHighlightColor = Color(0xE6FFFFFF); // 90% white

  /// Standard raised clay elevation for cards, sheets and tiles.
  static const List<BoxShadow> clayShadow = [
    BoxShadow(color: clayShadowColor, offset: Offset(8, 8), blurRadius: 20),
    BoxShadow(color: clayHighlightColor, offset: Offset(-8, -8), blurRadius: 20),
  ];

  /// Tighter variant for small controls — chips, icon buttons, list rows.
  static const List<BoxShadow> clayShadowSmall = [
    BoxShadow(color: clayShadowColor, offset: Offset(5, 5), blurRadius: 12),
    BoxShadow(color: clayHighlightColor, offset: Offset(-5, -5), blurRadius: 12),
  ];

  /// Coloured glow for filled accent buttons, so a blue CTA still casts a
  /// blue-tinted shadow instead of a grey one.
  static const List<BoxShadow> clayShadowAccent = [
    BoxShadow(color: Color(0x591D4ED8), offset: Offset(6, 6), blurRadius: 16),
    BoxShadow(color: Color(0xB3FFFFFF), offset: Offset(-4, -4), blurRadius: 14),
  ];

  // Legacy glass tokens, retained because ~30 call sites still reference them.
  // Repointed at clay equivalents so those surfaces stay coherent without
  // needing every usage rewritten.
  static const Color glassBorder = Color(0x1F3B82F6);  // 12% blue hairline
  static const Color glassSurface = Color(0xFFFFFFFF);

  // Gradients
  /// Scrim for text sitting over poster artwork. Still dark — the artwork
  /// underneath is full-bleed photography regardless of the app's chrome.
  static const LinearGradient cardOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0xCC0B1220),
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B9DFF), tertiary],
  );

  // ===========================================================================
  // Helpers
  // ===========================================================================

  /// Decoration for a raised clay surface.
  static BoxDecoration claySurfaceDecoration({
    double radius = 24,
    Color color = surface,
    bool small = false,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: small ? clayShadowSmall : clayShadow,
    );
  }

  /// Decoration for a recessed (pressed-in) clay surface such as a text field
  /// or progress track. Flutter has no inset box-shadow, so the illusion comes
  /// from a deeper fill plus a soft inner-edge hairline.
  static BoxDecoration clayInsetDecoration({
    double radius = 18,
    Color color = surfaceContainerHigh,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0x1FA3B9DE), width: 1),
    );
  }
}
