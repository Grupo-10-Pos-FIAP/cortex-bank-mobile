import 'package:cortex_bank_mobile/features/transaction/constants/attachment_constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

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
  static const _uuid = Uuid();

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
    _validateFile(bytes, fileName);

    final processedBytes = await _compressIfImage(bytes, fileName);
    final ext = fileName.split('.').last.toLowerCase();
    final uniqueName = '${_uuid.v4()}.$ext';
    final path = 'receipts/$_uid/$transactionId/$uniqueName';

    final ref = _storage.ref().child(path);
    await ref.putData(
      processedBytes is Uint8List
          ? processedBytes
          : Uint8List.fromList(processedBytes),
      SettableMetadata(contentType: _contentTypeFromFileName(fileName)),
    );
    return ref.getDownloadURL();
  }

  /// Valida extensão e tamanho do arquivo antes do upload.
  static void _validateFile(List<int> bytes, String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (!AttachmentConstants.allowedExtensions.contains(ext)) {
      throw Exception(
        'Tipo de arquivo não permitido. Use: ${AttachmentConstants.allowedExtensions.join(', ')}',
      );
    }
    if (bytes.length > AttachmentConstants.maxFileSizeBytes) {
      final maxMb = AttachmentConstants.maxFileSizeBytes / (1024 * 1024);
      throw Exception(
        'Arquivo excede o tamanho máximo de ${maxMb.toStringAsFixed(0)}MB.',
      );
    }
  }

  /// Comprime imagens (jpg/png) para reduzir o tamanho do upload.
  /// PDFs são retornados sem modificação.
  static Future<List<int>> _compressIfImage(
    List<int> bytes,
    String fileName,
  ) async {
    final ext = fileName.split('.').last.toLowerCase();
    final isImage = ext == 'jpg' || ext == 'jpeg' || ext == 'png';
    if (!isImage) return bytes;

    if (kIsWeb) return bytes;

    try {
      final compressed = await FlutterImageCompress.compressWithList(
        bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
        minWidth: 1920,
        minHeight: 1920,
        quality: 80,
        format: ext == 'png' ? CompressFormat.png : CompressFormat.jpeg,
      );
      return compressed;
    } catch (_) {
      return bytes;
    }
  }

  static String _contentTypeFromFileName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }
}
