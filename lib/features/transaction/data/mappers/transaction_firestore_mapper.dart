import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_status_normalization.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';

/// Constrói [Transaction] a partir de um documento Firestore (mapa + id).
Transaction transactionFromFirestoreMap(Map<String, dynamic> data, String docId) {
  final receipts = data['receiptUrls'];
  final list = receipts is List
      ? receipts.map((e) => e is String ? e : e.toString()).toList()
      : <String>[];
  final date = (data['date'] as Timestamp).toDate();
  final rawStatus = data['status'] ?? TransactionStatus.completed;
  final storedStatus =
      rawStatus is String ? rawStatus : rawStatus.toString();
  final status = normalizeTransactionStatusForRead(storedStatus, date);

  return Transaction(
    id: docId,
    accountId: data['accountId'] ?? '',
    type: TransactionTypeExtension.fromString(
      (data['type'] ?? '').toString(),
    ),
    value: (data['value'] as num?)?.toDouble() ?? 0.0,
    date: date,
    to: data['to'] as String?,
    from: data['from'] as String?,
    status: status,
    category: TransactionCategoryExtension.fromString(
      data['category'] ?? 'others',
    ),
    description: data['description'] as String?,
    receiptUrls: list,
  );
}
