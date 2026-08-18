import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A raised clay surface: solid fill, generous radius, and the paired
/// shadow/highlight that gives the design system its inflated look.
class ClayContainer extends StatelessWidget {
  const ClayContainer({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.color,
    this.border,
    this.padding,
    this.width,
    this.height,
    this.small = false,
    this.inset = false,
  });

  final Widget child;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  /// Uses the tighter shadow pair, for chips and other small controls.
  final bool small;

  /// Renders the surface as pressed *into* the page instead of raised.
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final decoration = inset
        ? AppColors.clayInsetDecoration(
            radius: borderRadius,
            color: color ?? AppColors.surfaceContainerHigh,
          )
        : AppColors.claySurfaceDecoration(
            radius: borderRadius,
            color: color ?? AppColors.surface,
            small: small,
          );

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: border == null
          ? decoration
          : decoration.copyWith(border: border),
      // Transparent Material keeps ink effects working for any tappable
      // children without painting over the clay fill.
      child: Material(color: Colors.transparent, child: child),
    );
  }
}

/// Backwards-compatible alias for the many call sites written against the
/// previous glassmorphism system. Blur and translucency have no meaning in
/// the clay language, so [blur] and [opacity] are accepted and ignored rather
/// than removed, which would have meant touching every screen at once.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.05,
    this.borderRadius = 24.0,
    this.color,
    this.border,
    this.padding,
    this.width,
    this.height,
  });

  final Widget child;

  /// Ignored. Retained so existing call sites keep compiling.
  final double blur;

  /// Ignored. Retained so existing call sites keep compiling.
  final double opacity;

  final double borderRadius;
  final Color? color;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      borderRadius: borderRadius,
      color: color,
      border: border,
      padding: padding,
      width: width,
      height: height,
      child: child,
    );
  }
}
