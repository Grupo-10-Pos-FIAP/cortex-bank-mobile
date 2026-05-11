import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/dashboard_page.dart';
import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/features/transaction/widgets/app_balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

void main() {
  group('DashboardPage', () {
    testWidgets(
      'deve exibir card de saldo quando o resumo estiver disponível',
      (tester) async {
        final repo = FakeTransactionsRepository()
          ..getBalanceSummaryResult = Success(
            const BalanceSummary(
              totalIncomeCents: 10000,
              totalExpenseCents: 2000,
              balanceCents: 8000,
            ),
          );
        final tx = TransactionsProvider(repo);
        await tx.loadBalanceSummary();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<TransactionsProvider>.value(
              value: tx,
              child: const Scaffold(body: DashboardPage()),
            ),
          ),
        );

        await pumpAfterNavigation(
          tester,
          find.byKey(const Key('dashboard.scroll')),
        );

        expect(find.byKey(const Key('dashboard.scroll')), findsOneWidget);
        expect(find.byType(AppBalanceCard), findsOneWidget);
        expect(find.text('Saldo'), findsOneWidget);
      },
    );
  });
}
