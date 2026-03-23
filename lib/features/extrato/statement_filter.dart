import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';

/// Critérios do extrato (sem [TextEditingController]); imutável.
class StatementFilterCriteria {
  const StatementFilterCriteria({
    required this.searchQuery,
    this.dateStart,
    this.dateEnd,
    required this.tipoFiltro,
    required this.statusFiltro,
    this.categoriaFiltro = 'todas',
    required this.minCents,
    required this.maxCents,
  });

  final String searchQuery;
  final DateTime? dateStart;
  final DateTime? dateEnd;

  /// `todas` | `credito` | `debito` | `ted`
  final String tipoFiltro;

  /// `todas` | `completa` | `agendada` | `pendente`
  final String statusFiltro;

  /// `todas` ou [TransactionCategory.name] (ex.: `food`, `transport`).
  final String categoriaFiltro;

  final int minCents;
  final int maxCents;
}

/// Filtra mantendo a ordem relativa da lista de entrada (apenas `where` encadeados).
List<Transaction> applyStatementFilter(
  List<Transaction> source,
  StatementFilterCriteria c,
) {
  var result = source;
  final query = c.searchQuery.trim().toLowerCase();
  if (query.isNotEmpty) {
    result = result.where((t) {
      if (t.from?.toLowerCase().contains(query) ?? false) return true;
      if (t.to?.toLowerCase().contains(query) ?? false) return true;
      if (t.id.toLowerCase().contains(query)) return true;
      if (t.value.toString().contains(query)) return true;
      return false;
    }).toList();
  }
  if (c.dateStart != null) {
    final start = DateTime(
      c.dateStart!.year,
      c.dateStart!.month,
      c.dateStart!.day,
    );
    result = result.where((t) {
      final txDate = DateTime(t.date.year, t.date.month, t.date.day);
      return !txDate.isBefore(start);
    }).toList();
  }
  if (c.dateEnd != null) {
    final end = DateTime(
      c.dateEnd!.year,
      c.dateEnd!.month,
      c.dateEnd!.day,
      23,
      59,
      59,
      999,
    );
    result = result
        .where((t) => t.date.isBefore(end) || t.date.isAtSameMomentAs(end))
        .toList();
  }
  if (c.tipoFiltro == 'credito') {
    result = result.where((t) => t.type == TransactionType.credit).toList();
  } else if (c.tipoFiltro == 'debito') {
    result = result.where((t) => t.type == TransactionType.debit).toList();
  } else if (c.tipoFiltro == 'ted') {
    result = result.where((t) => t.type == TransactionType.ted).toList();
  }
  if (c.statusFiltro == 'completa') {
    result =
        result.where((t) => t.status == TransactionStatus.completed).toList();
  } else if (c.statusFiltro == 'agendada') {
    result =
        result.where((t) => t.status == TransactionStatus.scheduled).toList();
  } else if (c.statusFiltro == 'pendente') {
    result =
        result.where((t) => t.status == TransactionStatus.pending).toList();
  }
  if (c.categoriaFiltro != 'todas') {
    TransactionCategory? match;
    for (final cat in TransactionCategory.values) {
      if (cat.name == c.categoriaFiltro) {
        match = cat;
        break;
      }
    }
    if (match != null) {
      result = result.where((t) => t.category == match).toList();
    }
  }
  if (c.minCents > 0) {
    result = result
        .where((t) => (t.value.abs() * 100).round() >= c.minCents)
        .toList();
  }
  if (c.maxCents > 0) {
    result = result
        .where((t) => (t.value.abs() * 100).round() <= c.maxCents)
        .toList();
  }
  return result;
}
