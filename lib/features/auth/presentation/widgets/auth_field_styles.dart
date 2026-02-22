import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

/// Estilos comuns dos campos de formulário nas telas de login e registro.
/// Centraliza cores e tipografia para manter consistência e facilitar manutenção.
class AuthFieldStyles {
  AuthFieldStyles._();

  static TextStyle labelStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppDesignTokens.colorContentInverse,
            fontWeight: AppDesignTokens.fontWeightMedium,
          ) ??
      const TextStyle(
        color: AppDesignTokens.colorContentInverse,
        fontWeight: AppDesignTokens.fontWeightMedium,
      );

  static TextStyle inputStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppDesignTokens.colorContentInverse,
          ) ??
      const TextStyle(color: AppDesignTokens.colorContentInverse);

  static TextStyle hintStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppDesignTokens.colorGray400,
          ) ??
      const TextStyle(color: AppDesignTokens.colorGray400);
}
