import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTabs extends StatelessWidget {
  final List<String> titles;
  final List<Widget> children;
  final double? height;

  const AppTabs({
    super.key,
    required this.titles,
    required this.children,
    this.height,
  }) : assert(titles.length == children.length);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: titles.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            labelStyle: GoogleFonts.roboto(
              fontSize: AppDesignTokens.fontSizeBody,
              fontWeight: AppDesignTokens.fontWeightSemibold,
              color: AppDesignTokens.colorContentDefault,
            ),
            unselectedLabelStyle: GoogleFonts.roboto(
              fontWeight: AppDesignTokens.fontWeightRegular,
              fontSize: AppDesignTokens.fontSizeSmall,
              color: AppDesignTokens.colorGray400
            ),

            labelColor: AppDesignTokens.colorPrimary,
            unselectedLabelColor: AppDesignTokens.colorGray500,

            indicatorColor: AppDesignTokens.colorPrimary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize
                .tab,
            dividerColor:
                AppDesignTokens.colorGray200,
            labelPadding: const EdgeInsets.symmetric(vertical: 4),
            overlayColor: WidgetStateProperty.all(
              AppDesignTokens.colorPrimary,
            ),

            tabs: titles.map((title) => Tab(text: title)).toList(),
          ),

          const SizedBox(height: 16), 
          SizedBox(
            height: height ?? 200,
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
