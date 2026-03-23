import 'package:cloud_firestore/cloud_firestore.dart';

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

  static bool _isStrictlyAfterToday(DateTime date) {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final d = DateTime(date.year, date.month, date.day);
    return d.isAfter(today);
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

  factory Transaction.fromFirestore(Map<String, dynamic> data, String docId) {
    final receipts = data['receiptUrls'];
    final list = receipts is List
        ? (receipts)
            .map((e) => e is String ? e : e.toString())
            .toList()
        : <String>[];
    final date = (data['date'] as Timestamp).toDate();
    var status = data['status'] ?? TransactionStatus.completed;
    if (status == TransactionStatus.pending &&
        TransactionStatus._isStrictlyAfterToday(date)) {
      status = TransactionStatus.scheduled;
    }
    // Legado / gravação incorreta: "Completa" com data ainda futura → tratar como agendada.
    if (status == TransactionStatus.completed &&
        TransactionStatus._isStrictlyAfterToday(date)) {
      status = TransactionStatus.scheduled;
    }
    // Agendada só é consistente com data futura; hoje ou passado não pode ser Scheduled.
    if (status == TransactionStatus.scheduled &&
        !TransactionStatus._isStrictlyAfterToday(date)) {
      status = TransactionStatus.completed;
    }
    return Transaction(
      id: docId,
      accountId: data['accountId'] ?? '',
      type: TransactionTypeExtension.fromString(data['type']),
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      date: date,
      to: data['to'],
      from: data['from'],
      status: status,
      category: TransactionCategoryExtension.fromString(
        data['category'] ?? 'others',
      ),
      description: data['description'],
      receiptUrls: list,
    );
  }

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



