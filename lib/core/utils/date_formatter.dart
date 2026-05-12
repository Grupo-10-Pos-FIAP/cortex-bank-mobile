/// Formatação de data/hora para exibição (dd/MM/yyyy, HH:mm).
class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Meia-noite local sem fração — típico de data escolhida no calendário sem horário.
  static bool isMidnightDateOnly(DateTime date) {
    return date.hour == 0 &&
        date.minute == 0 &&
        date.second == 0 &&
        date.millisecond == 0 &&
        date.microsecond == 0;
  }

  /// [formatTime] ou `null` quando o registro parece ser só data civil.
  static String? formatTimeIfSpecified(DateTime date) {
    if (isMidnightDateOnly(date)) return null;
    return formatTime(date);
  }

  /// Lista / resumo: `dd/MM/yyyy` ou `dd/MM/yyyy • HH:mm`.
  static String formatDateOptionalTimeLine(DateTime date) {
    final t = formatTimeIfSpecified(date);
    if (t == null) return formatDate(date);
    return '${formatDate(date)} • $t';
  }

  /// Coluna de hora no detalhe (coerente com a linha da lista).
  static String formatTimeForDetail(DateTime date) {
    return formatTimeIfSpecified(date) ?? '—';
  }
}
