/// Constantes para anexos de transação.
abstract class AttachmentConstants {
  AttachmentConstants._();

  static const List<String> allowedExtensions = [
    'pdf',
    'png',
    'jpg',
    'jpeg',
    'heic',
  ];

  static const int maxAttachments = 2;
}
