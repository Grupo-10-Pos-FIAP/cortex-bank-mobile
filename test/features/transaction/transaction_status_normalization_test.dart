import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_status_normalization.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final farFuture = DateTime(2099, 6, 15);
  final farPast = DateTime(2020, 1, 1);
  final today = TransactionDatePolicy.today;

  group('normalizeTransactionStatusForRead', () {
    test('deve mapear pending com data futura estrita para scheduled', () {
      expect(
        normalizeTransactionStatusForRead(TransactionStatus.pending, farFuture),
        TransactionStatus.scheduled,
      );
    });

    test('deve mapear completed com data futura estrita para scheduled', () {
      expect(
        normalizeTransactionStatusForRead(
          TransactionStatus.completed,
          farFuture,
        ),
        TransactionStatus.scheduled,
      );
    });

    test('deve mapear scheduled na data de hoje para completed', () {
      expect(
        normalizeTransactionStatusForRead(TransactionStatus.scheduled, today),
        TransactionStatus.completed,
      );
    });

    test('deve mapear scheduled no passado para completed', () {
      expect(
        normalizeTransactionStatusForRead(TransactionStatus.scheduled, farPast),
        TransactionStatus.completed,
      );
    });

    test('deve manter pending no passado', () {
      expect(
        normalizeTransactionStatusForRead(TransactionStatus.pending, farPast),
        TransactionStatus.pending,
      );
    });

    test('deve manter completed no passado', () {
      expect(
        normalizeTransactionStatusForRead(TransactionStatus.completed, farPast),
        TransactionStatus.completed,
      );
    });

    test('deve preservar status desconhecido como string', () {
      expect(
        normalizeTransactionStatusForRead('Unknown', farFuture),
        'Unknown',
      );
    });
  });
}
