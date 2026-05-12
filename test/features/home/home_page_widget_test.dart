import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/home_page.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_form_page.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/providers/transactions_notifier.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/state/transactions_state.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

Widget _buildHomeShell() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(FakeAuthRepository())),
      StateNotifierProvider<TransactionsNotifier, TransactionsState>(
        create: (_) => TransactionsNotifier(FakeTransactionsRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => ContactsProvider(FakeContactsRepository()),
      ),
    ],
    child: const MaterialApp(home: HomePage()),
  );
}

void main() {
  group('HomePage', () {
    testWidgets('deve exibir app bar, título e abas principais', (
      tester,
    ) async {
      await tester.pumpWidget(_buildHomeShell());

      await pumpAfterNavigation(tester, find.byKey(const Key('home.scaffold')));

      expect(find.byKey(const Key('home.scaffold')), findsOneWidget);
      expect(find.text('CortexBank'), findsOneWidget);
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Transação'), findsOneWidget);
    });

    testWidgets('deve abrir TransactionFormPage ao tocar na aba Transação', (
      tester,
    ) async {
      await tester.pumpWidget(_buildHomeShell());

      await pumpAfterNavigation(tester, find.byKey(const Key('home.scaffold')));

      await tester.tap(find.text('Transação'));
      await pumpAfterNavigation(
        tester,
        find.byKey(const Key('transaction.form.page')),
      );

      expect(find.byKey(const Key('transaction.form.page')), findsOneWidget);
      expect(find.byType(TransactionFormPage), findsOneWidget);
    });
  });
}
