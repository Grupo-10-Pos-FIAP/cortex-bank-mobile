/// Marcador opaco para a página seguinte na paginação de transações.
abstract class TransactionPageCursor {
  const TransactionPageCursor();
}

/// Cursor genérico por id da última transação (testes, mirrors em memória).
class StringTransactionPageCursor extends TransactionPageCursor {
  const StringTransactionPageCursor(this.transactionId);
  final String transactionId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringTransactionPageCursor &&
          other.transactionId == transactionId;

  @override
  int get hashCode => transactionId.hashCode;
}
