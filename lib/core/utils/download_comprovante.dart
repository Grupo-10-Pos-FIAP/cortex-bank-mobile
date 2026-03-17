import 'download_comprovante_stub.dart'
    if (dart.library.html) 'download_comprovante_web.dart' as impl;

/// Dispara o download do comprovante.
/// Na web: salva o arquivo na pasta Downloads do navegador.
/// Em outras plataformas: lança [UnsupportedError].
Future<void> downloadComprovante(String filename, String content) =>
    impl.downloadComprovante(filename, content);
