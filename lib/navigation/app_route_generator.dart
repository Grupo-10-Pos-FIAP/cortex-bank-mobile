import 'package:cortex_bank_mobile/core/constants/app_routes.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/register_route_loader.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/shell/authenticated_app_shell.dart';
import 'package:cortex_bank_mobile/navigation/slide_page_route.dart';
import 'package:flutter/material.dart';

/// Gerador de rotas do [MaterialApp] (navigator raiz): splash via [home], demais por nome.
class AppRouteGenerator {
  AppRouteGenerator._();

  static const String initialRoute = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return buildSlidePageRoute(const AuthenticatedAppShell(), settings);

      case AppRoutes.login:
        return buildSlidePageRoute(const LoginPage(), settings);

      case AppRoutes.register:
        return buildSlidePageRoute(const RegisterRouteLoader(), settings);

      default:
        return buildSlidePageRoute(
          Scaffold(
            body: Center(
              child: Text('Rota não encontrada: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }
}
