import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppCardContainer extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AppCardContainer({
    super.key,
    this.title,
    required this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppDesignTokens.colorWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppDesignTokens.colorGray200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: GoogleFonts.roboto(
                fontSize: AppDesignTokens.fontSizeTitle,
                fontWeight: AppDesignTokens.fontWeightSemibold,
                color: AppDesignTokens.colorContentDefault,
              ),
            ),
            const SizedBox(height: 24),
          ],
          child,
        ],
      ),
    );
  }
}
