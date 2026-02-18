import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/core/theme/app_theme.dart';
// Ao descomentar o bloco [home] com login: adicione provider e auth_provider
import 'package:cortex_bank_mobile/features/auth/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/auth/pages/register_page.dart';
import 'package:cortex_bank_mobile/features/extrato/pages/extrato_page.dart';
import 'package:cortex_bank_mobile/features/transaction/pages/transaction_form_page.dart';

/// Acesso à plataforma é livre por enquanto; login/cadastro serão exigidos depois.
/// Para exigir login: descomente o bloco [home] abaixo e use initialRoute: '/login'.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cortex Bank Mobile',
      theme: AppTheme.lightTheme,
      initialRoute: '/extrato',
      // Com login obrigatório: initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/extrato': (_) => const ExtratoPage(),
        '/transaction/new': (_) => const TransactionFormPage(),
      },
      home: const ExtratoPage(),
      // --- Código de login (descomente para exigir autenticação; adicione imports provider + auth_provider) ---
      // home: Consumer<AuthProvider>(
      //   builder: (context, auth, _) {
      //     if (auth.loading && auth.user == null) {
      //       return const Scaffold(
      //         body: Center(child: CircularProgressIndicator()),
      //       );
      //     }
      //     return auth.isAuthenticated
      //         ? const ExtratoPage()
      //         : const LoginPage();
      //   },
      // ),
    );
  }
}
