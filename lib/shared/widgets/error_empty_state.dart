import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Unified error / empty / info state widget with optional action button.
class ErrorEmptyState extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Widget>? extra;

  const ErrorEmptyState({super.key, required this.icon, required this.title, this.message, this.iconColor, this.actionLabel, this.onAction, this.extra});

  factory ErrorEmptyState.error({required String message, VoidCallback? onRetry, String title = 'Something went wrong'}) =>
      ErrorEmptyState(icon: Icons.error_outline, iconColor: Colors.redAccent, title: title, message: message, actionLabel: onRetry != null ? 'Retry' : null, onAction: onRetry);

  factory ErrorEmptyState.empty({required String title, String? message, IconData icon = Icons.inbox_outlined}) =>
      ErrorEmptyState(icon: icon, title: title, message: message, iconColor: AppColors.outline);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 64, color: iconColor ?? theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: onAction, icon: const Icon(Icons.refresh), label: Text(actionLabel!)),
            ],
            if (extra != null) ...[
              const SizedBox(height: 12),
              ...extra!,
            ]
          ]),
        ),
      ),
    );
  }
}
