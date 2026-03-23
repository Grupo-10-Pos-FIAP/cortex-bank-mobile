import 'package:cortex_bank_mobile/features/extrato/statement_filter.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

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
  final baseDate = DateTime(2025, 1, 15, 12, 0);
  final dayBefore = DateTime(2025, 1, 14);
  final dayAfter = DateTime(2025, 1, 16, 23, 59, 59, 999);

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

  test('empty criteria keeps order and all items', () {
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
  });

  test('search by from is case insensitive', () {
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

  test('date range inclusive of end of day', () {
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

  test('tipo credito', () {
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

  test('tipo debito', () {
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

  test('tipo ted', () {
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

  test('status completa', () {
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

  test('status pendente', () {
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

  test('status agendada', () {
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

  test('minCents and maxCents zero do not filter by value', () {
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

  test('minCents filters', () {
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

  test('maxCents filters', () {
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

  test('categoria salary', () {
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

  test('categoria food', () {
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

  test('categoria ted matches enum name', () {
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

  test('categoria todas keeps all items', () {
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

  test('unknown categoriaFiltro does not filter', () {
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
}
