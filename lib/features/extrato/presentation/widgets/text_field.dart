import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

class AppTextFieldDecorator extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final bool enabled;

  const AppTextFieldDecorator({
    super.key,
    required this.label,
    this.hintText = 'R\$ 0,00',
    this.controller,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // Usa o formatador de moeda que você já possui
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyBRLInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
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
