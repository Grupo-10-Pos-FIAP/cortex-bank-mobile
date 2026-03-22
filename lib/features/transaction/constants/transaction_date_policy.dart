import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';

/// Regras de data para transações: **não** permite datas passadas;
/// permite **hoje** até **30 dias à frente** (inclusive).
abstract class TransactionDatePolicy {
  TransactionDatePolicy._();

  /// Quantidade de dias no futuro a partir de hoje permitidos (inclusive o último dia).
  static const int futureDaysInclusive = 30;

  static DateTime get today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime get maxSelectableDate =>
      today.add(const Duration(days: futureDaysInclusive));

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Ajusta [date] para o intervalo permitido (útil ao abrir edição de transação antiga).
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

  /// `true` se o **dia** da transação for **depois** de hoje (não inclui hoje).
  /// Nesse caso a transação deve ficar como **pendente** até a data.
  static bool isStrictlyAfterToday(DateTime date) {
    return dateOnly(date).isAfter(today);
  }

  static String get validationMessage =>
      'A data deve ser hoje ou até $futureDaysInclusive dias no futuro (não é permitido data passada).';

  /// Se a transação deve **compor saldo / entradas / saídas agora** (referência [asOf], default: hoje).
  ///
  /// Transação **pendente** com data **posterior** a [asOf] (agendada) **não** entra até o dia
  /// programado (inclusive), para **crédito, débito e TED**. Concluídas sempre entram.
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
