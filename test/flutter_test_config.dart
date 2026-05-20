import 'dart:typed_data';

import 'package:cortex_bank_mobile/core/cache/cache_manager.dart';
import 'package:cortex_bank_mobile/core/cache/sensitive_cache_manager.dart';
import 'package:cortex_bank_mobile/core/security/encryption_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/test_setup.dart';

Future<void> testExecutable(Future<void> Function() testMain) async {
  // Goldens/CI: sem HTTP; fontes em `fonts/*.ttf` listadas no pubspec.yaml.
  GoogleFonts.config.allowRuntimeFetching = false;
  registerCommonFallbackValues();
  SensitiveCacheManager.useEncryptionForTests(
    EncryptionService(Uint8List.fromList(List<int>.generate(32, (i) => i))),
  );
  setUp(() {
    CacheManager.clear();
    SensitiveCacheManager.clear();
  });
  tearDown(() {
    CacheManager.clear();
    SensitiveCacheManager.clear();
  });
  await testMain();
}
