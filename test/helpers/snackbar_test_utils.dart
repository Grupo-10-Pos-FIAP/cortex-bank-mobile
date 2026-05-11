import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> dismissTestSnackBars(WidgetTester tester) async {
  AppSnackBar.hide();
  await tester.pump();
  await tester.pump(
    const Duration(seconds: 3) + const Duration(milliseconds: 200),
  );
}
