import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Complete theme system for the app, built on the "Soft Clay" design system.
///
/// Note on light/dark: [AppColors] is a flat static palette consumed directly
/// by screens (rather than resolved through `Theme.of(context).colorScheme`),
/// so a runtime brightness switch cannot repaint those call sites. The clay
/// language is also explicitly a light one — its depth comes from a white
/// highlight against a pale ground. Both [lightTheme] and [darkTheme]
/// therefore return the same clay theme, which keeps any lingering
/// `themeMode` wiring from rendering a half-themed screen.
class AppTheme {
  /// Base corner radius. Clay reads as soft and inflated, so the whole system
  /// sits on noticeably larger radii than the previous cinematic theme.
  static const double baseRadius = 18.0;
  static const double cardRadius = 24.0;
  static const double pillRadius = 999.0;

  static ThemeData get clayTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.bodyFont,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,

      // Clay conveys depth with paired shadows, so Material's own tinting is
      // switched off — otherwise surfaces pick up an extra elevation overlay
      // that muddies the white.
      applyElevationOverlayColor: false,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        // Dark status-bar glyphs, since the app chrome is now pale.
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.titleMedium,
        iconTheme: IconThemeData(color: AppColors.onSurface),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0, // Depth comes from AppColors.clayShadow instead.
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tertiary,
          foregroundColor: AppColors.onTertiary,
          disabledBackgroundColor: AppColors.surfaceContainerHighest,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(pillRadius),
          ),
          textStyle: AppTextStyles.labelSmall,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tertiary,
          backgroundColor: AppColors.surface,
          side: BorderSide(color: AppColors.outline.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(pillRadius),
          ),
          textStyle: AppTextStyles.labelSmall,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.tertiary,
          textStyle: AppTextStyles.labelSmall,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Inputs read as pressed *into* the surface — filled, no hard outline
      // until focus, which then draws the blue accent.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(baseRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(baseRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(baseRadius),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(baseRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(baseRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        prefixIconColor: AppColors.onSurfaceVariant,
        suffixIconColor: AppColors.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.tertiary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        selectedColor: AppColors.tertiary,
        secondarySelectedColor: AppColors.tertiary,
        checkmarkColor: AppColors.onTertiary,
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.onSurface,
        ),
        secondaryLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.onTertiary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(pillRadius)),
        ),
        side: BorderSide.none,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        titleTextStyle: AppTextStyles.titleMedium.copyWith(
          color: AppColors.onSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inverseSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.inverseOnSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(baseRadius),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onTertiary
              : AppColors.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.tertiary
              : AppColors.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.tertiary,
        inactiveTrackColor: AppColors.surfaceContainerHighest,
        thumbColor: AppColors.tertiary,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.tertiary,
        circularTrackColor: Colors.transparent,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.onSurfaceVariant,
        textColor: AppColors.onSurface,
      ),

      textTheme:
          const TextTheme(
            displayLarge: AppTextStyles.displayLarge,
            displaySmall: AppTextStyles.displaySmall,
            headlineLarge: AppTextStyles.headlineLarge,
            headlineMedium: AppTextStyles.headlineMedium,
            titleLarge: AppTextStyles.titleLarge,
            titleMedium: AppTextStyles.titleMedium,
            bodyLarge: AppTextStyles.bodyLarge,
            bodyMedium: AppTextStyles.bodyMedium,
            bodySmall: AppTextStyles.bodySmall,
            labelSmall: AppTextStyles.labelSmall,
          ).apply(
            bodyColor: AppColors.onSurface,
            displayColor: AppColors.onSurface,
          ),

      iconTheme: const IconThemeData(color: AppColors.onSurface, size: 24),

      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Both entries resolve to the clay theme — see the class doc for why.
  static ThemeData get lightTheme => clayTheme;
  static ThemeData get darkTheme => clayTheme;
}
