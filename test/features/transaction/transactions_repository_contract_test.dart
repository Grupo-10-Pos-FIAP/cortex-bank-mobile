import 'package:cortex_bank_mobile/features/transaction/data/repositories/transactions_repository_impl.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page_cursor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TransactionsRepositoryImpl', () {
    test(
      'deve retornar lista do datasource quando getAll for bem-sucedido',
      () async {
        final ds = MockTransactionsDataSource();
        final storage = MockReceiptStorageDataSource();
        when(() => ds.getAll()).thenAnswer((_) async => [buildTransaction()]);
        final repository = TransactionsRepositoryImpl(ds, storage);

        final result = await repository.getAll();

        expect(result, isSuccess);
        expect(result.valueOrNull?.first.id, 't1');
      },
    );

    test('deve mapear exceção quando getAll lançar', () async {
      final ds = MockTransactionsDataSource();
      final storage = MockReceiptStorageDataSource();
      when(() => ds.getAll()).thenThrow(Exception('boom'));
      final repository = TransactionsRepositoryImpl(ds, storage);

      final result = await repository.getAll();

      expect(result, isFailureWithMessage('Erro ao carregar extrato'));
    });

    test('deve repassar página quando getPage for bem-sucedido', () async {
      final ds = MockTransactionsDataSource();
      final storage = MockReceiptStorageDataSource();
      when(
        () => ds.getPage(
          any(),
          startAfterCursor: any(named: 'startAfterCursor'),
        ),
      ).thenAnswer(
        (_) async => TransactionPage(
          items: [buildTransaction(id: 't10')],
          hasMore: true,
          endCursor: const StringTransactionPageCursor('doc'),
        ),
      );
      final repository = TransactionsRepositoryImpl(ds, storage);

      final result = await repository.getPage(
        20,
        startAfterCursor: const StringTransactionPageCursor('prev'),
      );

      expect(result, isSuccess);
      expect(result.valueOrNull?.items.first.id, 't10');
      expect(result.valueOrNull?.hasMore, true);
      verify(
        () => ds.getPage(
          20,
          startAfterCursor: const StringTransactionPageCursor('prev'),
        ),
      ).called(1);
    });

    test('deve mapear exceção quando getPage lançar', () async {
      final ds = MockTransactionsDataSource();
      final storage = MockReceiptStorageDataSource();
      when(
        () => ds.getPage(
          any(),
          startAfterCursor: any(named: 'startAfterCursor'),
        ),
      ).thenThrow(Exception('boom'));
      final repository = TransactionsRepositoryImpl(ds, storage);

      final result = await repository.getPage(20);

      expect(result, isFailureWithMessage('Erro ao carregar transações'));
    });

    test('deve repassar id quando add for bem-sucedido', () async {
      final ds = MockTransactionsDataSource();
      final storage = MockReceiptStorageDataSource();
      when(() => ds.add(any())).thenAnswer((_) async => 'new-id');
      final repository = TransactionsRepositoryImpl(ds, storage);

      final result = await repository.add(buildTransaction());

      expect(result, isSuccess);
      expect(result.valueOrNull, 'new-id');
    });

    test(
      'deve mapear indisponibilidade do Firebase ao adicionar transação',
      () async {
        final ds = MockTransactionsDataSource();
        final storage = MockReceiptStorageDataSource();
        when(() => ds.add(any())).thenThrow(
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
        );
        final repository = TransactionsRepositoryImpl(ds, storage);

        final result = await repository.add(buildTransaction());

        expect(
          result,
          isFailureWithMessage(
            'Serviço temporariamente indisponível. Verifique sua internet e tente de novo.',
          ),
        );
      },
    );

    test('deve mapear exceção quando update lançar', () async {
      final ds = MockTransactionsDataSource();
      final storage = MockReceiptStorageDataSource();
      when(() => ds.update(any())).thenThrow(Exception('boom'));
      final repository = TransactionsRepositoryImpl(ds, storage);

      final result = await repository.update(buildTransaction());

      expect(result, isFailureWithMessage('Erro ao salvar alterações'));
    });

    test('deve retornar sucesso quando delete for bem-sucedido', () async {
      final ds = MockTransactionsDataSource();
      final storage = MockReceiptStorageDataSource();
      when(() => ds.delete(any())).thenAnswer((_) async {});
      final repository = TransactionsRepositoryImpl(ds, storage);

      final result = await repository.delete('t1');

      expect(result, isSuccess);
      verify(() => ds.delete('t1')).called(1);
    });

    test('deve mapear exceção quando delete lançar', () async {
      final ds = MockTransactionsDataSource();
      final storage = MockReceiptStorageDataSource();
      when(() => ds.delete(any())).thenThrow(Exception('boom'));
      final repository = TransactionsRepositoryImpl(ds, storage);

      final result = await repository.delete('t1');

      expect(result, isFailureWithMessage('Erro ao remover item'));
    });

    test('deve mapear exceção quando getBalanceSummary lançar', () async {
      final ds = MockTransactionsDataSource();
      final storage = MockReceiptStorageDataSource();
      when(() => ds.getBalanceSummary()).thenThrow(Exception('boom'));
      final repository = TransactionsRepositoryImpl(ds, storage);

      final result = await repository.getBalanceSummary();

      expect(result, isFailureWithMessage('Erro ao carregar saldo'));
    });

    test(
      'deve anexar URL e atualizar quando uploadReceipt for bem-sucedido',
      () async {
        final ds = MockTransactionsDataSource();
        final storage = MockReceiptStorageDataSource();
        when(
          () => storage.uploadReceipt(any(), any(), any()),
        ).thenAnswer((_) async => 'https://cdn/receipt.jpg');
        when(() => ds.update(any())).thenAnswer((_) async {});
        final repository = TransactionsRepositoryImpl(ds, storage);

        final result = await repository.uploadReceipt(
          buildTransaction(id: 't1'),
          const [1, 2, 3],
          'receipt.jpg',
        );

        expect(result, isSuccess);
        expect(result.valueOrNull?.receiptUrls, ['https://cdn/receipt.jpg']);
        verify(() => ds.update(any<Transaction>())).called(1);
      },
    );

    test('deve mapear storage unauthorized em uploadReceipt', () async {
      final ds = MockTransactionsDataSource();
      final storage = MockReceiptStorageDataSource();
      when(
        () => storage.uploadReceipt(any(), any(), any()),
      ).thenThrow(FirebaseException(plugin: 'storage', code: 'unauthorized'));
      final repository = TransactionsRepositoryImpl(ds, storage);

      final result = await repository.uploadReceipt(
        buildTransaction(id: 't1'),
        const [1, 2, 3],
        'r.jpg',
      );

      expect(
        result,
        isFailureWithMessage(
          'Sem permissão para enviar o arquivo. Faça login novamente.',
        ),
      );
    });

    test(
      'deve retornar original sem chamadas quando uploadReceipts vazio',
      () async {
        final ds = MockTransactionsDataSource();
        final storage = MockReceiptStorageDataSource();
        final repository = TransactionsRepositoryImpl(ds, storage);
        final tx = buildTransaction(id: 't1');

        final result = await repository.uploadReceipts(tx, const []);

        expect(result, isSuccess);
        expect(result.valueOrNull, same(tx));
        verifyNever(() => storage.uploadReceipt(any(), any(), any()));
      },
    );

    test(
      'deve anexar todas as URLs quando uploadReceipts for bem-sucedido',
      () async {
        final ds = MockTransactionsDataSource();
        final storage = MockReceiptStorageDataSource();
        when(
          () => storage.uploadReceipt(any(), any(), any()),
        ).thenAnswer((_) async => 'https://cdn/r.jpg');
        when(() => ds.update(any())).thenAnswer((_) async {});
        final repository = TransactionsRepositoryImpl(ds, storage);

        final result = await repository.uploadReceipts(
          buildTransaction(id: 't1'),
          [
            (bytes: const [1], name: 'a.jpg'),
            (bytes: const [2], name: 'b.jpg'),
          ],
        );

        expect(result, isSuccess);
        expect(result.valueOrNull?.receiptUrls.length, 2);
        verify(() => storage.uploadReceipt(any(), any(), any())).called(2);
      },
    );
  });
}
