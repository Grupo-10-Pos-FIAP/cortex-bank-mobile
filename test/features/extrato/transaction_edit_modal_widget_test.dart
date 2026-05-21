import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/widgets/transaction_edit_modal.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/providers/transactions_notifier.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/state/transactions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TransactionEditModal', () {
    testWidgets('permite editar valor e descrição em transação pendente', (
      tester,
    ) async {
      final repo = FakeTransactionsRepository()
        ..updateResult = const Success(null);
      final txNotifier = TransactionsNotifier(repo);
      final contacts = ContactsProvider(FakeContactsRepository());
      final auth = AuthProvider(FakeAuthRepository());

      final pending = buildTransaction(
        id: 'tx-pending',
        type: TransactionType.debit,
        value: 10,
        date: DateTime.now(),
        status: TransactionStatus.pending,
        description: 'antes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider<AuthProvider>.value(
                              value: auth,
                            ),
                            ChangeNotifierProvider<ContactsProvider>.value(
                              value: contacts,
                            ),
                            StateNotifierProvider<
                              TransactionsNotifier,
                              TransactionsState
                            >.value(value: txNotifier),
                          ],
                          child: TransactionEditModal(data: pending),
                        ),
                      );
                    },
                    child: const Text('Abrir'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Transação'), findsOneWidget);

      final descField = find.widgetWithText(TextField, 'antes');
      expect(descField, findsOneWidget);
      await tester.enterText(descField, 'depois');
      await tester.pump();

      await tester.ensureVisible(find.text('Alterar'));
      await tester.tap(find.text('Alterar'));
      await tester.pumpAndSettle();

      expect(repo.updateCalls, 1);
      expect(repo.lastUpdated?.description, 'depois');
      expect(repo.lastUpdated?.status, TransactionStatus.pending);

      await tester.pump(const Duration(seconds: 4));
    });
  });
}
