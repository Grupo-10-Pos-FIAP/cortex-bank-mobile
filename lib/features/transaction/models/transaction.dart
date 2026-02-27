/// Alinhado ao backend/statement: "Credit" | "Debit".
enum TransactionType {
  credit,
  debit,
}

/// Modelo estrito do backend: id, accountId, type, value, from, to, date, anexo, urlAnexo, status.
class Transaction {
  const Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.value,
    required this.date,
    this.from,
    this.to,
    this.anexo,
    this.urlAnexo,
    this.status = 'Pending',
  });

  final String id;
  final String accountId;
  final TransactionType type;
  /// Valor em reais (não centavos).
  final double value;
  final DateTime date;
  final String? from;
  final String? to;
  final String? anexo;
  final String? urlAnexo;
  final String status;
}
