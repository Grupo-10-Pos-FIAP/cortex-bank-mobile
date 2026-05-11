import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page_cursor.dart';

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

  Result<TransactionPage> getPage(int limit, {TransactionPageCursor? startAfterCursor}) {
    sortNewestFirst();
    final afterId = switch (startAfterCursor) {
      null => null,
      StringTransactionPageCursor(:final transactionId) => transactionId,
      _ => null,
    };
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
        endCursor: pageItems.isEmpty
            ? null
            : StringTransactionPageCursor(pageItems.last.id),
      ),
    );
  }
}
