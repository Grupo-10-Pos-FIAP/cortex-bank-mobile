import 'package:cortex_bank_mobile/features/auth/domain/entities/user.dart';
import 'package:cortex_bank_mobile/features/contacts/domain/entities/contact.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';

/// Serialização JSON para valores armazenados no [SensitiveCacheManager].
abstract final class CacheSerializers {
  static Map<String, dynamic> userToJson(User user) => user.toMap();

  static User userFromJson(Map<String, dynamic> json) => User(
    uid: json['uid'] as String?,
    username: json['username'] as String? ?? '',
    email: json['email'] as String? ?? '',
    branchCode: json['branchCode'] as String? ?? '',
    accountNumber: json['accountNumber'] as String? ?? '',
  );

  static Map<String, dynamic> transactionToJson(Transaction t) => {
    'id': t.id,
    'accountId': t.accountId,
    'type': t.type.name,
    'value': t.value,
    'date': t.date.toUtc().toIso8601String(),
    'to': t.to,
    'from': t.from,
    'status': t.status,
    'category': t.category.name,
    'description': t.description,
    'receiptUrls': t.receiptUrls,
  };

  static Transaction transactionFromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String? ?? '',
      accountId: json['accountId'] as String? ?? '',
      type: TransactionType.values.byName(json['type'] as String),
      value: (json['value'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String).toLocal(),
      to: json['to'] as String?,
      from: json['from'] as String?,
      status: json['status'] as String? ?? TransactionStatus.completed,
      category: TransactionCategory.values.byName(json['category'] as String),
      description: json['description'] as String?,
      receiptUrls:
          (json['receiptUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  static List<Map<String, dynamic>> transactionsToJson(
    List<Transaction> list,
  ) => list.map(transactionToJson).toList();

  static List<Transaction> transactionsFromJson(List<dynamic> json) =>
      json.map((e) => transactionFromJson(e as Map<String, dynamic>)).toList();

  static Map<String, dynamic> contactToJson(Contact c) => {
    'id': c.id,
    'name': c.name,
    'isFavorite': c.isFavorite,
  };

  static Contact contactFromJson(Map<String, dynamic> json) => Contact(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    isFavorite: json['isFavorite'] as bool? ?? false,
  );

  static List<Map<String, dynamic>> contactsToJson(List<Contact> list) =>
      list.map(contactToJson).toList();

  static List<Contact> contactsFromJson(List<dynamic> json) =>
      json.map((e) => contactFromJson(e as Map<String, dynamic>)).toList();

  static Map<String, dynamic> balanceSummaryToJson(BalanceSummary s) => {
    'totalIncomeCents': s.totalIncomeCents,
    'totalExpenseCents': s.totalExpenseCents,
    'balanceCents': s.balanceCents,
  };

  static BalanceSummary balanceSummaryFromJson(Map<String, dynamic> json) =>
      BalanceSummary(
        totalIncomeCents: json['totalIncomeCents'] as int,
        totalExpenseCents: json['totalExpenseCents'] as int,
        balanceCents: json['balanceCents'] as int,
      );
}
