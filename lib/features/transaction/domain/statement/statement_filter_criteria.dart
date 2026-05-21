import 'package:cortex_bank_mobile/features/transaction/constants/transaction_status_normalization.dart';

import '../entities/transaction.dart';

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

/// Valor de `type` no Firestore para [StatementFilterCriteria.tipoFiltro] da UI.
String? tipoFiltroToFirestoreType(String tipoFiltro) {
  switch (tipoFiltro) {
    case 'credito':
      return 'credit';
    case 'debito':
      return 'debit';
    case 'ted':
      return 'ted';
    default:
      return null;
  }
}

/// Valor de `status` no Firestore para [StatementFilterCriteria.statusFiltro] da UI.
String? statusFiltroToFirestoreStatus(String statusFiltro) {
  switch (statusFiltro) {
    case 'completa':
      return TransactionStatus.completed;
    case 'agendada':
      return TransactionStatus.scheduled;
    case 'pendente':
      return TransactionStatus.pending;
    default:
      return null;
  }
}

/// Critérios para filtro na camada data (sem busca textual da UI).
StatementFilterCriteria criteriaForDatasourceFilter(
  StatementFilterCriteria criteria,
) {
  return StatementFilterCriteria(
    searchQuery: '',
    dateStart: criteria.dateStart,
    dateEnd: criteria.dateEnd,
    tipoFiltro: criteria.tipoFiltro,
    statusFiltro: criteria.statusFiltro,
    categoriaFiltro: criteria.categoriaFiltro,
    minCents: criteria.minCents,
    maxCents: criteria.maxCents,
  );
}

/// Quantos filtros secundários (além de data) estão ativos.
int countActiveSecondaryFilters(StatementFilterCriteria criteria) {
  var count = 0;
  if (criteria.tipoFiltro != 'todas') count++;
  if (criteria.statusFiltro != 'todas') count++;
  if (criteria.categoriaFiltro != 'todas') count++;
  if (criteria.minCents > 0 || criteria.maxCents > 0) count++;
  return count;
}

/// Status efetivo na UI (após [normalizeTransactionStatusForRead] no mapper).
String transactionDisplayStatus(Transaction t) =>
    normalizeTransactionStatusForRead(t.status, t.date);

/// Usa leitura por data + [applyStatementFilter] no datasource (combinações / valor).
bool needsDatasourcePostFilter(StatementFilterCriteria? criteria) {
  if (criteria == null) return false;
  // Status no Firestore ≠ status exibido (ex.: Scheduled + data hoje → Completa).
  if (criteria.statusFiltro != 'todas') return true;
  var equalityCount = 0;
  if (criteria.tipoFiltro != 'todas') equalityCount++;
  if (criteria.categoriaFiltro != 'todas') equalityCount++;
  if (equalityCount > 1) return true;
  if (criteria.minCents > 0 || criteria.maxCents > 0) return true;
  return false;
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
    result = result
        .where(
          (t) => transactionDisplayStatus(t) == TransactionStatus.completed,
        )
        .toList();
  } else if (c.statusFiltro == 'agendada') {
    result = result
        .where(
          (t) => transactionDisplayStatus(t) == TransactionStatus.scheduled,
        )
        .toList();
  } else if (c.statusFiltro == 'pendente') {
    result = result
        .where((t) => transactionDisplayStatus(t) == TransactionStatus.pending)
        .toList();
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
