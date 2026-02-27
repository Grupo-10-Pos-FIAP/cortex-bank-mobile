import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart' as model;
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart';

const String _collection = 'transactions';

class TransactionsDataSourceFirestore implements TransactionsDataSource {
  TransactionsDataSourceFirestore(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  @override
  Future<void> add(model.Transaction transaction) async {
    await _col.doc(transaction.id).set(_toMap(transaction));
  }

  @override
  Future<List<model.Transaction>> getAll() async {
    print('DEBUG Firestore: buscando transactions...');
    final snapshot = await _col.get();

    print('DEBUG Firestore: qtd docs = ${snapshot.docs.length}');
    for (final d in snapshot.docs) {
      print('DEBUG Firestore doc: id=${d.id}, data=${d.data()}');
    }

    return snapshot.docs.map((d) => _fromDoc(d)).toList();
  }

  @override
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
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
      'id': t.id,
      'accountId': t.accountId,
      'type': t.type == model.TransactionType.credit ? 'Credit' : 'Debit',
      'value': t.value,
      'date': Timestamp.fromDate(t.date),
      'status': t.status.isEmpty ? 'Pending' : t.status,
      if (t.from != null && t.from!.isNotEmpty) 'from': t.from,
      if (t.to != null && t.to!.isNotEmpty) 'to': t.to,
      if (t.anexo != null && t.anexo!.isNotEmpty) 'anexo': t.anexo,
      if (t.urlAnexo != null && t.urlAnexo!.isNotEmpty) 'urlAnexo': t.urlAnexo,
    };
  }

  static model.Transaction _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final date = d['date'];
    final value = (d['value'] as num?)?.toDouble() ?? 0.0;
    final typeStr = d['type'] as String? ?? 'Credit';
    return model.Transaction(
      id: d['id'] as String? ?? doc.id,
      accountId: d['accountId'] as String? ?? '',
      type: typeStr == 'Debit' ? model.TransactionType.debit : model.TransactionType.credit,
      value: value,
      date: date is Timestamp ? date.toDate() : DateTime.now(),
      from: d['from'] as String?,
      to: d['to'] as String?,
      anexo: d['anexo'] as String?,
      urlAnexo: d['urlAnexo'] as String?,
      status: (d['status'] as String?) ?? 'Pending',
    );
  }
}
