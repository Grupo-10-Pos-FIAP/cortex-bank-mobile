import 'package:flutter/material.dart';

/// Design tokens aligned with the web design system.
/// Use these constants in theme and widgets for consistency.
class AppDesignTokens {
  AppDesignTokens._();

  // ---------------------------------------------------------------------------
  // Typography - Font sizes (logical pixels)
  // ---------------------------------------------------------------------------
  static const double fontSizeCaption = 12;
  static const double fontSizeSmall = 14;
  static const double fontSizeBody = 16;
  static const double fontSizeSubtitle = 18;
  static const double fontSizeTitle = 20;
  static const double fontSizeH4 = 22;
  static const double fontSizeH3 = 24;
  static const double fontSizeH2 = 26;
  static const double fontSizeH1 = 28;
  static const double fontSizeH5 = 30;

  // ---------------------------------------------------------------------------
  // Typography - Font weights
  // ---------------------------------------------------------------------------
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // ---------------------------------------------------------------------------
  // Typography - Line heights (multiplier)
  // ---------------------------------------------------------------------------
  static const double lineHeightCaption = 1.4;
  static const double lineHeightBody = 1.5;
  static const double lineHeightSubtitle = 1.4;
  static const double lineHeightTitle = 1.3;
  static const double lineHeightHeading = 1.2;
  static const double lineHeightTight = 1.25;
  static const double lineHeightSnug = 1.375;
  static const double lineHeightRelaxed = 1.625;
  static const double lineHeightLoose = 2;

  // ---------------------------------------------------------------------------
  // Typography - Letter spacing (logical pixels, approximate from em)
  // ---------------------------------------------------------------------------
  static double letterSpacingTightest(double fontSize) => fontSize * -0.015;
  static double letterSpacingTight(double fontSize) => fontSize * -0.005;
  static const double letterSpacingNormal = 0;
  static double letterSpacingRelaxed(double fontSize) => fontSize * 0.015;
  static double letterSpacingWide(double fontSize) => fontSize * 0.03;
  static double letterSpacingWider(double fontSize) => fontSize * 0.05;

  // ---------------------------------------------------------------------------
  // Absolute colors
  // ---------------------------------------------------------------------------
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color colorBlack = Color(0xFF000000);

  // ---------------------------------------------------------------------------
  // Gray scale
  // ---------------------------------------------------------------------------
  static const Color colorGray100 = Color(0xFFF8F9FA);
  static const Color colorGray200 = Color(0xFFE0E0E0);
  static const Color colorGray300 = Color(0xFFC0C0C0);
  static const Color colorGray400 = Color(0xFFA0A0A0);
  static const Color colorGray500 = Color(0xFF808080);
  static const Color colorGray600 = Color(0xFF606060);
  static const Color colorGray700 = Color(0xFF404040);
  static const Color colorGray800 = Color(0xFF202020);
  static const Color colorGray900 = Color(0xFF101010);

  // ---------------------------------------------------------------------------
  // Brand palette
  // ---------------------------------------------------------------------------
  static const Color colorBase = Color(0xFF1A1A1A);
  static const Color colorPrimary = Color(0xFF1C6EA4);
  static const Color colorSecondary = Color(0xFF658864);
  static const Color colorNeutral = colorGray300;
  static const Color colorSoft = Color(0xFFE1F0FB);

  // ---------------------------------------------------------------------------
  // Backgrounds
  // ---------------------------------------------------------------------------
  /// Background padrão do app (telas de login e cadastro). Sempre esta escala.
  static const Color colorBgDefault = Color(0xFFF5F5F5);
  static const Color colorBgLight = colorWhite;
  static const Color colorBgPrimary = colorPrimary;
  static const Color colorBgSecondary = colorSecondary;
  static const Color colorBgDisabled = colorGray200;
  static const Color colorBgHovered = colorSoft;
  static const Color colorBgOverlay = Color(0xCCFFFFFF);
  static const Color colorBgFullscreen = Color(0xE6FFFFFF);

  // ---------------------------------------------------------------------------
  // Content
  // ---------------------------------------------------------------------------
  static const Color colorContentDefault = colorBase;
  static const Color colorContentInverse = colorWhite;
  static const Color colorContentDisabled = colorGray500;

  // ---------------------------------------------------------------------------
  // Borders
  // ---------------------------------------------------------------------------
  static const Color colorBorderDefault = colorNeutral;
  static const Color colorBorderDisabled = Color(0x00FFFFFF);
  static const Color colorBorderFocused = colorPrimary;
  static const Color colorBorderHovered = colorNeutral;

  // ---------------------------------------------------------------------------
  // Links
  // ---------------------------------------------------------------------------
  static const Color colorLink = Color(0xFF1C6EA4);
  static const Color colorLinkHover = Color(0xFF144B70);
  static const Color colorLinkVisited = Color(0xFF0F3C5C);

