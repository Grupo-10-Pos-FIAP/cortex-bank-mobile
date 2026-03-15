import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
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
    });
    return docRef.id;
  }

  @override
  Future<List<model.Transaction>> getAll() async {
    final snapshot = await _transactionsCol
        .orderBy('date', descending: true)
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
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> delete(String id) async =>
      await _transactionsCol.doc(id).delete();

  @override
  Future<BalanceSummary> getBalanceSummary() async {
    final list = await getAll();
    int incomeCents = 0;
    int expenseCents = 0;

    for (final t in list) {
      final cents = (t.value.abs() * 100).round();

      if (t.type == model.TransactionType.credit) {
        incomeCents += cents;
      } else if (t.type == model.TransactionType.debit ||
          t.type == model.TransactionType.ted) {
        expenseCents += cents;
      }
    }

    return BalanceSummary(
      totalIncomeCents: incomeCents,
      totalExpenseCents: expenseCents,
      balanceCents: incomeCents - expenseCents,
    );
  }
}
