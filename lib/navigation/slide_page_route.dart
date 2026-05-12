import 'package:flutter/material.dart';

/// Rota com transição slide (direita → esquerda), compartilhada entre root e navigator autenticado.
PageRouteBuilder<dynamic> buildSlidePageRoute(
  Widget page,
  RouteSettings settings,
) {
  return PageRouteBuilder<dynamic>(
    settings: settings,
    pageBuilder: (_, _, _) => page,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (_, animation, _, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
