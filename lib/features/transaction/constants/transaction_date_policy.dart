import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';

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

  /// Usa o dia civil de [day] com hora/minuto/segundo de [timeSource]
  /// (útil após [showDatePicker], que devolve meia-noite).
  static DateTime combineDateWithTime(DateTime day, DateTime timeSource) {
    return DateTime(
      day.year,
      day.month,
      day.day,
      timeSource.hour,
      timeSource.minute,
      timeSource.second,
      timeSource.millisecond,
      timeSource.microsecond,
    );
  }

  /// Como [clampToAllowedRange], mas mantém o horário de [date].
  static DateTime clampToAllowedRangePreservingTime(DateTime date) {
    return combineDateWithTime(clampToAllowedRange(date), date);
  }

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

  static bool isSameCalendarDay(DateTime a, DateTime b) {
    return dateOnly(a) == dateOnly(b);
  }

  static String get validationMessage =>
      'A data deve ser hoje ou até $futureDaysInclusive dias no futuro (não é permitido data passada).';

  /// Inclui a transação no saldo “agora”. Sem [asOf], usa [today] — mesma regra que
  /// o resumo de saldo no Firestore (`getBalanceSummary`) e o card do dashboard.
  /// Gráficos do início devem chamar sem [asOf] para alinhar ao saldo exibido.
  ///
  /// - [TransactionStatus.scheduled]: entra no saldo quando a data da transação
  ///   chega (mesmo dia ou anterior ao dia de referência).
  /// - [TransactionStatus.pending]: não altera saldo até virar [Completed].
  static bool transactionAffectsBalanceNow(
    Transaction transaction, {
    DateTime? asOf,
  }) {
    final refDay = dateOnly(asOf ?? DateTime.now());
    if (transaction.status == TransactionStatus.pending) {
      return false;
    }
    if (transaction.status == TransactionStatus.scheduled) {
      final txDay = dateOnly(transaction.date);
      return !txDay.isAfter(refDay);
    }
    return true;
  }
}
