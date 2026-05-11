import 'package:cortex_bank_mobile/core/cache/cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(Future<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => CacheManager.clear());
  tearDown(() => CacheManager.clear());
  await testMain();
}
