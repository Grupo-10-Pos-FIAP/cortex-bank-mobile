import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cortex_bank_mobile/features/transaction/data/pagination/firestore_transaction_page_cursor.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
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
    final fetchLimit = limit + 1;
    Query<Map<String, dynamic>> query = _buildQueryWithFilters(criteria)
        .orderBy('date', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(fetchLimit);

    query = _queryAfterCursor(query, startAfterCursor);

    try {
      final snapshot = await query.get();
      final allDocs = snapshot.docs;
      final hasMore = allDocs.length > limit;
      final pageDocs = hasMore ? allDocs.sublist(0, limit) : allDocs;
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
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition' && criteria != null) {
        return await _getPageWithDateFallback(
          limit,
          startAfterCursor: startAfterCursor,
          criteria: criteria,
        );
      }
      rethrow;
    }
  }

  Future<TransactionPage> _getPageWithDateFallback(
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
    final filteredDocs = <DocumentSnapshot<Map<String, dynamic>>>[];
    final filteredItems = <model.Transaction>[];

    for (final doc in snapshot.docs) {
      final transaction = transactionFromFirestoreMap(doc.data(), doc.id);
      if (applyStatementFilter([transaction], criteria).isNotEmpty) {
        filteredDocs.add(doc);
        filteredItems.add(transaction);
        if (filteredItems.length > limit) break;
      }
    }

    final items = filteredItems.length > limit
        ? filteredItems.sublist(0, limit)
        : filteredItems;
    final hasMore =
        filteredItems.length > limit || snapshot.docs.length == fetchLimit;
    return TransactionPage(
      items: items,
      hasMore: hasMore,
      endCursor: items.isNotEmpty
          ? FirestoreTransactionPageCursor(filteredDocs[items.length - 1])
          : null,
    );
  }

  /// Constrói uma query com filtros server-side aplicados.
  /// NOTA: Por limitações de índices, aplicamos apenas filtros que têm índices compostos.
  Query<Map<String, dynamic>> _buildQueryWithFilters(
    StatementFilterCriteria? criteria,
  ) {
    Query<Map<String, dynamic>> query = _transactionsCol;

    if (criteria == null) return query;

    // Aplicar apenas filtros que sabemos ter índices
    // Priorizar filtros mais comuns primeiro

    // Filtro de data - sempre aplicado se presente
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
      final end = DateTime(
        criteria.dateEnd!.year,
        criteria.dateEnd!.month,
        criteria.dateEnd!.day,
        23,
        59,
        59,
        999,
      );
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(end));
    }

    // Aplicar apenas UM filtro adicional para evitar problemas de índices
    // Prioridade: tipo > status > categoria > valor
    if (criteria.tipoFiltro != 'todas') {
      query = query.where('type', isEqualTo: criteria.tipoFiltro);
    } else if (criteria.statusFiltro != 'todas') {
      final statusMap = {
        'completa': 'completed',
        'agendada': 'scheduled',
        'pendente': 'pending',
      };
      final statusValue = statusMap[criteria.statusFiltro];
      if (statusValue != null) {
        query = query.where('status', isEqualTo: statusValue);
      }
    } else if (criteria.categoriaFiltro != 'todas') {
      query = query.where('category', isEqualTo: criteria.categoriaFiltro);
    } else if (criteria.minCents > 0 || criteria.maxCents > 0) {
      // Filtros de valor são mais complexos, deixar para client-side por enquanto
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
      final end = DateTime(
        criteria.dateEnd!.year,
        criteria.dateEnd!.month,
        criteria.dateEnd!.day,
        23,
        59,
        59,
        999,
      );
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(end));
    }

    return query;
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
