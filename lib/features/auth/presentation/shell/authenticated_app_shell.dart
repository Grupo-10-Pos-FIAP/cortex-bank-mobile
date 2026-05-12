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
class AuthenticatedAppShell extends StatefulWidget {
  const AuthenticatedAppShell({super.key});

  @override
  State<AuthenticatedAppShell> createState() => _AuthenticatedAppShellState();
}

class _AuthenticatedAppShellState extends State<AuthenticatedAppShell> {
  late final AuthProvider _auth;
  late final TransactionsNotifier _transactions;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
    _transactions = TransactionsNotifier(getIt<ITransactionsRepository>());
    _syncTransactions();
    _auth.addListener(_syncTransactions);
  }

  void _syncTransactions() {
    _transactions.syncAuthUserId(_auth.user?.uid);
  }

  @override
  void dispose() {
    _auth.removeListener(_syncTransactions);
    _transactions.dispose();
    super.dispose();
  }

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
        StateNotifierProvider<TransactionsNotifier, TransactionsState>.value(
          value: _transactions,
        ),
      ],
      child: Navigator(
        onGenerateRoute: AuthenticatedNavigator.onGenerateRoute,
      ),
    );
  }
}
