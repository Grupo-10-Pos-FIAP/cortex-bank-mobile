import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_status_normalization.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final farFuture = DateTime(2099, 6, 15);
  final farPast = DateTime(2020, 1, 1);
  final today = TransactionDatePolicy.today;

  group('normalizeTransactionStatusForRead', () {
    test('Pending + strictly future date -> Scheduled', () {
      expect(
        normalizeTransactionStatusForRead(
          TransactionStatus.pending,
          farFuture,
        ),
        TransactionStatus.scheduled,
      );
    });

    test('Completed + strictly future date -> Scheduled', () {
      expect(
        normalizeTransactionStatusForRead(
          TransactionStatus.completed,
          farFuture,
        ),
        TransactionStatus.scheduled,
      );
    });

    test('Scheduled + today -> Completed', () {
      expect(
        normalizeTransactionStatusForRead(
          TransactionStatus.scheduled,
          today,
        ),
        TransactionStatus.completed,
      );
    });

    test('Scheduled + past -> Completed', () {
      expect(
        normalizeTransactionStatusForRead(
          TransactionStatus.scheduled,
          farPast,
        ),
        TransactionStatus.completed,
      );
    });

    test('Pending + past stays Pending', () {
      expect(
        normalizeTransactionStatusForRead(
          TransactionStatus.pending,
          farPast,
        ),
        TransactionStatus.pending,
      );
    });

    test('Completed + past stays Completed', () {
      expect(
        normalizeTransactionStatusForRead(
          TransactionStatus.completed,
          farPast,
        ),
        TransactionStatus.completed,
      );
    });

    test('unknown status string unchanged', () {
      expect(
        normalizeTransactionStatusForRead('Unknown', farFuture),
        'Unknown',
      );
    });
  });
}
