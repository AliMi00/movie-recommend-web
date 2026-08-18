import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MoodInputBar extends StatefulWidget {
  final Function(String) onSubmitted;
  final String? initialValue;

  const MoodInputBar({
    super.key,
    required this.onSubmitted,
    this.initialValue,
  });

  @override
  State<MoodInputBar> createState() => _MoodInputBarState();
}

class _MoodInputBarState extends State<MoodInputBar> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  final List<String> _placeholders = [
    'Find me something neon and fast-paced...',
    'Feeling like a lighthearted comedy...',
    'Something dark, gritty and intellectual...',
    'A journey through space and time...',
    'Romantic but with a tragic twist...',
  ];
  late String _currentPlaceholder;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _currentPlaceholder = (_placeholders..shuffle()).first;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? AppColors.secondary : AppColors.glassBorder,
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          // Lightens rather than darkens now — a darkening pass muddied the
          // pale surface the field sits on.
          filter: ColorFilter.mode(
            AppColors.surface.withValues(alpha: 0.6),
            BlendMode.lighten,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: widget.onSubmitted,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
            cursorColor: AppColors.secondary,
            decoration: InputDecoration(
              hintText: _currentPlaceholder,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
              prefixIcon: Icon(
                Icons.auto_awesome,
                color: _isFocused ? AppColors.secondary : AppColors.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        widget.onSubmitted('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
