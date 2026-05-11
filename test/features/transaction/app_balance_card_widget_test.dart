import 'dart:async';

import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/core/widgets/app_error_message.dart';
import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/features/transaction/widgets/app_balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppBalanceCard', () {
    testWidgets('exibe carregamento enquanto o resumo não chega', (
      tester,
    ) async {
      final completer = Completer<Result<BalanceSummary>>();
      final repo = FakeTransactionsRepository()
        ..getBalanceSummaryCompleter = completer;
      final provider = TransactionsProvider(repo);

      final loadFuture = provider.loadBalanceSummary(forceRefresh: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<TransactionsProvider>.value(
              value: provider,
              child: const AppBalanceCard(mostrarSaldoInicial: true),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Carregando saldo…'), findsOneWidget);

      completer.complete(Success(buildBalanceSummary(balanceCents: 150)));
      await loadFuture;
      await pumpUntil(
        tester,
        () => find.text('R\$ 1,50').evaluate().isNotEmpty,
      );

      expect(find.text('Carregando saldo…'), findsNothing);
      expect(find.text('R\$ 1,50'), findsOneWidget);
    });

    testWidgets('exibe erro de saldo sem mostrar R\$ 0,00', (tester) async {
      final repo = FakeTransactionsRepository()
        ..getBalanceSummaryResult = FailureResult(
          const Failure(message: 'Falha ao obter saldo'),
        );
      final provider = TransactionsProvider(repo);
      await provider.loadBalanceSummary(forceRefresh: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<TransactionsProvider>.value(
              value: provider,
              child: const AppBalanceCard(mostrarSaldoInicial: true),
            ),
          ),
        ),
      );
      await tester.pump();
      await pumpUntil(
        tester,
        () => find.byType(AppErrorMessage).evaluate().isNotEmpty,
      );

      expect(find.byType(AppErrorMessage), findsOneWidget);
      expect(find.textContaining('R\$ 0,00'), findsNothing);
      expect(find.textContaining('Falha ao obter saldo'), findsOneWidget);
    });
  });
}
