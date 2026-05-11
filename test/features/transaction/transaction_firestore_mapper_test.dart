import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/data/mappers/transaction_firestore_mapper.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('transactionFromFirestoreMap', () {
    final pastDate = DateTime(2024, 3, 10);
    final futureDate = DateTime(2099, 12, 1);

    test('deve usar status completed como padrão em mapa mínimo', () {
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

    test('deve usar débito quando tipo estiver ausente', () {
      final t = transactionFromFirestoreMap({
        'date': Timestamp.fromDate(pastDate),
        'accountId': '',
        'value': 0,
        'category': 'others',
      }, 'x');

      expect(t.type, TransactionType.debit);
    });

    test('deve normalizar receiptUrls com tipos mistos para strings', () {
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

    test('deve normalizar pending com data futura para scheduled', () {
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

    test('deve normalizar scheduled na data de política para completed', () {
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
  });
}
