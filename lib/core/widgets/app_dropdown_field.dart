import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
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
    this.enabled = true,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final TextInputAction? textInputAction;
  final void Function(T?)? onFieldSubmitted;
  final bool showRequiredIndicator;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final Key? formFieldKey;
  final Color? fillColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    final textTheme = theme.textTheme;

    final defaultLabelStyle =
        textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: AppDesignTokens.fontWeightMedium,
          fontSize: AppDesignTokens.fontSizeSmall,
        ) ??
        TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: AppDesignTokens.fontWeightMedium,
          fontSize: AppDesignTokens.fontSizeSmall,
        );

    final requiredIndicatorStyle =
        textTheme.bodyMedium?.copyWith(
          color: AppDesignTokens.colorFeedbackError,
          fontSize: AppDesignTokens.fontSizeSmall,
        ) ??
        const TextStyle(
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
            Text(label, style: labelStyle ?? defaultLabelStyle),
            if (showRequiredIndicator)
              Padding(
                padding: const EdgeInsets.only(left: AppDesignTokens.spacingXs),
                child: Text('*', style: requiredIndicatorStyle),
              ),
          ],
        ),
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
          decoration: decoration,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
        ),
      ],
    );
  }
}
