import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';

/// Janela de data (hoje … +30 dias) e quando a transação entra no saldo.
abstract class TransactionDatePolicy {
  TransactionDatePolicy._();

  static const int futureDaysInclusive = 30;

  static DateTime get today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime get maxSelectableDate =>
      today.add(const Duration(days: futureDaysInclusive));

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime clampToAllowedRange(DateTime date) {
    final d = dateOnly(date);
    if (d.isBefore(today)) return today;
    if (d.isAfter(maxSelectableDate)) return maxSelectableDate;
    return d;
  }

  static bool isAllowed(DateTime date) {
    final d = dateOnly(date);
    return !d.isBefore(today) && !d.isAfter(maxSelectableDate);
  }

  static bool isStrictlyAfterToday(DateTime date) {
    return dateOnly(date).isAfter(today);
  }

  static String get validationMessage =>
      'A data deve ser hoje ou até $futureDaysInclusive dias no futuro (não é permitido data passada).';

  static bool transactionAffectsBalanceNow(
    Transaction transaction, {
    DateTime? asOf,
  }) {
    final refDay = dateOnly(asOf ?? DateTime.now());
    if (transaction.status != TransactionStatus.pending) return true;
    final txDay = dateOnly(transaction.date);
    return !txDay.isAfter(refDay);
  }
}
