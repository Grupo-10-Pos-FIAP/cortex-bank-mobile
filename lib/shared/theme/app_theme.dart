import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

class AppTheme {
  AppTheme._();

  /// Light theme aligned with web design system (bg-default white, content base).
  static ThemeData get lightTheme {
    final baseTextTheme = _buildBaseTextTheme();
    final textTheme = GoogleFonts.robotoTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.roboto().fontFamily,
      colorScheme: ColorScheme.light(
        primary: AppDesignTokens.colorPrimary,
        secondary: AppDesignTokens.colorSecondary,
        error: AppDesignTokens.colorFeedbackError,
        surface: AppDesignTokens.colorBgLight,
        onSurface: AppDesignTokens.colorContentDefault,
        onPrimary: AppDesignTokens.colorContentInverse,
        outline: AppDesignTokens.colorBorderDefault,
      ),
      scaffoldBackgroundColor: AppDesignTokens.colorBgLight,
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDesignTokens.colorWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
          borderSide: const BorderSide(color: AppDesignTokens.colorBorderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
          borderSide: const BorderSide(color: AppDesignTokens.colorBorderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
          borderSide: const BorderSide(
            color: AppDesignTokens.colorBorderFocused,
            width: AppDesignTokens.borderWidthSmall,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
          borderSide: const BorderSide(color: AppDesignTokens.colorFeedbackError),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDesignTokens.spacingMd,
          vertical: AppDesignTokens.spacingMd,
        ),
        hintStyle: TextStyle(
          color: AppDesignTokens.colorContentDisabled,
          fontSize: AppDesignTokens.fontSizeSmall,
          fontWeight: AppDesignTokens.fontWeightRegular,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDesignTokens.buttonBrandBgDefault,
          foregroundColor: AppDesignTokens.buttonBrandContentDefault,
          disabledBackgroundColor: AppDesignTokens.buttonBrandBgDisabled,
          disabledForegroundColor: AppDesignTokens.buttonBrandContentDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppDesignTokens.spacingMd),
          textStyle: TextStyle(
            fontSize: AppDesignTokens.fontSizeBody,
            fontWeight: AppDesignTokens.fontWeightSemibold,
            fontFamily: GoogleFonts.roboto().fontFamily,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppDesignTokens.buttonBrandBgDisabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppDesignTokens.buttonBrandBgPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return AppDesignTokens.buttonBrandBgHovered;
            }
            return AppDesignTokens.buttonBrandBgDefault;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppDesignTokens.buttonBrandContentDisabled;
            }
            return AppDesignTokens.buttonBrandContentDefault;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppDesignTokens.buttonOutlinedContentDefault,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppDesignTokens.spacingMd),
          textStyle: TextStyle(
            fontSize: AppDesignTokens.fontSizeBody,
            fontWeight: AppDesignTokens.fontWeightSemibold,
            fontFamily: GoogleFonts.roboto().fontFamily,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppDesignTokens.buttonOutlinedBgDisabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppDesignTokens.buttonOutlinedBgPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return AppDesignTokens.buttonOutlinedBgHovered;
            }
            return AppDesignTokens.buttonOutlinedBgDefault;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppDesignTokens.buttonOutlinedContentDisabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppDesignTokens.buttonOutlinedContentPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return AppDesignTokens.buttonOutlinedContentHovered;
            }
            return AppDesignTokens.buttonOutlinedContentDefault;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: AppDesignTokens.buttonOutlinedBorderDisabled);
            }
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered)) {
              return const BorderSide(color: AppDesignTokens.buttonOutlinedBorderHovered);
            }
            return const BorderSide(color: AppDesignTokens.buttonOutlinedBorderDefault);
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppDesignTokens.colorLink,
          textStyle: TextStyle(
            fontSize: AppDesignTokens.fontSizeBody,
            fontFamily: GoogleFonts.roboto().fontFamily,
          ),
        ),
      ),
    );
  }

  /// Base TextTheme with design token sizes, weights, heights (no font family).
  static TextTheme _buildBaseTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: AppDesignTokens.fontSizeH1,
        fontWeight: AppDesignTokens.fontWeightBold,
        height: AppDesignTokens.lineHeightHeading,
        color: AppDesignTokens.colorContentDefault,
      ),
      displayMedium: TextStyle(
        fontSize: AppDesignTokens.fontSizeH2,
        fontWeight: AppDesignTokens.fontWeightBold,
        height: AppDesignTokens.lineHeightHeading,
        color: AppDesignTokens.colorContentDefault,
      ),
      displaySmall: TextStyle(
        fontSize: AppDesignTokens.fontSizeH3,
        fontWeight: AppDesignTokens.fontWeightBold,
        height: AppDesignTokens.lineHeightHeading,
        color: AppDesignTokens.colorContentDefault,
      ),
      headlineLarge: TextStyle(
        fontSize: AppDesignTokens.fontSizeH1,
        fontWeight: AppDesignTokens.fontWeightBold,
        height: AppDesignTokens.lineHeightHeading,
        color: AppDesignTokens.colorContentDefault,
      ),
      headlineMedium: TextStyle(
        fontSize: AppDesignTokens.fontSizeH2,
        fontWeight: AppDesignTokens.fontWeightBold,
        height: AppDesignTokens.lineHeightHeading,
        color: AppDesignTokens.colorContentDefault,
      ),
      headlineSmall: TextStyle(
        fontSize: AppDesignTokens.fontSizeH4,
        fontWeight: AppDesignTokens.fontWeightBold,
        height: AppDesignTokens.lineHeightHeading,
        color: AppDesignTokens.colorContentDefault,
      ),
      titleLarge: TextStyle(
        fontSize: AppDesignTokens.fontSizeSubtitle,
        fontWeight: AppDesignTokens.fontWeightSemibold,
        height: AppDesignTokens.lineHeightSubtitle,
        color: AppDesignTokens.colorContentDefault,
      ),
      titleMedium: TextStyle(
        fontSize: AppDesignTokens.fontSizeTitle,
        fontWeight: AppDesignTokens.fontWeightSemibold,
        height: AppDesignTokens.lineHeightTitle,
        color: AppDesignTokens.colorContentDefault,
      ),
      titleSmall: TextStyle(
        fontSize: AppDesignTokens.fontSizeSubtitle,
        fontWeight: AppDesignTokens.fontWeightMedium,
        height: AppDesignTokens.lineHeightSubtitle,
        color: AppDesignTokens.colorContentDefault,
      ),
      bodyLarge: TextStyle(
        fontSize: AppDesignTokens.fontSizeBody,
        fontWeight: AppDesignTokens.fontWeightRegular,
        height: AppDesignTokens.lineHeightBody,
        color: AppDesignTokens.colorContentDefault,
      ),
      bodyMedium: TextStyle(
        fontSize: AppDesignTokens.fontSizeSmall,
        fontWeight: AppDesignTokens.fontWeightRegular,
        height: AppDesignTokens.lineHeightBody,
        color: AppDesignTokens.colorContentDefault,
      ),
      bodySmall: TextStyle(
        fontSize: AppDesignTokens.fontSizeCaption,
        fontWeight: AppDesignTokens.fontWeightRegular,
        height: AppDesignTokens.lineHeightCaption,
        color: AppDesignTokens.colorContentDefault,
      ),
      labelLarge: TextStyle(
        fontSize: AppDesignTokens.fontSizeBody,
        fontWeight: AppDesignTokens.fontWeightSemibold,
        height: AppDesignTokens.lineHeightBody,
        color: AppDesignTokens.colorContentDefault,
      ),
      labelMedium: TextStyle(
        fontSize: AppDesignTokens.fontSizeSmall,
        fontWeight: AppDesignTokens.fontWeightMedium,
        height: AppDesignTokens.lineHeightBody,
        color: AppDesignTokens.colorContentDefault,
      ),
      labelSmall: TextStyle(
        fontSize: AppDesignTokens.fontSizeCaption,
        fontWeight: AppDesignTokens.fontWeightMedium,
        height: AppDesignTokens.lineHeightCaption,
        color: AppDesignTokens.colorContentDefault,
      ),
    );
  }

  // Legacy aliases for existing code that references AppTheme.primaryBlue etc.
  static const Color primaryBlue = AppDesignTokens.colorPrimary;
  static const Color secondaryGreen = AppDesignTokens.colorSecondary;
  static const Color baseDark = AppDesignTokens.colorBase;
  static const Color errorRed = AppDesignTokens.colorFeedbackError;
  static const Color successGreen = AppDesignTokens.colorFeedbackSuccess;
  static const double spacingXS = AppDesignTokens.spacingXs;
  static const double spacingSM = AppDesignTokens.spacingSm;
  static const double spacingMD = AppDesignTokens.spacingMd;
  static const double spacingLG = AppDesignTokens.spacingLg;
  static const double spacingXL = AppDesignTokens.spacingXl;
  static const double spacing2XL = AppDesignTokens.spacing2xl;
  static const double borderRadius = AppDesignTokens.borderRadiusDefault;
}
