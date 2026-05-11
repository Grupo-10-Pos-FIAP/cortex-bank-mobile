import '../entities/transaction.dart';
import 'transaction_page_cursor.dart';

class TransactionPage {
  final List<Transaction> items;
  final bool hasMore;
  final TransactionPageCursor? endCursor;

  const TransactionPage({
    required this.items,
    required this.hasMore,
    this.endCursor,
  });
}
