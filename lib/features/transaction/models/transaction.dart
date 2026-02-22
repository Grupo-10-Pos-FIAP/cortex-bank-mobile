enum TransactionType {
  income,
  expense,
}

class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.amountCents,
    required this.type,
    required this.date,
  });

  final String id;
  final String title;
  final int amountCents;
  final TransactionType type;
  final DateTime date;
}
