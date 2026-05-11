import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_form_page.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

Future<Widget> _buildForm() async {
  final authRepo = FakeAuthRepository()
    ..currentUserResult = Success(
      buildUser(uid: 'acc-1', username: 'Ana', email: 'ana@example.com'),
    );
  final auth = AuthProvider(authRepo);
  await auth.loadCurrentUser();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ChangeNotifierProvider(
        create: (_) => TransactionsProvider(FakeTransactionsRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => ContactsProvider(FakeContactsRepository()),
      ),
    ],
    child: const MaterialApp(home: TransactionFormPage()),
  );
}

void main() {
  tearDown(AppSnackBar.hide);

  group('TransactionFormPage', () {
    testWidgets('deve exibir página do formulário e campo de valor', (
      tester,
    ) async {
      await tester.pumpWidget(await _buildForm());

      await pumpAfterNavigation(
        tester,
        find.byKey(const Key('transaction.form.page')),
      );

      expect(find.byKey(const Key('transaction.form.page')), findsOneWidget);
      expect(find.byKey(const Key('transaction.form.value')), findsOneWidget);
      expect(find.byKey(const Key('transaction.form.submit')), findsOneWidget);
    });

    testWidgets('deve exibir erro ao enviar sem tipo de transação', (
      tester,
    ) async {
      await tester.pumpWidget(await _buildForm());

      await pumpAfterNavigation(
        tester,
        find.byKey(const Key('transaction.form.page')),
      );

      await tester.ensureVisible(
        find.byKey(const Key('transaction.form.submit')),
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('transaction.form.submit')));
      await pumpUntilFound(
        tester,
        find.text('Tipo de transação é obrigatório.'),
      );

      expect(find.text('Tipo de transação é obrigatório.'), findsOneWidget);

      await dismissTestSnackBars(tester);
    });
  });
}
