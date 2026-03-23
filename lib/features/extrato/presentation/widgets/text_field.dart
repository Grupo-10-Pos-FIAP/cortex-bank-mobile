import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

class AppTextFieldDecorator extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final bool enabled;
  /// Quando falso, usa teclado de texto e sem formatação de moeda (ex.: descrição).
  final bool isCurrency;
  final int? maxLines;

  const AppTextFieldDecorator({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.isCurrency = true,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHint = hintText ?? (isCurrency ? 'R\$ 0,00' : null);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: isCurrency
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: maxLines ?? 1,
      inputFormatters: isCurrency
          ? [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyBRLInputFormatter(),
            ]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: effectiveHint,
        filled: true,
        fillColor: AppDesignTokens.colorWhite,

        labelStyle: TextStyle(
          color: AppDesignTokens.colorContentDefault,
          fontSize: AppDesignTokens.fontSizeSmall,
        ),
        // Bordas padronizadas
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusDefault,
          ),
          borderSide: const BorderSide(
            color: AppDesignTokens.colorBorderDefault,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusDefault,
          ),
          borderSide: const BorderSide(
            color: AppDesignTokens.colorBorderDefault,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusDefault,
          ),
          borderSide: const BorderSide(
            color: AppDesignTokens.colorPrimary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
