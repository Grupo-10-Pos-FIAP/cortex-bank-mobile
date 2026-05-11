import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';

ThemeData integrationTestTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppDesignTokens.colorPrimary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppDesignTokens.colorBgLight,
  );
}
