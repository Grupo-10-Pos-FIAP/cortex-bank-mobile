import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_storage/firebase_storage.dart';

/// Contrato para upload de recibos/documentos da transação no Firebase Storage.
abstract class ReceiptStorageDataSource {
  /// Faz upload do arquivo e retorna a URL de download.
  /// [transactionId] identifica a transação.
  /// [bytes] conteúdo do arquivo; [fileName] nome original (ex: recibo.pdf).
  Future<String> uploadReceipt(
    String transactionId,
    List<int> bytes,
    String fileName,
  );
}

class ReceiptStorageDataSourceFirebase implements ReceiptStorageDataSource {
  ReceiptStorageDataSourceFirebase(this._storage);

  final FirebaseStorage _storage;

  String get _uid {
    final user = fa.FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    return user.uid;
  }

  @override
  Future<String> uploadReceipt(
    String transactionId,
    List<int> bytes,
    String fileName,
  ) async {
    final sanitized = _sanitizeFileName(fileName);
    final unique = DateTime.now().millisecondsSinceEpoch;
    final path =
        'users/$_uid/transactions/$transactionId/receipts/${unique}_$sanitized';

    final ref = _storage.ref().child(path);
    await ref.putData(
      bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      SettableMetadata(contentType: _contentTypeFromFileName(fileName)),
    );
    return ref.getDownloadURL();
  }

  static String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[^\w\.\-]'), '_');
  }

  static String _contentTypeFromFileName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'application/octet-stream';
  }
}
