import 'package:cortex_bank_mobile/core/constants/app_routes.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/register_route_loader.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/shell/authenticated_app_shell.dart';
import 'package:cortex_bank_mobile/navigation/slide_page_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Gerador de rotas do [MaterialApp] (navigator raiz): splash via [home], demais por nome.
class AppRouteGenerator {
  AppRouteGenerator._();

  static const String initialRoute = '/';

  /// [SEGURANÇA] Conjunto de rotas que exigem autenticação ativa.
  /// Qualquer rota listada aqui redireciona para login se não houver sessão.
  static const _protectedRoutes = {'/'}; // Adicione rotas protegidas aqui.

  /// [SEGURANÇA] Conjunto de rotas exclusivas para usuários NÃO autenticados.
  /// Se um usuário já logado tentar acessá-las, é redirecionado para '/'.
  static const _guestOnlyRoutes = {AppRoutes.login, AppRoutes.register};

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    final isAuthenticated = FirebaseAuth.instance.currentUser != null;

    // [SEGURANÇA] Bloqueia acesso a rotas protegidas sem sessão ativa.
    if (_protectedRoutes.contains(name) && !isAuthenticated) {
      return buildSlidePageRoute(
        const LoginPage(),
        const RouteSettings(name: AppRoutes.login),
      );
    }

    // [SEGURANÇA] Impede que usuário autenticado acesse login/registro,
    // evitando criação de sessões duplas ou sobreposição de estado de auth.
    if (_guestOnlyRoutes.contains(name) && isAuthenticated) {
      return buildSlidePageRoute(
        const AuthenticatedAppShell(),
        const RouteSettings(name: '/'),
      );
    }

    switch (name) {
      case '/':
        return buildSlidePageRoute(const AuthenticatedAppShell(), settings);
      case AppRoutes.login:
        return buildSlidePageRoute(const LoginPage(), settings);
      case AppRoutes.register:
        return buildSlidePageRoute(const RegisterRouteLoader(), settings);
      default:
        // [SEGURANÇA] Não exibe o nome da rota na UI — vazar nomes internos
        // facilita enumeração de rotas por atacantes.
        return buildSlidePageRoute(
          const _NotFoundPage(),
          const RouteSettings(name: '/not-found'),
        );
    }
  }
}

// [SEGURANÇA] Página de rota não encontrada sem expor detalhes internos.
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Página não encontrada.')));
  }
}
