import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Comparador de goldens com tolerância de pixels para diferenças entre
/// renderização no Linux (CI) e no macOS/Windows (desenvolvimento local).
///
/// Ver exemplo em `package:flutter_test` (`goldens.dart`).
class ToleranceGoldenFileComparator extends LocalFileComparator {
  ToleranceGoldenFileComparator(
    super.testFile, {
    this.precisionTolerance = 0.02,
  }) : assert(
         precisionTolerance >= 0 && precisionTolerance <= 1,
         'precisionTolerance must be between 0 and 1',
       );

  /// Fração máxima de pixels diferentes (0 = idêntico, 1 = totalmente diferente).
  final double precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    final passed =
        result.passed || result.diffPercent <= precisionTolerance;
    if (passed) {
      result.dispose();
      return true;
    }

    final String error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

/// Instala [ToleranceGoldenFileComparator] preservando o diretório do teste atual.
void useToleranceGoldenFileComparator({double precisionTolerance = 0.02}) {
  if (goldenFileComparator is! LocalFileComparator) return;
  final local = goldenFileComparator as LocalFileComparator;
  final testFile = local.basedir.resolve('golden_test_anchor.dart');
  goldenFileComparator = ToleranceGoldenFileComparator(
    testFile,
    precisionTolerance: precisionTolerance,
  );
}
