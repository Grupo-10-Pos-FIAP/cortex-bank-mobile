import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cortex_bank_mobile/features/transaction/data/pagination/firestore_transaction_page_cursor.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/data/mappers/transaction_firestore_mapper.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart'
    as model;
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page_cursor.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/statement/statement_filter_criteria.dart';
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

  Query<Map<String, dynamic>> _queryAfterCursor(
    Query<Map<String, dynamic>> query,
    TransactionPageCursor? cursor,
  ) {
    if (cursor == null) return query;
    if (cursor is! FirestoreTransactionPageCursor) {
      throw ArgumentError(
        'Paginação Firestore requer FirestoreTransactionPageCursor',
      );
    }
    return query.startAfterDocument(cursor.documentSnapshot);
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
        .map((d) => transactionFromFirestoreMap(d.data(), d.id))
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
    TransactionPageCursor? startAfterCursor,
    StatementFilterCriteria? criteria,
  }) async {
    if (criteria != null && needsDatasourcePostFilter(criteria)) {
      return _getPageWithCriteriaPostFilter(
        limit,
        startAfterCursor: startAfterCursor,
        criteria: criteria,
      );
    }

    final fetchLimit = limit + 1;
    Query<Map<String, dynamic>> query = _buildQueryWithFilters(criteria)
        .orderBy('date', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(fetchLimit);

    query = _queryAfterCursor(query, startAfterCursor);

    try {
      final snapshot = await query.get();
      return _transactionPageFromDocs(snapshot.docs, limit);
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition' && criteria != null) {
        return _getPageWithCriteriaPostFilter(
          limit,
          startAfterCursor: startAfterCursor,
          criteria: criteria,
        );
      }
      rethrow;
    }
  }

  @override
  Stream<TransactionPage> watchFirstPage(
    int limit, {
    StatementFilterCriteria? criteria,
  }) {
    if (criteria != null && needsDatasourcePostFilter(criteria)) {
      return _watchFirstPageWithPostFilter(limit, criteria);
    }

    final fetchLimit = limit + 1;
    Query<Map<String, dynamic>> query = _buildQueryWithFilters(criteria)
        .orderBy('date', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(fetchLimit);

    return query.snapshots().map(
      (snapshot) => _transactionPageFromDocs(snapshot.docs, limit),
    );
  }

  Stream<TransactionPage> _watchFirstPageWithPostFilter(
    int limit,
    StatementFilterCriteria criteria,
  ) {
    final fetchLimit = (limit * 3) + 1;
    var query = _buildQueryWithDateFilters(criteria)
        .orderBy('date', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(fetchLimit);

    final filterCriteria = criteriaForDatasourceFilter(criteria);

    return query.snapshots().map(
      (snapshot) => _transactionPageFromFilteredDocs(
        snapshot.docs,
        limit,
        filterCriteria,
      ),
    );
  }

  Future<TransactionPage> _getPageWithCriteriaPostFilter(
    int limit, {
    TransactionPageCursor? startAfterCursor,
    required StatementFilterCriteria criteria,
  }) async {
    final fetchLimit = (limit * 3) + 1;
    var query = _buildQueryWithDateFilters(criteria)
        .orderBy('date', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(fetchLimit);

    query = _queryAfterCursor(query, startAfterCursor);

    final snapshot = await query.get();
    final filterCriteria = criteriaForDatasourceFilter(criteria);
    return _transactionPageFromFilteredDocs(
      snapshot.docs,
      limit,
      filterCriteria,
      rawBatchLength: snapshot.docs.length,
      fetchLimit: fetchLimit,
    );
  }

  TransactionPage _transactionPageFromDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    int limit,
  ) {
    final hasMore = docs.length > limit;
    final pageDocs = hasMore ? docs.sublist(0, limit) : docs;
    final items = pageDocs
        .map((d) => transactionFromFirestoreMap(d.data(), d.id))
        .toList();

    return TransactionPage(
      items: items,
      hasMore: hasMore,
      endCursor: pageDocs.isNotEmpty
          ? FirestoreTransactionPageCursor(pageDocs.last)
          : null,
    );
  }

  TransactionPage _transactionPageFromFilteredDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    int limit,
    StatementFilterCriteria filterCriteria, {
    int? rawBatchLength,
    int? fetchLimit,
  }) {
    final filteredDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    final filteredItems = <model.Transaction>[];

    for (final doc in docs) {
      final transaction = transactionFromFirestoreMap(doc.data(), doc.id);
      if (applyStatementFilter([transaction], filterCriteria).isNotEmpty) {
        filteredDocs.add(doc);
        filteredItems.add(transaction);
        if (filteredItems.length > limit) break;
      }
    }

    final items = filteredItems.length > limit
        ? filteredItems.sublist(0, limit)
        : filteredItems;
    final batchLen = rawBatchLength ?? docs.length;
    final batchCap = fetchLimit ?? docs.length;
    final hasMore = filteredItems.length > limit || batchLen == batchCap;
    return TransactionPage(
      items: items,
      hasMore: hasMore,
      endCursor: items.isNotEmpty
          ? FirestoreTransactionPageCursor(filteredDocs[items.length - 1])
          : null,
    );
  }

  /// Constrói uma query com filtros server-side aplicados.
  Query<Map<String, dynamic>> _buildQueryWithFilters(
    StatementFilterCriteria? criteria,
  ) {
    Query<Map<String, dynamic>> query = _transactionsCol;

    if (criteria == null) return query;

    query = _buildQueryWithDateFilters(criteria);

    if (needsDatasourcePostFilter(criteria)) {
      return query;
    }

    final typeValue = tipoFiltroToFirestoreType(criteria.tipoFiltro);
    if (typeValue != null) {
      query = query.where('type', isEqualTo: typeValue);
    }

    final statusValue = statusFiltroToFirestoreStatus(criteria.statusFiltro);
    if (statusValue != null) {
      query = query.where('status', isEqualTo: statusValue);
    }

    if (criteria.categoriaFiltro != 'todas') {
      query = query.where('category', isEqualTo: criteria.categoriaFiltro);
    }

    return query;
  }

  Query<Map<String, dynamic>> _buildQueryWithDateFilters(
    StatementFilterCriteria criteria,
  ) {
    Query<Map<String, dynamic>> query = _transactionsCol;

    if (criteria.dateStart != null) {
      final start = DateTime(
        criteria.dateStart!.year,
        criteria.dateStart!.month,
        criteria.dateStart!.day,
      );
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(start),
      );
    }

    if (criteria.dateEnd != null) {
      final end = firestoreDateEndForStatementQuery(criteria.dateEnd!);
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(end));
    }

    return query;
  }

  @override
  Future<BalanceSummary> getBalanceSummary() async {
    final list = await getAll();
    return BalanceSummary.fromTransactions(list);
  }
}
