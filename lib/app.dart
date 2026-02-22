import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_form_page.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/shared/theme/app_theme.dart';
// Ao descomentar o bloco [home] com login: adicione provider e auth_provider
import 'package:cortex_bank_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/pages/extrato_page.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_new_form_page.dart';

/// Acesso à plataforma é livre por enquanto; login/cadastro serão exigidos depois.
/// Para exigir login: descomente o bloco [home] abaixo e use initialRoute: '/login'.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'Cortex Bank Mobile',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      // Com login obrigatório: initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/extrato': (_) => const ExtratoPage(),
        '/transaction': (_) => const TransactionFormPage(),
        '/transaction/new': (_) => const TransactionNewFormPage(),
      },
      home: const HomePage(),
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
