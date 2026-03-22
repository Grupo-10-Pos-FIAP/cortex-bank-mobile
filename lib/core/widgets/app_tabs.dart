import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTabs extends StatelessWidget {
  final List<String> titles;
  final List<Widget> children;
  final double? height;
  final double marginTop;

  const AppTabs({
    super.key,
    required this.titles,
    required this.children,
    this.height,
    this.marginTop = 0,
  }) : assert(titles.length == children.length);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: titles.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (marginTop > 0) SizedBox(height: marginTop),
          TabBar(
            labelStyle: GoogleFonts.roboto(
              fontSize: AppDesignTokens.fontSizeBody,
              fontWeight: AppDesignTokens.fontWeightSemibold,
              color: AppDesignTokens.colorContentDefault,
            ),
            unselectedLabelStyle: GoogleFonts.roboto(
              fontWeight: AppDesignTokens.fontWeightRegular,
              fontSize: AppDesignTokens.fontSizeSmall,
              color: AppDesignTokens.colorGray400,
            ),
            labelColor: AppDesignTokens.colorPrimary,
            unselectedLabelColor: AppDesignTokens.colorGray500,
            indicatorColor: AppDesignTokens.colorPrimary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: AppDesignTokens.colorGray200,
            labelPadding: kIsWeb
                ? const EdgeInsets.symmetric(horizontal: 4)
                : const EdgeInsets.symmetric(vertical: 4),
            indicatorPadding: EdgeInsets.zero,
            splashFactory: kIsWeb ? NoSplash.splashFactory : null,
            overlayColor: kIsWeb
                ? WidgetStateProperty.all(Colors.transparent)
                : WidgetStateProperty.all(AppDesignTokens.colorPrimary),
            tabs: kIsWeb
                ? List.generate(
                    titles.length,
                    (i) => Tab(
                      child: _WebHoverTabLabel(
                        index: i,
                        title: titles[i],
                      ),
                    ),
                  )
                : titles.map((title) => Tab(text: title)).toList(),
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

class _WebHoverTabLabel extends StatefulWidget {
  const _WebHoverTabLabel({
    required this.index,
    required this.title,
  });

  final int index;
  final String title;

  @override
  State<_WebHoverTabLabel> createState() => _WebHoverTabLabelState();
}

class _WebHoverTabLabelState extends State<_WebHoverTabLabel> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final selected = controller.index == widget.index;
        final TextStyle style;
        if (_hovering) {
          style = GoogleFonts.roboto(
            fontSize: selected
                ? AppDesignTokens.fontSizeBody
                : AppDesignTokens.fontSizeSmall,
            fontWeight: selected
                ? AppDesignTokens.fontWeightSemibold
                : AppDesignTokens.fontWeightRegular,
            color: AppDesignTokens.colorWhite,
          );
        } else if (selected) {
          style = GoogleFonts.roboto(
            fontSize: AppDesignTokens.fontSizeBody,
            fontWeight: AppDesignTokens.fontWeightSemibold,
            color: AppDesignTokens.colorPrimary,
          );
        } else {
          style = GoogleFonts.roboto(
            fontSize: AppDesignTokens.fontSizeSmall,
            fontWeight: AppDesignTokens.fontWeightRegular,
            color: AppDesignTokens.colorGray500,
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.hasBoundedHeight &&
                    constraints.maxHeight.isFinite &&
                    constraints.maxHeight > 0
                ? constraints.maxHeight
                : kMinInteractiveDimension;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              hitTestBehavior: HitTestBehavior.opaque,
              onEnter: (_) => setState(() => _hovering = true),
              onExit: (_) => setState(() => _hovering = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                width: w.isFinite ? w : null,
                height: h,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _hovering
                      ? AppDesignTokens.colorPrimary
                      : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
                child: Text(widget.title, style: style),
              ),
            );
          },
        );
      },
    );
  }
}
