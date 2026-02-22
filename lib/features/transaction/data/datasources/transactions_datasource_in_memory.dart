import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart';

/// In-memory implementation. For production, replace with Hive/SQLite or MongoDB API.
class TransactionsDataSourceInMemory implements TransactionsDataSource {
  final List<Transaction> _list = [];

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
    var income = 0;
    var expense = 0;
    for (final t in _list) {
      if (t.type == TransactionType.income) {
        income += t.amountCents;
      } else {
        expense += t.amountCents;
      }
    }
    return BalanceSummary(
      totalIncomeCents: income,
      totalExpenseCents: expense,
      balanceCents: income - expense,
    );
  }
}
