import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart'
    show TransactionPage;
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';

class FakeTransactionsTimelineMirror {
  final List<Transaction> _items = [];

  void sortNewestFirst() {
    _items.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      return b.id.compareTo(a.id);
    });
  }

  void mirrorAdd(String id, Transaction transaction) {
    _items.removeWhere((t) => t.id == id);
    _items.insert(0, transaction.copyWith(id: id));
    sortNewestFirst();
  }

  void mirrorDelete(String id) {
    _items.removeWhere((t) => t.id == id);
  }

  Result<List<Transaction>> snapshotAsSuccess() {
    sortNewestFirst();
    return Success(List<Transaction>.from(_items));
  }

  Result<TransactionPage> getPage(int limit, {dynamic startAfterDocument}) {
    sortNewestFirst();
    final afterId = startAfterDocument?.toString();
    final startIndex = afterId == null || afterId.isEmpty
        ? 0
        : (() {
            final i = _items.indexWhere((t) => t.id == afterId);
            return i < 0 ? 0 : i + 1;
          })();
    final pageItems = _items.skip(startIndex).take(limit).toList();
    final hasMore = startIndex + pageItems.length < _items.length;
    return Success(
      TransactionPage(
        items: pageItems,
        hasMore: hasMore,
        lastDocument: pageItems.isEmpty ? null : pageItems.last.id,
      ),
    );
  }
}
