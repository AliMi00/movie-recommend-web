import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
