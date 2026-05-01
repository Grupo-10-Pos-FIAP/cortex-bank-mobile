import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/core/constants/app_routes.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/profile_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/register_route_loader.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/pages/extrato_route_loader.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_form_page.dart';

/// Gerador de rotas com lazy instantiation e animação de slide horizontal.
class AppRouteGenerator {
  AppRouteGenerator._();

  static const String initialRoute = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _slideRoute(const LoginPage(), settings);

      case AppRoutes.register:
        return _slideRoute(const RegisterRouteLoader(), settings);

      case AppRoutes.extrato:
        return _slideRoute(const ExtratoRouteLoader(), settings);

      case AppRoutes.transaction:
        return _slideRoute(const TransactionFormPage(), settings);

      case AppRoutes.profile:
        return _slideRoute(const ProfilePage(), settings);

      default:
        return _slideRoute(
          Scaffold(
            body: Center(child: Text('Rota não encontrada: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  /// Animação de arrastar (slide) da direita para a esquerda.
  static PageRouteBuilder<dynamic> _slideRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
