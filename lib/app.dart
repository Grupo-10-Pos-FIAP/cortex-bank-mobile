import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/core/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/features/auth/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/extrato/pages/extrato_page.dart';
import 'package:cortex_bank_mobile/features/transaction/pages/transaction_form_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cortex Bank Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/extrato': (_) => const ExtratoPage(),
        '/transaction/new': (_) => const TransactionFormPage(),
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.loading && auth.user == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.isAuthenticated
              ? const ExtratoPage()
              : const LoginPage();
        },
      ),
    );
  }
}
