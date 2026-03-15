import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { credit, debit, ted }
enum TransactionCategory { food, transport, salary, ted, others }
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

  Transaction({
    this.id = '',
    required this.accountId,
    required this.type,
    required this.value,
    required this.date,
    this.to,
    this.from,
    this.status = 'Completed',
    required this.category,
  });

  factory Transaction.fromFirestore(Map<String, dynamic> data, String docId) {
    return Transaction(
      id: docId,
      accountId: data['accountId'] ?? '',
      type: TransactionTypeExtension.fromString(data['type']),
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      to: data['to'],
      from: data['from'],
      status: data['status'] ?? 'Completed',
      category: TransactionCategoryExtension.fromString(
        data['category'] ?? 'others',
      ), 
    );
  }
}


extension TransactionTypeExtension on TransactionType {
  /* Converte de String do Dropdown/UI para o Enum */
  static TransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'credito':
        return TransactionType.credit;
      case 'ted':
        return TransactionType.ted;
      case 'debito':
      default:
        return TransactionType.debit;
    }
  }

  /* Converte do Enum para String da UI (se precisar exibir o nome) */
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
  /* Converte de String (Banco/API) para o Enum */
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

  /* Nome amigável para mostrar na tela */
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



