import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/statement/statement_filter_criteria.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testes para [applyStatementFilter].
///
/// No extrato, os mesmos eixos de filtro podem ser aplicados no Firestore; a UI
/// monta critérios client-side (ex. só busca + faixa de valor) para não
/// duplicar o que já veio filtrado do servidor. Esta função ainda aplica todos
/// os campos do [StatementFilterCriteria] — inclusive no fallback do datasource.

Transaction _tx({
  required String id,
  required TransactionType type,
  required String status,
  required DateTime date,
  double value = 100,
  String? from,
  String? to,
  TransactionCategory category = TransactionCategory.others,
}) {
  return Transaction(
    id: id,
    accountId: 'a',
    type: type,
    value: value,
    date: date,
    from: from,
    to: to,
    status: status,
    category: category,
  );
}

void main() {
  final today = TransactionDatePolicy.today;
  final baseDate = DateTime(today.year, today.month, today.day, 12);
  final dayBefore = today.subtract(const Duration(days: 1));
  final dayAfter = TransactionDatePolicy.maxSelectableDate;

  final list = [
    _tx(
      id: 'a',
      type: TransactionType.credit,
      status: TransactionStatus.completed,
      date: baseDate,
      from: 'Alice',
      value: 50.0,
      category: TransactionCategory.salary,
    ),
    _tx(
      id: 'b',
      type: TransactionType.debit,
      status: TransactionStatus.pending,
      date: baseDate,
      to: 'Bob',
      value: 200.0,
      category: TransactionCategory.food,
    ),
    _tx(
      id: 'c',
      type: TransactionType.ted,
      status: TransactionStatus.scheduled,
      date: dayAfter,
      value: 10.0,
      category: TransactionCategory.ted,
    ),
  ];

  group('applyStatementFilter', () {
    test(
      'deve manter ordem e todos os itens quando critérios estiverem vazios',
      () {
        const c = StatementFilterCriteria(
          searchQuery: '',
          dateStart: null,
          dateEnd: null,
          tipoFiltro: 'todas',
          statusFiltro: 'todas',
          minCents: 0,
          maxCents: 0,
        );
        final out = applyStatementFilter(list, c);
        expect(out.map((e) => e.id).toList(), ['a', 'b', 'c']);
      },
    );

    test('deve buscar por remetente ignorando maiúsculas', () {
      const c = StatementFilterCriteria(
        searchQuery: 'alice',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'todas',
        minCents: 0,
        maxCents: 0,
      );
      final out = applyStatementFilter(list, c);
      expect(out.map((e) => e.id).toList(), ['a']);
    });

    test('deve incluir fim do dia no intervalo de datas', () {
      final c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: dayBefore,
        dateEnd: baseDate,
        tipoFiltro: 'todas',
        statusFiltro: 'todas',
        minCents: 0,
        maxCents: 0,
      );
      final out = applyStatementFilter(list, c);
      expect(out.map((e) => e.id).toList(), ['a', 'b']);
    });

    test('deve filtrar por tipo crédito', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'credito',
        statusFiltro: 'todas',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).map((e) => e.id).toList(), ['a']);
    });

    test('deve filtrar por tipo débito', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'debito',
        statusFiltro: 'todas',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).map((e) => e.id).toList(), ['b']);
    });

    test('deve filtrar por tipo TED', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'ted',
        statusFiltro: 'todas',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).map((e) => e.id).toList(), ['c']);
    });

    test('deve filtrar por status completa', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'completa',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).map((e) => e.id).toList(), ['a']);
    });

    test('deve filtrar por status pendente', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'pendente',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).map((e) => e.id).toList(), ['b']);
    });

    test('deve filtrar por status agendada', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'agendada',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).map((e) => e.id).toList(), ['c']);
    });

    test(
      'agendada não inclui Scheduled persistido com data hoje (exibe Completa)',
      () {
        final today = TransactionDatePolicy.today;
        final staleScheduled = _tx(
          id: 'stale',
          type: TransactionType.debit,
          status: TransactionStatus.scheduled,
          date: DateTime(today.year, today.month, today.day, 14, 30),
        );
        const c = StatementFilterCriteria(
          searchQuery: '',
          dateStart: null,
          dateEnd: null,
          tipoFiltro: 'todas',
          statusFiltro: 'agendada',
          minCents: 0,
          maxCents: 0,
        );
        expect(
          applyStatementFilter([
            staleScheduled,
            ...list,
          ], c).map((e) => e.id).toList(),
          ['c'],
        );
      },
    );

    test('deve ignorar filtro de valor quando min e max forem zero', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'todas',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).length, 3);
    });

    test('deve filtrar por valor mínimo em centavos', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'todas',
        minCents: 10000,
        maxCents: 0,
      );
      final out = applyStatementFilter(list, c);
      expect(out.map((e) => e.id).toList(), ['b']);
    });

    test('deve filtrar por valor máximo em centavos', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'todas',
        minCents: 0,
        maxCents: 1500,
      );
      final out = applyStatementFilter(list, c);
      expect(out.map((e) => e.id).toList(), ['c']);
    });

    test('deve filtrar por categoria salary', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'todas',
        categoriaFiltro: 'salary',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).map((e) => e.id).toList(), ['a']);
    });

    test('deve filtrar por categoria food', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'todas',
        categoriaFiltro: 'food',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).map((e) => e.id).toList(), ['b']);
    });

    test('deve filtrar categoria ted pelo nome do enum', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'todas',
        categoriaFiltro: 'ted',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).map((e) => e.id).toList(), ['c']);
    });

    test('deve manter todos os itens quando categoria for todas', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'todas',
        categoriaFiltro: 'todas',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).map((e) => e.id).toList(), [
        'a',
        'b',
        'c',
      ]);
    });

    test('deve ignorar categoria desconhecida', () {
      const c = StatementFilterCriteria(
        searchQuery: '',
        dateStart: null,
        dateEnd: null,
        tipoFiltro: 'todas',
        statusFiltro: 'todas',
        categoriaFiltro: 'not_a_category',
        minCents: 0,
        maxCents: 0,
      );
      expect(applyStatementFilter(list, c).length, 3);
    });
  });
}
