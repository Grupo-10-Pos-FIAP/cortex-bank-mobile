import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

/// Cabeçalho reutilizável das telas de autenticação (login e registro).
/// Exibe logo, tagline e título.
class AuthPageHeader extends StatelessWidget {
  const AuthPageHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppDesignTokens.spacing2xl),
        Text(
          'CortexBank',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: AppDesignTokens.fontWeightBold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDesignTokens.spacingSm),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppDesignTokens.colorContentInverse,
            ),
            children: [
              const TextSpan(text: 'O futuro das suas finanças merece esse '),
              TextSpan(
                text: 'up',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: AppDesignTokens.fontWeightBold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDesignTokens.spacingXl),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppDesignTokens.colorContentInverse,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDesignTokens.spacingXl),
      ],
    );
  }
}
