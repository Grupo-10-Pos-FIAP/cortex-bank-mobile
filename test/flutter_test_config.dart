import 'package:cortex_bank_mobile/core/cache/cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/test_setup.dart';

Future<void> testExecutable(Future<void> Function() testMain) async {
  // Goldens/CI: sem HTTP; fontes em `fonts/*.ttf` listadas no pubspec.yaml.
  GoogleFonts.config.allowRuntimeFetching = false;
  registerCommonFallbackValues();
  setUp(() => CacheManager.clear());
  tearDown(() => CacheManager.clear());
  await testMain();
}
