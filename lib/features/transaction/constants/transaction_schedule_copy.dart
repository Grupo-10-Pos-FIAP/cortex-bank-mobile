import 'package:cortex_bank_mobile/core/utils/date_formatter.dart';

abstract class TransactionScheduleCopy {
  TransactionScheduleCopy._();

  static const String cardSectionTitle = 'Nova transação';

  static const String primaryButtonLabelImmediate = 'Confirmar transação';

  static const String dialogTitleImmediate = 'Confirmar Transação';

  static const String dialogMessageImmediate =
      'Deseja realmente realizar esta transação?';

  static const String dialogConfirmImmediate = 'Confirmar';

  static const String loadingTitleImmediate = 'Efetuando transação…';

  static const String loadingSubtitleImmediate = 'Aguarde um instante';

  static const String successImmediate = 'Transação realizada com sucesso!';

  static String warningReceiptPartialImmediate({
    required String files,
    required int count,
    required String? detail,
  }) {
    final recibo = count == 1 ? 'o recibo' : 'alguns recibos';
    final tail = detail != null && detail.isNotEmpty ? '\n\n$detail' : '';
    final extrato = '\n\nVocê pode anexar os arquivos depois pelo extrato.';
    return 'Transação registrada, mas houve falha ao enviar $recibo: $files.$tail$extrato';
  }

  static const String errorSubmitFallbackImmediate =
      'Não foi possível registrar a transação. Verifique sua conexão e tente novamente.';

  static const String primaryButtonLabelScheduled = 'Confirmar agendamento';

  static const String dialogTitleScheduled = 'Confirmar agendamento';

  static String dialogMessageScheduled(DateTime date) {
    final formatted = DateFormatter.formatDate(date);
    return 'A transação será agendada para $formatted e ficará pendente até essa data. Deseja continuar?';
  }

  static const String dialogConfirmScheduled = 'Agendar';

  static const String loadingTitleScheduled = 'Agendando transação…';

  static const String loadingSubtitleScheduled =
      'Salvando o agendamento e os anexos, se houver.';

  static String successScheduled(String formattedDate) =>
      'Agendamento concluído. A transação fica pendente até $formattedDate.';

  static String warningReceiptPartialScheduled({
    required String files,
    required int count,
    required String? detail,
  }) {
    final recibo = count == 1 ? 'o recibo' : 'alguns recibos';
    final tail = detail != null && detail.isNotEmpty ? '\n\n$detail' : '';
    final extrato = '\n\nVocê pode anexar pelo extrato depois.';
    return 'Agendamento salvo, mas não foi possível enviar $recibo: $files.$tail$extrato';
  }

  static const String errorSubmitFallbackScheduled =
      'Não foi possível concluir o agendamento. Verifique sua conexão e tente novamente.';

  static const String hintFutureDate =
      'Data futura: a transação será agendada e ficará pendente até o dia selecionado.';

  static String primaryButtonLabel({required bool isScheduled}) =>
      isScheduled ? primaryButtonLabelScheduled : primaryButtonLabelImmediate;

  static String dialogTitle({required bool isScheduled}) =>
      isScheduled ? dialogTitleScheduled : dialogTitleImmediate;

  static String dialogMessage(DateTime date, {required bool isScheduled}) =>
      isScheduled
          ? dialogMessageScheduled(date)
          : dialogMessageImmediate;

  static String dialogConfirmLabel({required bool isScheduled}) =>
      isScheduled ? dialogConfirmScheduled : dialogConfirmImmediate;

  static String loadingTitle({required bool isScheduled}) =>
      isScheduled ? loadingTitleScheduled : loadingTitleImmediate;

  static String loadingSubtitle({required bool isScheduled}) =>
      isScheduled
          ? loadingSubtitleScheduled
          : loadingSubtitleImmediate;

  static String successAllOk({
    required bool isScheduled,
    required String formattedDate,
  }) =>
      isScheduled
          ? successScheduled(formattedDate)
          : successImmediate;

  static String warningReceiptPartial({
    required bool isScheduled,
    required String files,
    required int count,
    required String? detail,
  }) =>
      isScheduled
          ? warningReceiptPartialScheduled(
              files: files,
              count: count,
              detail: detail,
            )
          : warningReceiptPartialImmediate(
              files: files,
              count: count,
              detail: detail,
            );

  static String errorSubmitFallback({required bool isScheduled}) =>
      isScheduled
          ? errorSubmitFallbackScheduled
          : errorSubmitFallbackImmediate;
}
