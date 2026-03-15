import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cortex_bank_mobile/core/widgets/app_connectivity.dart';
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_form_page.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/shared/theme/app_theme.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/pages/extrato_page.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_new_form_page.dart';
import 'package:cortex_bank_mobile/core/constants/app_routes.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cortex Bank Mobile',
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ConnectivityWrapper(child: child!),
            ),
          ],
        );
      },

      initialRoute: '/',
      routes: {
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.extrato: (_) => const ExtratoPage(),
        AppRoutes.transaction: (_) => const TransactionFormPage(),
        AppRoutes.transactionNew: (_) => const TransactionNewFormPage(),
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.loading && auth.user == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.isAuthenticated ? const HomePage() : const LoginPage();
        },
      ),
    );
  }
}
