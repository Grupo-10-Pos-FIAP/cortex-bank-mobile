import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/utils/date_formatter.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart'
    as model;

class ComprovanteContent {
  ComprovanteContent._();

  static const String _bankName = 'CortexBank';

  static String build(model.Transaction transaction, String deValue) {
    final dateStr = DateFormatter.formatDate(transaction.date);
    final timeStr = DateFormatter.formatTime(transaction.date);
    final valueStr = _formatValue(transaction.value);
    final tipoStr = transaction.type == model.TransactionType.ted
        ? 'DOC/TED'
        : transaction.type.label;
    final paraValue = transaction.to ?? '—';
    final descriptionLine =
        (transaction.description != null && transaction.description!.isNotEmpty)
            ? '\nDescrição: ${transaction.description}'
            : '';

    return '''
COMPROVANTE DE TRANSAÇÃO
$_bankName

Data: $dateStr
Hora: $timeStr

De: $deValue
Para: $paraValue
Banco: $_bankName
Tipo: $tipoStr
Valor: $valueStr$descriptionLine
'''.trim();
  }

  static String _formatValue(double value) {
    final cents = (value.abs() * 100).round();
    return formatCentsToBRL(cents);
  }
}
