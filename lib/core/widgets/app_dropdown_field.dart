import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String? label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final bool showRequiredIndicator;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final Key? formFieldKey;
  final Color? fillColor;
  final bool enabled;
  // Nova prop decoration
  final InputDecoration? decoration;

  const AppDropdownField({
    super.key,
    this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.showRequiredIndicator = false,
    this.autofocus = false,
    this.focusNode,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.formFieldKey,
    this.fillColor,
    this.enabled = true,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final defaultLabelStyle = textTheme.bodyMedium?.copyWith(
      color: AppDesignTokens.colorContentDefault,
      fontWeight: AppDesignTokens.fontWeightMedium,
      fontSize: AppDesignTokens.fontSizeSmall,
    );

    // Estilo que replica o TextField solicitado
    final defaultDecoration = InputDecoration(
      hintText: hintText,
      hintStyle:
          hintStyle ??
          textTheme.bodyMedium?.copyWith(
            color: AppDesignTokens.colorContentSecondary,
          ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? AppDesignTokens.colorWhite,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacingMd,
        vertical: AppDesignTokens.spacingSm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDesignTokens.borderRadiusDefault,
        ),
        borderSide: const BorderSide(color: AppDesignTokens.colorBorderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDesignTokens.borderRadiusDefault,
        ),
        borderSide: const BorderSide(color: AppDesignTokens.colorBorderDefault),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDesignTokens.borderRadiusDefault,
        ),
        borderSide: const BorderSide(color: AppDesignTokens.colorFeedbackError),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Row(
            children: [
              Text(label!, style: labelStyle ?? defaultLabelStyle),
              if (showRequiredIndicator)
                const Text(
                  ' *',
                  style: TextStyle(color: AppDesignTokens.colorFeedbackError),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppDesignTokens.spacingSm),
        DropdownButtonFormField<T>(
          key: formFieldKey,
          initialValue: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          focusNode: focusNode,
          autofocus: autofocus,
          style:
              style ??
              textTheme.bodyLarge?.copyWith(
                color: AppDesignTokens.colorContentDefault,
              ),
          // Prioriza a prop decoration, senão usa o estilo padrão ajustado
          decoration: decoration ?? defaultDecoration,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          // Garante que o menu suspenso também tenha bordas arredondadas se o Flutter suportar
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusDefault,
          ),
        ),
      ],
    );
  }
}
