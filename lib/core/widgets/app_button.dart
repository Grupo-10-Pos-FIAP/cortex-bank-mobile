import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

enum ButtonVariant { primary, outlined, secondary, negative }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.variant = ButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final ButtonVariant variant;

  static const double _buttonHeight = 48;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? SizedBox(
            width: AppDesignTokens.spacingLg,
            height: AppDesignTokens.spacingLg,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    switch (variant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: FilledButton(
            onPressed: (enabled && !loading) ? onPressed : null,
            child: child,
          ),
        );
      case ButtonVariant.outlined:
        return SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: OutlinedButton(
            onPressed: (enabled && !loading) ? onPressed : null,
            child: child,
          ),
        );
      case ButtonVariant.negative:
        return SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: OutlinedButton(
            onPressed: (enabled && !loading) ? onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppDesignTokens.buttonNegativeContentDefault,
              side: const BorderSide(color: AppDesignTokens.buttonNegativeBorderDefault),
            ),
            child: child,
          ),
        );
      case ButtonVariant.secondary:
        return SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: FilledButton(
            onPressed: (enabled && !loading) ? onPressed : null,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: child,
          ),
        );
    }
  }
}
