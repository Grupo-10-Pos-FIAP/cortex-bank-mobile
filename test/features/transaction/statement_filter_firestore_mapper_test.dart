import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/statement/statement_filter_criteria.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tipoFiltroToFirestoreType', () {
    test('deve mapear credito para credit', () {
      expect(tipoFiltroToFirestoreType('credito'), 'credit');
    });

    test('deve mapear debito para debit', () {
      expect(tipoFiltroToFirestoreType('debito'), 'debit');
    });

    test('deve mapear ted para ted', () {
      expect(tipoFiltroToFirestoreType('ted'), 'ted');
    });

    test('deve retornar null para todas', () {
      expect(tipoFiltroToFirestoreType('todas'), isNull);
    });
  });

  group('statusFiltroToFirestoreStatus', () {
    test('deve mapear completa para Completed', () {
      expect(
        statusFiltroToFirestoreStatus('completa'),
        TransactionStatus.completed,
      );
    });

    test('deve mapear agendada para Scheduled', () {
      expect(
        statusFiltroToFirestoreStatus('agendada'),
        TransactionStatus.scheduled,
      );
    });

    test('deve mapear pendente para Pending', () {
      expect(
        statusFiltroToFirestoreStatus('pendente'),
        TransactionStatus.pending,
      );
    });

    test('deve retornar null para todas', () {
      expect(statusFiltroToFirestoreStatus('todas'), isNull);
    });
  });

  group('firestoreDateEndForStatementQuery', () {
    test('deve estender até maxSelectableDate quando fim da UI é hoje', () {
      final today = TransactionDatePolicy.today;
      final uiEnd = DateTime(
        today.year,
        today.month,
        today.day,
        23,
        59,
        59,
        999,
      );
      final queryEnd = firestoreDateEndForStatementQuery(uiEnd);
      expect(
        TransactionDatePolicy.dateOnly(queryEnd),
        TransactionDatePolicy.dateOnly(TransactionDatePolicy.maxSelectableDate),
      );
    });

    test('não deve estender quando fim da UI é só no passado', () {
      final past = TransactionDatePolicy.today.subtract(
        const Duration(days: 5),
      );
      final uiEnd = DateTime(past.year, past.month, past.day, 23, 59, 59, 999);
      expect(firestoreDateEndForStatementQuery(uiEnd), uiEnd);
    });
  });

  group('needsDatasourcePostFilter', () {
    test('deve ser true com tipo e status ativos', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        tipoFiltro: 'credito',
        statusFiltro: 'completa',
        minCents: 0,
        maxCents: 0,
      );
      expect(needsDatasourcePostFilter(c), isTrue);
    });

    test('deve ser true com filtro de valor', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        tipoFiltro: 'todas',
        statusFiltro: 'todas',
        minCents: 100,
        maxCents: 0,
      );
      expect(needsDatasourcePostFilter(c), isTrue);
    });

    test('deve ser false com apenas tipo', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        tipoFiltro: 'credito',
        statusFiltro: 'todas',
        minCents: 0,
        maxCents: 0,
      );
      expect(needsDatasourcePostFilter(c), isFalse);
    });

    test('deve ser true com apenas filtro de status agendada', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        tipoFiltro: 'todas',
        statusFiltro: 'agendada',
        minCents: 0,
        maxCents: 0,
      );
      expect(needsDatasourcePostFilter(c), isTrue);
    });
  });
}
