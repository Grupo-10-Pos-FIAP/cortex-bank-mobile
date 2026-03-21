import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;

Future<void> downloadComprovante(
  String filename,
  String content,
) async {
  try {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes], 'text/plain;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..download = filename
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
    } else {
      final bytes = utf8.encode(content);

      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar comprovante',
        fileName: filename,
        bytes: Uint8List.fromList(bytes),
      );

      if (outputPath != null && !Platform.isAndroid) {
        final file = File(outputPath);
        await file.writeAsBytes(bytes);
      }

    }
  } catch (e) {
    safeLogError('Erro ao baixar comprovante:', e);
    
  }
}
