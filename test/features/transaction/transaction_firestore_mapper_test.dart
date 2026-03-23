import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/data/mappers/transaction_firestore_mapper.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pastDate = DateTime(2024, 3, 10);
  final futureDate = DateTime(2099, 12, 1);

  test('minimal map defaults status to Completed', () {
    final t = transactionFromFirestoreMap({
      'date': Timestamp.fromDate(pastDate),
      'accountId': 'acc1',
      'type': 'credit',
      'category': 'others',
      'value': 10.5,
    }, 'doc1');
    expect(t.id, 'doc1');
    expect(t.accountId, 'acc1');
    expect(t.type, TransactionType.credit);
    expect(t.category, TransactionCategory.others);
    expect(t.value, 10.5);
    expect(t.status, TransactionStatus.completed);
  });

  test('missing type defaults via extension to debit', () {
    final t = transactionFromFirestoreMap({
      'date': Timestamp.fromDate(pastDate),
      'accountId': '',
      'value': 0,
      'category': 'others',
    }, 'x');
    expect(t.type, TransactionType.debit);
  });

  test('receiptUrls mixed list maps to strings', () {
    final t = transactionFromFirestoreMap({
      'date': Timestamp.fromDate(pastDate),
      'accountId': '',
      'type': 'debit',
      'category': 'others',
      'value': 1,
      'receiptUrls': ['a', 42],
    }, 'y');
    expect(t.receiptUrls, ['a', '42']);
  });

  test('Pending + future date normalizes to Scheduled', () {
    final t = transactionFromFirestoreMap({
      'date': Timestamp.fromDate(futureDate),
      'accountId': '',
      'type': 'debit',
      'category': 'others',
      'value': 1,
      'status': TransactionStatus.pending,
    }, 'z');
    expect(t.status, TransactionStatus.scheduled);
  });

  test('Scheduled + policy today normalizes to Completed', () {
    final t = transactionFromFirestoreMap({
      'date': Timestamp.fromDate(TransactionDatePolicy.today),
      'accountId': '',
      'type': 'debit',
      'category': 'others',
      'value': 1,
      'status': TransactionStatus.scheduled,
    }, 'w');
    expect(t.status, TransactionStatus.completed);
  });
}
