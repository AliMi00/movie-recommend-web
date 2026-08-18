import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/movie_model.dart';
import '../../../core/theme/app_colors.dart';

class SwipeActionButtons extends StatelessWidget {
  final void Function(UserInteraction) onAction;
  const SwipeActionButtons({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ClayActionButton(
          icon: Icons.close_rounded,
          iconColor: AppColors.dislike,
          onPressed: () => onAction(UserInteraction.disliked),
          size: 62,
          semanticLabel: 'Dislike',
        ),
        const SizedBox(width: 28),
        // Super like is the hero action, so it is the one filled button.
        _ClayActionButton(
          icon: Icons.star_rounded,
          iconColor: AppColors.onTertiary,
          onPressed: () => onAction(UserInteraction.superLiked),
          size: 78,
          filled: true,
          semanticLabel: 'Super like',
        ),
        const SizedBox(width: 28),
        _ClayActionButton(
          icon: Icons.favorite_rounded,
          iconColor: AppColors.like,
          onPressed: () => onAction(UserInteraction.liked),
          size: 62,
          semanticLabel: 'Like',
        ),
      ],
    );
  }
}

/// A round clay button.
///
/// The previous version tinted a translucent fill at 10% alpha over a
/// backdrop blur, which read as a glow against the old near-black screen but
/// washes out to almost nothing on the pale clay ground. These are solid
/// instead, and get their presence from the shadow pair rather than from
/// colour bleeding through.
class _ClayActionButton extends StatefulWidget {
  const _ClayActionButton({
    required this.icon,
    required this.iconColor,
    required this.onPressed,
    required this.size,
    required this.semanticLabel,
    this.filled = false,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;
  final double size;

  /// Fills the button with the accent colour instead of leaving it white.
  final bool filled;

  /// The icon alone carries no meaning to a screen reader — this is the only
  /// thing that tells VoiceOver/TalkBack which action the button performs.
  final String semanticLabel;

  @override
  State<_ClayActionButton> createState() => _ClayActionButtonState();
}

class _ClayActionButtonState extends State<_ClayActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onPressed();
        },
        child: AnimatedScale(
          // Clay presses *into* the surface, so the button shrinks on touch
          // rather than growing the way the old one did.
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.filled
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF5B9DFF), AppColors.tertiary],
                    )
                  : null,
              color: widget.filled ? null : AppColors.surface,
              // Flattening the shadow while held reads as the button sinking.
              boxShadow: _pressed
                  ? AppColors.clayShadowSmall
                  : (widget.filled
                        ? AppColors.clayShadowAccent
                        : AppColors.clayShadow),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.size * 0.44,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
