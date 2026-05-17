import 'package:cortex_bank_mobile/core/constants/app_routes.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/profile_page.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/pages/extrato_route_loader.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/home_page.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_form_page.dart';
import 'package:cortex_bank_mobile/navigation/slide_page_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Rotas do [Navigator] interno ao fluxo autenticado (abaixo do [AuthenticatedAppShell]).
class AuthenticatedNavigator {
  AuthenticatedNavigator._();

  // [SEGURANÇA] Segunda barreira de autenticação: mesmo que o roteador raiz
  // falhe em bloquear o acesso, este navigator rejeita qualquer navegação
  // interna sem sessão ativa (defesa em profundidade).
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // [SEGURANÇA] Verifica sessão a cada navegação interna, não apenas na
    // entrada do shell. Detecta expiração de sessão durante o uso do app.
    if (FirebaseAuth.instance.currentUser == null) {
      return buildSlidePageRoute(
        const _SessionExpiredPage(),
        const RouteSettings(name: '/session-expired'),
      );
    }

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
        // [SEGURANÇA] Não expõe o nome da rota tentada — evita enumeração
        // de rotas internas por atacantes via deep links maliciosos.
        return buildSlidePageRoute(
          const _NotFoundPage(),
          const RouteSettings(name: '/not-found'),
        );
    }
  }
}

// [SEGURANÇA] Exibida quando a sessão expirou durante o uso do app.
// Redireciona para login sem expor detalhes do estado interno.
class _SessionExpiredPage extends StatefulWidget {
  const _SessionExpiredPage();

  @override
  State<_SessionExpiredPage> createState() => _SessionExpiredPageState();
}

class _SessionExpiredPageState extends State<_SessionExpiredPage> {
  @override
  void initState() {
    super.initState();
    // Navega para login no próximo frame, após a árvore de widgets ser montada.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil('/login', (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
