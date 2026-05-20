import 'dart:async';

import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page_cursor.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/statement/statement_filter_criteria.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/providers/transactions_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TransactionsNotifier', () {
    test(
      'deve carregar e ordenar primeira página quando loadTransactionsPaginated tiver sucesso',
      () async {
        final repo = FakeTransactionsRepository()
          ..getPageResult = Success(
            TransactionPage(
              items: [
                buildTransaction(id: 'old', date: DateTime(2024, 1, 1)),
                buildTransaction(id: 'new', date: DateTime(2024, 2, 1)),
              ],
              hasMore: true,
              endCursor: const StringTransactionPageCursor('doc-1'),
            ),
          );
        final provider = TransactionsNotifier(repo);

        await provider.loadTransactionsPaginated();

        expect(provider.transactions.map((e) => e.id).toList(), ['new', 'old']);
        expect(provider.hasMore, true);
        expect(provider.isLoading, false);
        expect(provider.transactionsError, isNull);
        expect(provider.balanceSummaryError, isNull);
      },
    );

    test(
      'deve substituir lista e repassar criteria ao refiltrar com loadTransactionsPaginated',
      () async {
        final repo = FakeTransactionsRepository()
          ..getPageResult = Success(
            TransactionPage(
              items: [buildTransaction(id: 'c1', date: DateTime(2024, 6, 1))],
              hasMore: false,
              endCursor: null,
            ),
          );
        final provider = TransactionsNotifier(repo);

        const creditCriteria = StatementFilterCriteria(
          searchQuery: '',
          tipoFiltro: 'credito',
          statusFiltro: 'todas',
          minCents: 0,
          maxCents: 0,
        );
        await provider.loadTransactionsPaginated(criteria: creditCriteria);

        expect(provider.transactions.map((e) => e.id).toList(), ['c1']);
        expect(repo.lastGetPageCriteria?.tipoFiltro, 'credito');

        repo.getPageResult = Success(
          TransactionPage(
            items: [buildTransaction(id: 'd1', date: DateTime(2024, 5, 1))],
            hasMore: false,
            endCursor: null,
          ),
        );

        const debitCriteria = StatementFilterCriteria(
          searchQuery: '',
          tipoFiltro: 'debito',
          statusFiltro: 'todas',
          minCents: 0,
          maxCents: 0,
        );
        await provider.loadTransactionsPaginated(criteria: debitCriteria);

        expect(provider.transactions.map((e) => e.id).toList(), ['d1']);
        expect(provider.transactions.any((t) => t.id == 'c1'), isFalse);
        expect(repo.lastGetPageCriteria?.tipoFiltro, 'debito');
      },
    );

    test(
      'deve mesclar próxima página sem duplicatas quando loadMoreTransactions tiver sucesso',
      () async {
        final repo = FakeTransactionsRepository()
          ..getPageResult = Success(
            TransactionPage(
              items: [
                buildTransaction(id: 'a', date: DateTime(2024, 4, 1)),
                buildTransaction(id: 'b', date: DateTime(2024, 3, 1)),
              ],
              hasMore: true,
              endCursor: const StringTransactionPageCursor('doc-1'),
            ),
          )
          ..getPageNextResult = Success(
            TransactionPage(
              items: [
                buildTransaction(id: 'b', date: DateTime(2024, 3, 1)),
                buildTransaction(id: 'c', date: DateTime(2024, 2, 1)),
              ],
              hasMore: false,
              endCursor: const StringTransactionPageCursor('doc-2'),
            ),
          );
        final provider = TransactionsNotifier(repo);

        await provider.loadTransactionsPaginated();
        await provider.loadMoreTransactions();

        expect(provider.transactions.map((e) => e.id).toList(), [
          'a',
          'b',
          'c',
        ]);
        expect(provider.hasMore, false);
        expect(provider.isLoadingMore, false);
        expect(
          repo.lastStartAfterCursor,
          const StringTransactionPageCursor('doc-1'),
        );
      },
    );

    test(
      'novo provider deve hidratar lista merged via cache após loadMore sem chamar getAll',
      () async {
        final repo = FakeTransactionsRepository()
          ..getPageResult = Success(
            TransactionPage(
              items: [
                buildTransaction(id: 'a', date: DateTime(2024, 4, 1)),
                buildTransaction(id: 'b', date: DateTime(2024, 3, 1)),
              ],
              hasMore: true,
              endCursor: const StringTransactionPageCursor('doc-1'),
            ),
          )
          ..getPageNextResult = Success(
            TransactionPage(
              items: [
                buildTransaction(id: 'b', date: DateTime(2024, 3, 1)),
                buildTransaction(id: 'c', date: DateTime(2024, 2, 1)),
              ],
              hasMore: false,
              endCursor: const StringTransactionPageCursor('doc-2'),
            ),
          );

        final first = TransactionsNotifier(repo);
        await first.loadTransactionsPaginated();
        await first.loadMoreTransactions();

        final second = TransactionsNotifier(repo);
        await second.loadTransactions();

        expect(second.transactions.map((e) => e.id).toList(), ['a', 'b', 'c']);
        expect(repo.getAllCalls, 0);
      },
    );

    test('deve expor mensagem quando loadTransactions falhar', () async {
      final repo = FakeTransactionsRepository()
        ..getAllResult = FailureResult(
          const Failure(message: 'Erro ao carregar transacoes'),
        );
      final provider = TransactionsNotifier(repo);

      await provider.loadTransactions();

      expect(provider.transactions, isEmpty);
      expect(provider.transactionsError, 'Erro ao carregar transacoes');
      expect(provider.isLoading, false);
    });

    test(
      'deve expor erro e encerrar loadingMore quando loadMoreTransactions falhar',
      () async {
        final repo = FakeTransactionsRepository()
          ..getPageResult = Success(
            TransactionPage(
              items: [],
              hasMore: true,
              endCursor: const StringTransactionPageCursor('doc-1'),
            ),
          )
          ..getPageNextResult = FailureResult(
            const Failure(message: 'Erro ao carregar mais'),
          );
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactionsPaginated();

        await provider.loadMoreTransactions();

        expect(provider.transactionsError, 'Erro ao carregar mais');
        expect(provider.isLoadingMore, false);
        expect(provider.hasMore, true);
      },
    );

    test(
      'deve limpar erro ao servir lista válida do cache após falha em loadMore',
      () async {
        final repo = FakeTransactionsRepository()
          ..getPageResult = Success(
            TransactionPage(
              items: [buildTransaction(id: 'a', date: DateTime(2024, 4, 1))],
              hasMore: true,
              endCursor: const StringTransactionPageCursor('doc-1'),
            ),
          )
          ..getPageNextResult = FailureResult(
            const Failure(message: 'Erro ao carregar mais'),
          );
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactionsPaginated();
        await provider.loadMoreTransactions();

        expect(provider.transactionsError, 'Erro ao carregar mais');

        await provider.loadTransactions();

        expect(provider.transactionsError, isNull);
        expect(provider.balanceSummaryError, isNull);
        expect(provider.transactions.map((e) => e.id).toList(), ['a']);
        expect(repo.getAllCalls, 0);
      },
    );

    test(
      'deve sair cedo quando loadMoreTransactions e hasMore for falso',
      () async {
        final repo = FakeTransactionsRepository()
          ..getPageResult = Success(TransactionPage(items: [], hasMore: false));
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactionsPaginated();

        await provider.loadMoreTransactions();

        expect(repo.getPageCalls, 0);
      },
    );

    test(
      'deve antecipar transação criada quando addTransaction for bem-sucedido',
      () async {
        final repo = FakeTransactionsRepository()
          ..addResult = const Success('new-id');
        final provider = TransactionsNotifier(repo);
        final transaction = buildTransaction(
          id: '',
          date: DateTime(2024, 5, 1),
        );

        final created = await provider.addTransaction(
          transaction,
          skipBalanceRefresh: true,
        );

        expect(repo.addCalls, 1);
        expect(created?.id, 'new-id');
        expect(provider.transactions.first.id, 'new-id');
        expect(provider.transactionsError, isNull);
        expect(provider.balanceSummaryError, isNull);
        expect(provider.isLoading, false);
      },
    );

    test(
      'deve retornar null e definir erro quando addTransaction falhar',
      () async {
        final repo = FakeTransactionsRepository()
          ..addResult = FailureResult(
            const Failure(message: 'Erro ao adicionar'),
          );
        final provider = TransactionsNotifier(repo);

        final created = await provider.addTransaction(
          buildTransaction(id: '', date: DateTime(2024, 5, 1)),
          skipBalanceRefresh: true,
        );

        expect(created, isNull);
        expect(provider.transactions, isEmpty);
        expect(provider.transactionsError, 'Erro ao adicionar');
      },
    );

    test(
      'deve substituir item quando updateTransaction for bem-sucedido',
      () async {
        final repo = FakeTransactionsRepository()
          ..getAllResult = Success([
            buildTransaction(id: 't1', date: DateTime(2024, 5, 1), value: 10),
          ])
          ..updateResult = const Success(null);
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactions();

        final ok = await provider.updateTransaction(
          buildTransaction(id: 't1', date: DateTime(2024, 5, 1), value: 20),
        );

        expect(ok, true);
        expect(repo.updateCalls, 1);
        expect(provider.transactions.first.value, 20);
      },
    );

    test(
      'deve retornar false e manter valor original quando updateTransaction falhar',
      () async {
        final repo = FakeTransactionsRepository()
          ..getAllResult = Success([
            buildTransaction(id: 't1', date: DateTime(2024, 5, 1), value: 10),
          ])
          ..updateResult = FailureResult(
            const Failure(message: 'Erro ao atualizar'),
          );
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactions();

        final ok = await provider.updateTransaction(
          buildTransaction(id: 't1', date: DateTime(2024, 5, 1), value: 20),
        );

        expect(ok, false);
        expect(provider.transactions.first.value, 10);
        expect(provider.transactionsError, 'Erro ao atualizar');
      },
    );

    test(
      'deve remover item quando deleteTransaction for bem-sucedido',
      () async {
        final repo = FakeTransactionsRepository()
          ..getAllResult = Success([
            buildTransaction(id: 't1', date: DateTime(2024, 5, 1)),
          ]);
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactions();

        await provider.deleteTransaction('t1');

        expect(repo.deleteCalls, 1);
        expect(repo.lastDeletedId, 't1');
        expect(provider.transactions, isEmpty);
      },
    );

    test(
      'deve manter item e expor erro quando deleteTransaction falhar',
      () async {
        final repo = FakeTransactionsRepository()
          ..getAllResult = Success([
            buildTransaction(id: 't1', date: DateTime(2024, 5, 1)),
          ])
          ..deleteResult = FailureResult(
            const Failure(message: 'Erro ao remover'),
          );
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactions();

        await provider.deleteTransaction('t1');

        expect(provider.transactions.length, 1);
        expect(provider.transactionsError, 'Erro ao remover');
      },
    );

    test(
      'deve retornar null e definir erro quando uploadReceipt falhar',
      () async {
        final repo = FakeTransactionsRepository()
          ..getAllResult = Success([
            buildTransaction(id: 't1', date: DateTime(2024, 5, 1)),
          ])
          ..uploadReceiptResult = FailureResult(
            const Failure(message: 'Falha upload'),
          );
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactions();

        final updated = await provider.uploadReceipt(
          provider.transactions.first,
          [1, 2, 3],
          'receipt.png',
        );

        expect(updated, isNull);
        expect(repo.uploadReceiptCalls, 1);
        expect(provider.transactionsError, 'Falha upload');
      },
    );

    test(
      'deve substituir item e retornar atualizado quando uploadReceipt for bem-sucedido',
      () async {
        final original = buildTransaction(id: 't1', date: DateTime(2024, 5, 1));
        final updated = original.copyWith(receiptUrls: const ['https://r.png']);
        final repo = FakeTransactionsRepository()
          ..getAllResult = Success([original])
          ..uploadReceiptResult = Success(updated);
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactions();

        final result = await provider.uploadReceipt(
          provider.transactions.first,
          [1, 2, 3],
          'receipt.png',
        );

        expect(result, isNotNull);
        expect(provider.transactions.first.receiptUrls, ['https://r.png']);
      },
    );

    test(
      'uploadReceipts deve retornar original quando anexos estiverem vazios',
      () async {
        final repo = FakeTransactionsRepository()
          ..getAllResult = Success([
            buildTransaction(id: 't1', date: DateTime(2024, 5, 1)),
          ]);
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactions();

        final original = provider.transactions.first;
        final result = await provider.uploadReceipts(original, []);

        expect(result, same(original));
        expect(repo.uploadReceiptsCalls, 0);
      },
    );

    test(
      'deve retornar null e definir erro quando uploadReceipts falhar',
      () async {
        final original = buildTransaction(id: 't1', date: DateTime(2024, 5, 1));
        final repo = FakeTransactionsRepository()
          ..getAllResult = Success([original])
          ..uploadReceiptsResult = FailureResult(
            const Failure(message: 'Falha upload em lote'),
          );
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactions();

        final result = await provider.uploadReceipts(
          provider.transactions.first,
          [
            (bytes: const [1, 2, 3], name: 'receipt.png'),
          ],
        );

        expect(result, isNull);
        expect(provider.transactionsError, 'Falha upload em lote');
      },
    );

    test(
      'deve definir resumo quando loadBalanceSummary for bem-sucedido',
      () async {
        final repo = FakeTransactionsRepository()
          ..getBalanceSummaryResult = Success(
            buildBalanceSummary(balanceCents: 5000),
          );
        final provider = TransactionsNotifier(repo);

        await provider.loadBalanceSummary();

        expect(provider.balanceSummary?.balanceCents, 5000);
      },
    );

    test('deve expor mensagem quando loadBalanceSummary falhar', () async {
      final repo = FakeTransactionsRepository()
        ..getBalanceSummaryResult = FailureResult(
          const Failure(message: 'Erro saldo'),
        );
      final provider = TransactionsNotifier(repo);

      await provider.loadBalanceSummary();

      expect(repo.getBalanceSummaryCalls, 1);
      expect(provider.balanceSummary, isNull);
      expect(provider.balanceSummaryError, 'Erro saldo');
      expect(provider.isBalanceSummaryLoading, false);
    });

    test(
      'deve expor isBalanceSummaryLoading durante getBalanceSummary em voo',
      () async {
        final completer = Completer<Result<BalanceSummary>>();
        final repo = FakeTransactionsRepository()
          ..getBalanceSummaryCompleter = completer;
        final provider = TransactionsNotifier(repo);

        final pending = provider.loadBalanceSummary(forceRefresh: true);

        expect(provider.isBalanceSummaryLoading, true);
        expect(provider.balanceSummaryError, isNull);

        completer.complete(Success(buildBalanceSummary(balanceCents: 100)));
        await pending;

        expect(provider.isBalanceSummaryLoading, false);
        expect(provider.balanceSummary?.balanceCents, 100);
      },
    );

    test(
      'deve limpar erros de transação e saldo ao chamar clearError',
      () async {
        final repo = FakeTransactionsRepository()
          ..getAllResult = FailureResult(
            const Failure(message: 'Erro ao carregar transacoes'),
          )
          ..getBalanceSummaryResult = FailureResult(
            const Failure(message: 'Erro saldo'),
          );
        final provider = TransactionsNotifier(repo);
        await provider.loadTransactions();
        await provider.loadBalanceSummary(forceRefresh: true);

        expect(provider.transactionsError, isNotNull);
        expect(provider.balanceSummaryError, isNotNull);

        provider.clearError();

        expect(provider.transactionsError, isNull);
        expect(provider.balanceSummaryError, isNull);
      },
    );

    test(
      'deve desempatar por id decrescente quando ordenar mesma data',
      () async {
        final sameDate = DateTime(2024, 5, 1);
        final repo = FakeTransactionsRepository()
          ..getAllResult = Success([
            buildTransaction(id: 'a', date: sameDate),
            buildTransaction(id: 'b', date: sameDate),
          ]);
        final provider = TransactionsNotifier(repo);

        await provider.loadTransactions();

        expect(provider.transactions.map((t) => t.id).toList(), ['b', 'a']);
      },
    );
  });
}
