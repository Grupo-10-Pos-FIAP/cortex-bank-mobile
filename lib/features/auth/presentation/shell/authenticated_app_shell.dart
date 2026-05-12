import 'package:cortex_bank_mobile/core/di/injection.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/features/contacts/domain/repositories/i_contacts_repository.dart';
import 'package:cortex_bank_mobile/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/repositories/i_transactions_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/providers/transactions_notifier.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/state/transactions_state.dart';
import 'package:cortex_bank_mobile/navigation/authenticated_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart';

/// Shell do fluxo autenticado: providers de dados da sessão + [Navigator] interno.
class AuthenticatedAppShell extends StatelessWidget {
  const AuthenticatedAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<AuthProvider, ContactsProvider>(
          create: (_) => ContactsProvider(getIt<IContactsRepository>()),
          update: (_, auth, contacts) {
            contacts!.syncAuthUserId(auth.user?.uid);
            return contacts;
          },
        ),
        ProxyProvider<AuthProvider, TransactionsNotifier>(
          create: (_) => TransactionsNotifier(getIt<ITransactionsRepository>()),
          update: (_, auth, previous) {
            previous!.syncAuthUserId(auth.user?.uid);
            return previous;
          },
          dispose: (_, notifier) => notifier.dispose(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return StateNotifierProvider<
            TransactionsNotifier,
            TransactionsState
          >.value(
            value: context.read<TransactionsNotifier>(),
            child: Navigator(
              onGenerateRoute: AuthenticatedNavigator.onGenerateRoute,
            ),
          );
        },
      ),
    );
  }
}
