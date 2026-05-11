import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page_cursor.dart';

/// Cursor de paginação ligado a um [DocumentSnapshot] do Firestore.
final class FirestoreTransactionPageCursor extends TransactionPageCursor {
  FirestoreTransactionPageCursor(this.documentSnapshot);
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot;
}
