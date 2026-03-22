/// Constantes para anexos de transação.
abstract class AttachmentConstants {
  AttachmentConstants._();

  static const List<String> allowedExtensions = ['pdf', 'png', 'jpg', 'jpeg'];

  static const List<String> allowedMimeTypes = [
    'application/pdf',
    'image/png',
    'image/jpeg',
  ];

  static const int maxAttachments = 2;

  /// 5 MB
  static const int maxFileSizeBytes = 5 * 1024 * 1024;
}