  // ---------------------------------------------------------------------------
  // System feedback
  // ---------------------------------------------------------------------------
  static const Color colorFeedbackSuccess = Color(0xFF81BE7F);
  static const Color colorFeedbackWarning = Color(0xFFDEBB51);
  static const Color colorFeedbackError = Color(0xFFE53935);
  static const Color colorFeedbackInfo = Color(0xFF1C6EA4);
  static const Color colorFeedbackAlert = Color(0xFFD32F2F);
  static const Color colorFeedbackMuted = colorGray100;

  // ---------------------------------------------------------------------------
  // Spacing
  // ---------------------------------------------------------------------------
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2xl = 48;
  static const double spacing3xl = 64;

  // ---------------------------------------------------------------------------
  // Border radius & width
  // ---------------------------------------------------------------------------
  static const double borderRadiusDefault = spacingSm;
  static const double borderWidthDefault = 1;
  static const double borderWidthSmall = 2;
  static const double borderWidthMedium = 3;
  static const double borderWidthLarge = spacingXs;

  // ---------------------------------------------------------------------------
  // Breakpoints (logical pixels)
  // ---------------------------------------------------------------------------
  static const double breakpointMobile = 480;
  static const double breakpointTablet = 768;
  static const double breakpointDesktop = 1024;
  static const double breakpointWidescreen = 1200;

  // ---------------------------------------------------------------------------
  // Z-index
  // ---------------------------------------------------------------------------
  static const int zIndexDropdown = 1000;
  static const int zIndexSticky = 1020;
  static const int zIndexFixed = 1030;
  static const int zIndexModalBackdrop = 1040;
  static const int zIndexModal = 1050;
  static const int zIndexPopover = 1060;
  static const int zIndexTooltip = 1070;
  static const int zIndexLoading = 9999;

  // ---------------------------------------------------------------------------
  // Button - Brand
  // ---------------------------------------------------------------------------
  static const Color buttonBrandBgDefault = Color(0xFF1C6EA4);
  static const Color buttonBrandBgHovered = Color(0xFF2395DF);
  static const Color buttonBrandBgPressed = Color(0xFF0C4165);
  static const Color buttonBrandBgDisabled = Color(0xFFCDE6F6);
  static const Color buttonBrandContentDefault = colorWhite;
  static const Color buttonBrandContentDisabled = colorWhite;

  // ---------------------------------------------------------------------------
  // Button - Secondary
  // ---------------------------------------------------------------------------
  static const Color buttonSecondaryBgDefault = Color(0xFF658864);
  static const Color buttonSecondaryBgHovered = Color(0xFF81BE7F);
  static const Color buttonSecondaryBgPressed = Color(0xFF2C4D2B);
  static const Color buttonSecondaryBgDisabled = Color(0xFFD6EED6);
  static const Color buttonSecondaryContentDefault = colorWhite;
  static const Color buttonSecondaryContentDisabled = colorWhite;

  // ---------------------------------------------------------------------------
  // Button - Outlined
  // ---------------------------------------------------------------------------
  static const Color buttonOutlinedBgDefault = Colors.transparent;
  static const Color buttonOutlinedBgHovered = Color(0xFFFAFAFA);
  static const Color buttonOutlinedBgPressed = Color(0xFF3A3C3C);
  static const Color buttonOutlinedBgDisabled = Colors.transparent;
  static const Color buttonOutlinedBorderDefault = Color(0x331A1A1A);
  static const Color buttonOutlinedBorderHovered = Color(0xCC1A1A1A);
  static const Color buttonOutlinedBorderPressed = Color(0xCC1A1A1A);
  static const Color buttonOutlinedBorderDisabled = Color(0x1A1A1A1A);
  static const Color buttonOutlinedContentDefault = Color(0xFF555555);
  static const Color buttonOutlinedContentHovered = colorBase;
  static const Color buttonOutlinedContentPressed = colorWhite;
  static const Color buttonOutlinedContentDisabled = Color(0xFFC2C2C2);

  // ---------------------------------------------------------------------------
  // Button - Negative (e.g. on dark background)
  // ---------------------------------------------------------------------------
  static const Color buttonNegativeBgDefault = Colors.transparent;
  static const Color buttonNegativeBgHovered = colorBase;
  static const Color buttonNegativeBgPressed = colorBlack;
  static const Color buttonNegativeBgDisabled = Colors.transparent;
  static const Color buttonNegativeBorderDefault = colorWhite;
  static const Color buttonNegativeBorderHovered = Color(0xFF555555);
  static const Color buttonNegativeBorderPressed = colorBase;
  static const Color buttonNegativeBorderDisabled = colorWhite;
  static const Color buttonNegativeContentDefault = colorWhite;
  static const Color buttonNegativeContentDisabled = colorWhite;

  // ---------------------------------------------------------------------------
  // List item
  // ---------------------------------------------------------------------------
  static const Color listItemContentActived = Color(0xFF2563EB);
  static const Color listItemBgHovered = Color(0xFFF3F4F6);
}
