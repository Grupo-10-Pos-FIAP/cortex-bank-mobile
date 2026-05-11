import 'dart:async';

import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/pages/extrato_page.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/widgets/transaction_card.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

/// Cenários com [TransactionDatePolicy.today] usam a data local do runner; com
/// flakiness (meia-noite / TZ), prefira datas fixas nos fakes (sem mudar `lib/`).

Widget _buildPage(TransactionsProvider provider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(FakeAuthRepository())),
      ChangeNotifierProvider<TransactionsProvider>.value(value: provider),
    ],
    child: const MaterialApp(home: ExtratoPage()),
  );
}

void main() {
  group('ExtratoPage', () {
    testWidgets('deve exibir loading enquanto getPage está em progresso', (
      tester,
    ) async {
      final repo = FakeTransactionsRepository()
        ..getPageCompleter = Completer<Result<TransactionPage>>();
      final provider = TransactionsProvider(repo);

      await tester.pumpWidget(_buildPage(provider));
      await tester.pump();

      expect(find.byType(AppLoading), findsOneWidget);

      repo.getPageCompleter!.complete(
        const Success(
          TransactionPage(items: [], hasMore: false, lastDocument: null),
        ),
      );
      await pumpUntil(tester, () => find.byType(AppLoading).evaluate().isEmpty);

      expect(provider.isLoading, false);
      expect(provider.transactionsError, isNull);
      expect(provider.transactions, isEmpty);
      expect(find.byType(TransactionCard), findsNothing);
    });

    testWidgets('deve exibir mensagem de erro quando getPage falhar', (
      tester,
    ) async {
      final repo = FakeTransactionsRepository()
        ..getPageResult = FailureResult(
          const Failure(message: 'Erro ao carregar transacoes'),
        );
      final provider = TransactionsProvider(repo);

      await tester.pumpWidget(_buildPage(provider));
      await tester.pump();
      await pumpUntil(tester, () => !provider.isLoading);

      expect(provider.transactionsError, 'Erro ao carregar transacoes');
      expect(find.byType(TransactionCard), findsNothing);
    });

    testWidgets('deve exibir lista vazia quando não houver transações', (
      tester,
    ) async {
      final repo = FakeTransactionsRepository()
        ..getPageResult = const Success(
          TransactionPage(items: [], hasMore: false, lastDocument: null),
        );
      final provider = TransactionsProvider(repo);

      await tester.pumpWidget(_buildPage(provider));
      await tester.pump();
      await pumpUntil(tester, () => !provider.isLoading);

      expect(provider.transactions, isEmpty);
      expect(find.byType(TransactionCard), findsNothing);
    });

    testWidgets(
      'deve exibir mensagem de filtro quando busca não retornar itens',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 2000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final d = TransactionDatePolicy.today;
        final recent = DateTime(d.year, d.month, d.day, 12);
        final repo = FakeTransactionsRepository()
          ..getPageResult = Success(
            TransactionPage(
              items: [buildTransaction(id: 'x1', from: 'Maria', date: recent)],
              hasMore: false,
              lastDocument: null,
            ),
          );
        final provider = TransactionsProvider(repo);

        await tester.pumpWidget(_buildPage(provider));
        await tester.pump();
        await pumpUntil(tester, () => !provider.isLoading);

        await tester.ensureVisible(
          find.byKey(const Key('extrato.filter.search')),
        );
        await tester.pump();
        await tester.tap(find.byKey(const Key('extrato.filter.search')));
        await tester.pump();
        await tester.enterText(
          find.byKey(const Key('extrato.filter.search')),
          'zzz_inexistente',
        );
        await tester.pump();
        await pumpUntil(
          tester,
          () => find
              .text('Nenhum resultado para os filtros selecionados.')
              .evaluate()
              .isNotEmpty,
        );

        expect(
          find.text('Nenhum resultado para os filtros selecionados.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'com erro em loadMore e lista filtrada vazia deve priorizar mensagem de filtro',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 2000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final d = TransactionDatePolicy.today;
        final recent = DateTime(d.year, d.month, d.day, 11);
        final repo = FakeTransactionsRepository()
          ..getPageResult = Success(
            TransactionPage(
              items: [buildTransaction(id: 'a', from: 'Ana', date: recent)],
              hasMore: true,
              lastDocument: 'd1',
            ),
          )
          ..getPageNextResult = FailureResult(
            const Failure(message: 'Erro ao carregar mais'),
          );
        final provider = TransactionsProvider(repo);

        await tester.pumpWidget(_buildPage(provider));
        await tester.pump();
        await pumpUntil(tester, () => !provider.isLoading);

        await provider.loadMoreTransactions();
        await tester.pump();
        expect(provider.transactionsError, 'Erro ao carregar mais');

        await tester.ensureVisible(
          find.byKey(const Key('extrato.filter.search')),
        );
        await tester.pump();
        await tester.tap(find.byKey(const Key('extrato.filter.search')));
        await tester.pump();
        await tester.enterText(
          find.byKey(const Key('extrato.filter.search')),
          'nada1982',
        );
        await tester.pump();
        await pumpUntil(tester, () => !provider.isLoadingMore);
        await pumpUntil(
          tester,
          () => find
              .text('Nenhum resultado para os filtros selecionados.')
              .evaluate()
              .isNotEmpty,
        );

        expect(
          find.text('Nenhum resultado para os filtros selecionados.'),
          findsOneWidget,
        );
        expect(find.text('Erro ao carregar mais'), findsNothing);
      },
    );
  });
}
