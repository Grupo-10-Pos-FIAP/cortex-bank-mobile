import 'package:cortex_bank_mobile/features/transaction/constants/attachment_constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as im;
import 'package:uuid/uuid.dart';

abstract class ReceiptStorageDataSource {
  Future<String> uploadReceipt(
    String transactionId,
    List<int> bytes,
    String fileName,
  );
}

class _PreparedReceipt {
  const _PreparedReceipt({
    required this.bytes,
    required this.extension,
    required this.contentType,
  });

  final List<int> bytes;
  final String extension;
  final String contentType;
}

class ReceiptStorageDataSourceFirebase implements ReceiptStorageDataSource {
  ReceiptStorageDataSourceFirebase(this._storage);

  final FirebaseStorage _storage;
  static const _uuid = Uuid();

  static const int _maxImageSide = 1920;
  static const int _jpegQuality = 80;

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

    final prepared = await _prepareReceiptBytes(bytes, fileName);
    final uniqueName = '${_uuid.v4()}.${prepared.extension}';
    final path = 'receipts/$_uid/$transactionId/$uniqueName';

    final ref = _storage.ref().child(path);
    final data = prepared.bytes is Uint8List
        ? prepared.bytes as Uint8List
        : Uint8List.fromList(prepared.bytes);
    await ref.putData(
      data,
      SettableMetadata(contentType: prepared.contentType),
    );
    return ref.getDownloadURL();
  }

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

  static Future<_PreparedReceipt> _prepareReceiptBytes(
    List<int> bytes,
    String fileName,
  ) async {
    final ext = fileName.split('.').last.toLowerCase();

    if (ext == 'pdf') {
      return _PreparedReceipt(
        bytes: bytes,
        extension: 'pdf',
        contentType: 'application/pdf',
      );
    }

    final isRaster = ext == 'jpg' || ext == 'jpeg' || ext == 'png';
    if (!isRaster) {
      return _PreparedReceipt(
        bytes: bytes,
        extension: ext,
        contentType: _contentTypeFromFileName(fileName),
      );
    }

    if (kIsWeb) {
      final optimized = _optimizeRasterForWeb(bytes);
      if (optimized != null) {
        return _PreparedReceipt(
          bytes: optimized,
          extension: 'jpg',
          contentType: 'image/jpeg',
        );
      }
      return _PreparedReceipt(
        bytes: bytes,
        extension: ext,
        contentType: _contentTypeFromFileName(fileName),
      );
    }

    try {
      final compressed = await FlutterImageCompress.compressWithList(
        bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
        minWidth: _maxImageSide,
        minHeight: _maxImageSide,
        quality: _jpegQuality,
        format: ext == 'png' ? CompressFormat.png : CompressFormat.jpeg,
      );
      return _PreparedReceipt(
        bytes: compressed,
        extension: ext,
        contentType: _contentTypeFromFileName(fileName),
      );
    } catch (_) {
      return _PreparedReceipt(
        bytes: bytes,
        extension: ext,
        contentType: _contentTypeFromFileName(fileName),
      );
    }
  }

  static List<int>? _optimizeRasterForWeb(List<int> bytes) {
    try {
      final decoded = im.decodeImage(Uint8List.fromList(bytes));
      if (decoded == null) return null;

      im.Image work = decoded;
      if (work.width > _maxImageSide || work.height > _maxImageSide) {
        if (work.width >= work.height) {
          work = im.copyResize(
            work,
            width: _maxImageSide,
            interpolation: im.Interpolation.average,
          );
        } else {
          work = im.copyResize(
            work,
            height: _maxImageSide,
            interpolation: im.Interpolation.average,
          );
        }
      }

      return im.encodeJpg(work, quality: _jpegQuality);
    } catch (_) {
      return null;
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
