import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex_bank_mobile/core/utils/get_transaction_type.dart';

enum TransactionType { credit, debit, ted }

class Transaction {
  final String id;
  final String accountId;
  final TransactionType type;
  final double value;
  final DateTime date;
  final String? to;
  final String? from;
  final String status;

  Transaction({
    this.id = '',
    required this.accountId,
    required this.type,
    required this.value,
    required this.date,
    this.to,
    this.from,
    this.status = 'Completed',
  });

  factory Transaction.fromFirestore(Map<String, dynamic> data, String docId) {
    return Transaction(
      id: docId,
      accountId: data['accountId'] ?? '',
      type: TransactionTypeExtension.fromString(data['type']),
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      to: data['to'],
      from: data['from'],
      status: data['status'] ?? 'Completed',
    );
  }
}
