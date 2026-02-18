import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/core/theme/app_design_tokens.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.textInputAction,
    this.onFieldSubmitted,
    this.showRequiredIndicator = false,
    this.autofocus = false,
    this.focusNode,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.formFieldKey,
    this.fillColor,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool showRequiredIndicator;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final Key? formFieldKey;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    final textTheme = theme.textTheme;

    final defaultLabelStyle = textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: AppDesignTokens.fontWeightMedium,
      fontSize: AppDesignTokens.fontSizeSmall,
    ) ?? TextStyle(
      color: theme.colorScheme.onSurface,
      fontWeight: AppDesignTokens.fontWeightMedium,
      fontSize: AppDesignTokens.fontSizeSmall,
    );

    final requiredIndicatorStyle = textTheme.bodyMedium?.copyWith(
      color: AppDesignTokens.colorFeedbackError,
      fontSize: AppDesignTokens.fontSizeSmall,
    ) ?? const TextStyle(
      color: AppDesignTokens.colorFeedbackError,
      fontSize: AppDesignTokens.fontSizeSmall,
    );

    final decoration = InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle ?? inputTheme.hintStyle,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: inputTheme.filled,
      fillColor: fillColor ?? inputTheme.fillColor,
      border: inputTheme.border,
      enabledBorder: inputTheme.enabledBorder,
      focusedBorder: inputTheme.focusedBorder,
      errorBorder: inputTheme.errorBorder,
      contentPadding: inputTheme.contentPadding,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: labelStyle ?? defaultLabelStyle,
            ),
            if (showRequiredIndicator)
              Padding(
                padding: const EdgeInsets.only(left: AppDesignTokens.spacingXs),
                child: Text(
                  '*',
                  style: requiredIndicatorStyle,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDesignTokens.spacingSm),
        TextFormField(
          key: formFieldKey,
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          autofocus: autofocus,
          style: style ?? textTheme.bodyLarge?.copyWith(
            color: AppDesignTokens.colorContentDefault,
          ),
          decoration: decoration,
        ),
      ],
    );
  }
}
