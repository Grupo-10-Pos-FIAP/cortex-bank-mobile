import 'dart:async';

import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/domain/entities/user.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/providers/transactions_notifier.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/state/transactions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

Widget _buildGate(AuthProvider authProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      StateNotifierProvider<TransactionsNotifier, TransactionsState>(
        create: (_) => TransactionsNotifier(FakeTransactionsRepository()),
      ),
      ChangeNotifierProvider<ContactsProvider>(
        create: (_) => ContactsProvider(FakeContactsRepository()),
      ),
    ],
    child: MaterialApp(
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.loading && auth.user == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.isAuthenticated
              ? const Scaffold(body: Text('Home gate opened'))
              : const LoginPage();
        },
      ),
    ),
  );
}

void main() {
  group('Auth gate', () {
    testWidgets(
      'deve exibir loading quando autenticação estiver em andamento sem usuário',
      (tester) async {
        final repo = FakeAuthRepository()
          ..signInCompleter = Completer<Result<User>>();
        final provider = AuthProvider(repo);

        await tester.pumpWidget(_buildGate(provider));
        await tester.pump();

        final signInFuture = provider.signIn('ana@example.com', '123456');
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        repo.signInCompleter!.complete(Success(buildUser()));
        await signInFuture;
        await tester.pump();
        await pumpUntilFound(tester, find.text('Home gate opened'));

        expect(find.text('Home gate opened'), findsOneWidget);
      },
    );

    testWidgets('deve exibir LoginPage quando não autenticado', (tester) async {
      final provider = AuthProvider(FakeAuthRepository());

      await tester.pumpWidget(_buildGate(provider));

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('deve exibir home quando autenticado', (tester) async {
      final repo = FakeAuthRepository()..signInResult = Success(buildUser());
      final provider = AuthProvider(repo);
      await provider.signIn('ana@example.com', '123456');

      await tester.pumpWidget(_buildGate(provider));
      await tester.pump();

      expect(find.text('Home gate opened'), findsOneWidget);
    });
  });
}
