import 'package:cortex_bank_mobile/core/constants/app_routes.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/profile_page.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/pages/extrato_route_loader.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/home_page.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_form_page.dart';
import 'package:cortex_bank_mobile/navigation/slide_page_route.dart';
import 'package:flutter/material.dart';

/// Rotas do [Navigator] interno ao fluxo autenticado (abaixo do [AuthenticatedAppShell]).
class AuthenticatedNavigator {
  AuthenticatedNavigator._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    switch (name) {
      case '/':
        return buildSlidePageRoute(const HomePage(), settings);

      case AppRoutes.extrato:
        return buildSlidePageRoute(const ExtratoRouteLoader(), settings);

      case AppRoutes.transaction:
        return buildSlidePageRoute(const TransactionFormPage(), settings);

      case AppRoutes.profile:
        return buildSlidePageRoute(const ProfilePage(), settings);

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
