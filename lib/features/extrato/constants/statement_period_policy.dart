import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';

/// Período do extrato: intervalo flexível (início e fim), sem datas futuras, máx. 90 dias.
abstract class StatementPeriodPolicy {
  StatementPeriodPolicy._();

  /// Dias corridos no intervalo (início e fim inclusos).
  static const int maxInclusiveDays = 90;

  /// Dias anteriores a hoje para o início mais antigo (hoje − 89 = 90 dias).
  static const int maxDaysBeforeToday = 89;

  static DateTime get today => TransactionDatePolicy.today;

  static DateTime dateOnly(DateTime d) => TransactionDatePolicy.dateOnly(d);

  /// Primeiro dia selecionável no calendário do extrato.
  static DateTime get earliestSelectableStart {
    final d = today.subtract(const Duration(days: maxDaysBeforeToday));
    return DateTime(d.year, d.month, d.day);
  }

  /// Último instante do dia de hoje (fim do período).
  static DateTime get lastSelectableEnd {
    return DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
      999,
    );
  }

  static DateTime clampStartDay(DateTime date) {
    final day = dateOnly(date);
    final earliest = dateOnly(earliestSelectableStart);
    if (day.isBefore(earliest)) {
      return earliest;
    }
    if (day.isAfter(today)) {
      return today;
    }
    return day;
  }

  static DateTime clampEndDay(DateTime date) {
    final day = dateOnly(date);
    if (day.isAfter(today)) {
      return today;
    }
    return day;
  }

  /// Maior data final permitida para um início dado (respeita 90 dias e hoje).
  static DateTime maxEndDayForStart(DateTime start) {
    final startDay = dateOnly(clampStartDay(start));
    final spanCap = startDay.add(const Duration(days: maxDaysBeforeToday));
    final cap = dateOnly(spanCap).isAfter(today) ? today : dateOnly(spanCap);
    return DateTime(cap.year, cap.month, cap.day, 23, 59, 59, 999);
  }

  static int inclusiveDayCount(DateTime start, DateTime end) {
    return dateOnly(end).difference(dateOnly(start)).inDays + 1;
  }

  static bool isValidRange(DateTime start, DateTime end) {
    final s = dateOnly(start);
    final e = dateOnly(end);
    if (e.isBefore(s)) return false;
    if (s.isBefore(dateOnly(earliestSelectableStart))) return false;
    if (e.isAfter(today)) return false;
    return inclusiveDayCount(s, e) <= maxInclusiveDays;
  }

  static DateTime endOfDay(DateTime day) => DateTime(
        day.year,
        day.month,
        day.day,
        23,
        59,
        59,
        999,
      );

  static String get rangeValidationMessage =>
      'O período deve ter entre ${_formatDay(earliestSelectableStart)} e hoje, '
      'com no máximo $maxInclusiveDays dias entre início e fim.';
}

String _formatDay(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
