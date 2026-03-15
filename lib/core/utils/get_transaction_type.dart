import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart'
    as model;

extension TransactionTypeExtension on model.TransactionType {  
  /* Converte de String do Dropdown/UI para o Enum */
  static model.TransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'credito':
        return model.TransactionType.credit;
      case 'ted':
        return model.TransactionType.ted;
      case 'debito':
      default:
        return model.TransactionType.debit;
    }
  }

  /* Converte do Enum para String da UI (se precisar exibir o nome) */
  String get label {
    switch (this) {
      case model.TransactionType.credit:
        return 'Crédito';
      case model.TransactionType.debit:
        return 'Débito';
      case model.TransactionType.ted:
        return 'TED';
    }
  }
}
