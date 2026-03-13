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
  Future<List<model.Transaction>> getAll() async {
    final snapshot = await _transactionsCol
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((d) => _fromDoc(d)).toList();
  }

  @override
  Future<void> add(model.Transaction transaction) async {
    // Segue a base do Contacts: usa .add() para o Firestore gerar o ID único
    final docRef = await _transactionsCol.add(_toMap(transaction));

    // Opcional: Se o seu objeto 'transaction' precisar carregar o ID gerado pelo Firebase
    // transaction.id = docRef.id;
  }

  @override
  Future<void> delete(String id) async {
    await _transactionsCol.doc(id).delete();
  }

  @override
  Future<BalanceSummary> getBalanceSummary() async {
    final list = await getAll();
    var incomeCents = 0;
    var expenseCents = 0;

    for (final t in list) {
      final cents = (t.value.abs() * 100).round();
      if (t.type == model.TransactionType.credit) {
        incomeCents += cents;
      } else {
        expenseCents += cents;
      }
    }

    return BalanceSummary(
      totalIncomeCents: incomeCents,
      totalExpenseCents: expenseCents,
      balanceCents: incomeCents - expenseCents,
    );
  }

  static Map<String, dynamic> _toMap(model.Transaction t) {
    return {
      'accountId': t.accountId,
      'type': t.type == model.TransactionType.credit ? 'Credit' : 'Debit',
      'value': t.value,
      'date': Timestamp.fromDate(t.date),
      'createdAt': FieldValue.serverTimestamp(),
      'status': t.status.isEmpty ? 'Pending' : t.status,
      'to': t.to,
      'from': t.from,
      'anexo': t.anexo,
      'urlAnexo': t.urlAnexo,
    };
  }

  static model.Transaction _fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    final date = d['date'] as Timestamp?;
    return model.Transaction(
      id: doc.id,
      accountId: d['accountId'] as String? ?? '',
      type: d['type'] == 'Debit'
          ? model.TransactionType.debit
          : model.TransactionType.credit,
      value: (d['value'] as num?)?.toDouble() ?? 0.0,
      date: date?.toDate() ?? DateTime.now(),
      to: d['to'] as String?,
      from: d['from'] as String?,
      status: d['status'] as String? ?? 'Pending',
    );
  }
}
