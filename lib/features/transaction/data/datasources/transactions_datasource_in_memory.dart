import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart';

/// In-memory implementation. For production, replace with Firestore.
/// Use [initialData] para iniciar com transações mockadas.
class TransactionsDataSourceInMemory implements TransactionsDataSource {
  TransactionsDataSourceInMemory({List<Transaction>? initialData})
      : _list = List.from(initialData ?? []);

  final List<Transaction> _list;

  @override
  Future<void> add(Transaction transaction) async {
    _list.add(transaction);
  }

  @override
  Future<List<Transaction>> getAll() async {
    return List.unmodifiable(_list);
  }

  @override
  Future<void> delete(String id) async {
    _list.removeWhere((t) => t.id == id);
  }

  @override
  Future<BalanceSummary> getBalanceSummary() async {
    var incomeCents = 0;
    var expenseCents = 0;
    for (final t in _list) {
      final cents = (t.value.abs() * 100).round();
      if (t.type == TransactionType.credit) {
        incomeCents += cents;
      } else {
        expenseCents += cents;
      }
    }
    return BalanceSummary(
      totalIncomeCents: incomeCents,
      totalExpenseCents: expenseCents,
      balanceCents: incomeCents - expenseCents,
    );
  }
}
