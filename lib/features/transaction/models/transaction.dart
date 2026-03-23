enum TransactionType { credit, debit, ted }
enum TransactionCategory { food, transport, salary, ted, others }

abstract class TransactionStatus {
  TransactionStatus._();
  static const String pending = 'Pending';
  /// Só é válido com data **estritamente posterior a hoje** (programada na janela permitida).
  /// Data de hoje ou passada não usa este status (usa [pending] ou [completed]).
  static const String scheduled = 'Scheduled';
  static const String completed = 'Completed';

  static String labelPt(String status) {
    if (status == pending) return 'Pendente';
    if (status == scheduled) return 'Agendada';
    if (status == completed) return 'Completa';
    return status;
  }
}

class Transaction {
  final String id;
  final String accountId;
  final TransactionType type;
  final double value;
  final DateTime date;
  final String? to;
  final String? from;
  final String status;
  final TransactionCategory category;
  final String? description;
  final List<String> receiptUrls;

  Transaction({
    this.id = '',
    required this.accountId,
    required this.type,
    required this.value,
    required this.date,
    this.to,
    this.from,
    this.status = TransactionStatus.completed,
    required this.category,
    this.description,
    List<String>? receiptUrls,
  }) : receiptUrls = receiptUrls ?? const [];

  Transaction copyWith({
    String? id,
    String? accountId,
    TransactionType? type,
    double? value,
    DateTime? date,
    String? to,
    String? from,
    String? status,
    TransactionCategory? category,
    String? description,
    List<String>? receiptUrls,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      value: value ?? this.value,
      date: date ?? this.date,
      to: to ?? this.to,
      from: from ?? this.from,
      status: status ?? this.status,
      category: category ?? this.category,
      description: description ?? this.description,
      receiptUrls: receiptUrls ?? this.receiptUrls,
    );
  }
}


extension TransactionTypeExtension on TransactionType {
  static TransactionType fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'credit':
      case 'credito':
      case 'crédito':
        return TransactionType.credit;
      case 'ted':
        return TransactionType.ted;
      case 'debit':
      case 'debito':
      case 'débito':
        return TransactionType.debit;
      default:
        return TransactionType.debit;
    }
  }

  String get label {
    switch (this) {
      case TransactionType.credit:
        return 'Crédito';
      case TransactionType.debit:
        return 'Débito';
      case TransactionType.ted:
        return 'TED';
    }
  }
}


extension TransactionCategoryExtension on TransactionCategory {
  static TransactionCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'food':
      case 'alimentação':
        return TransactionCategory.food;
      case 'transport':
      case 'transporte':
        return TransactionCategory.transport;
      case 'ted':
        return TransactionCategory.ted;
      case 'salary':
      case 'salário':
        return TransactionCategory.salary;
      default:
        return TransactionCategory.others;
    }
  }

  String get label {
    switch (this) {
      case TransactionCategory.food:
        return 'Alimentação';
      case TransactionCategory.transport:
        return 'Transporte';
      case TransactionCategory.ted:
        return 'TED';
      case TransactionCategory.salary:
        return 'Salário';
      case TransactionCategory.others:
        return 'Outros';
    }
  }
}



