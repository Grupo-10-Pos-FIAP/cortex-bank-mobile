import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/dashboard_page.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/providers/transactions_notifier.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/state/transactions_state.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:cortex_bank_mobile/features/transaction/widgets/app_balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
        final tx = TransactionsNotifier(repo);
        await tx.loadBalanceSummary();

        await tester.pumpWidget(
          MaterialApp(
            home:
                StateNotifierProvider<
                  TransactionsNotifier,
                  TransactionsState
                >.value(
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
