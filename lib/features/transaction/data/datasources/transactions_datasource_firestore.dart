import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart'
    as model;
import 'transactions_datasource.dart';

class TransactionsDataSourceFirestore implements TransactionsDataSource {
  final FirebaseFirestore _firestore;
  TransactionsDataSourceFirestore(this._firestore);

  CollectionReference<Map<String, dynamic>> get _transactionsCol {
    final user = fa.FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  

  @override
  Future<String> add(model.Transaction transaction) async {
    final docRef = await _transactionsCol.add({
      'accountId': transaction.accountId,
      'type': transaction.type.name,
      'category': transaction.category.name,
      'value': transaction.value,
      'date': Timestamp.fromDate(transaction.date),
      'createdAt': FieldValue.serverTimestamp(),
      'to': transaction.to,
      'from': transaction.from,
      'status': transaction.status,
      'description': transaction.description,
      'receiptUrls': transaction.receiptUrls,
    });
    return docRef.id;
  }

  @override
  Future<List<model.Transaction>> getAll() async {
    final snapshot = await _transactionsCol
        .orderBy('date', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .get();
    return snapshot.docs
        .map((d) => model.Transaction.fromFirestore(d.data(), d.id))
        .toList();
  }

  @override
  Future<void> update(model.Transaction transaction) async {
    await _transactionsCol.doc(transaction.id).update({
      'accountId': transaction.accountId,
      'type': transaction.type.name,
      'category': transaction.category.name,
      'value': transaction.value,
      'date': Timestamp.fromDate(transaction.date),
      'to': transaction.to,
      'from': transaction.from,
      'status': transaction.status,
      'description': transaction.description,
      'receiptUrls': transaction.receiptUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> delete(String id) async =>
      await _transactionsCol.doc(id).delete();

  @override
  Future<TransactionPage> getPage(
    int limit, {
    dynamic startAfterDocument,
  }) async {
    final fetchLimit = limit + 1;
    Query<Map<String, dynamic>> query = _transactionsCol
        .orderBy('date', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(fetchLimit);

    if (startAfterDocument != null) {
      query = query.startAfterDocument(
        startAfterDocument as DocumentSnapshot,
      );
    }

    final snapshot = await query.get();
    final allDocs = snapshot.docs;
    final hasMore = allDocs.length > limit;
    final pageDocs = hasMore ? allDocs.sublist(0, limit) : allDocs;
    final items = pageDocs
        .map((d) => model.Transaction.fromFirestore(d.data(), d.id))
        .toList();

    return TransactionPage(
      items: items,
      hasMore: hasMore,
      lastDocument: pageDocs.isNotEmpty ? pageDocs.last : null,
    );
  }

  @override
  Future<BalanceSummary> getBalanceSummary() async {
    final list = await getAll();
    int incomeCents = 0;
    int expenseCents = 0;

    for (final t in list) {
      final cents = (t.value.abs() * 100).round();

      if (t.type == model.TransactionType.credit) {
        if (TransactionDatePolicy.transactionAffectsBalanceNow(t)) {
          incomeCents += cents;
        }
      } else if (t.type == model.TransactionType.debit ||
          t.type == model.TransactionType.ted) {
        if (TransactionDatePolicy.transactionAffectsBalanceNow(t)) {
          expenseCents += cents;
        }
      }
    }

    return BalanceSummary(
      totalIncomeCents: incomeCents,
      totalExpenseCents: expenseCents,
      balanceCents: incomeCents - expenseCents,
    );
  }
}
