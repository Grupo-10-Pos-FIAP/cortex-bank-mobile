import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/core/theme/app_design_tokens.dart';

class AppErrorMessage extends StatelessWidget {
  const AppErrorMessage({
    super.key,
    this.message,
    this.onDismiss,
  });

  final String? message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(AppDesignTokens.spacingMd),
      margin: const EdgeInsets.only(bottom: AppDesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
        border: Border.all(
          color: errorColor,
          width: AppDesignTokens.borderWidthDefault,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: errorColor,
            size: 20,
          ),
          const SizedBox(width: AppDesignTokens.spacingMd - 4),
          Expanded(
            child: Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: errorColor,
                fontSize: AppDesignTokens.fontSizeSmall,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: errorColor,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
