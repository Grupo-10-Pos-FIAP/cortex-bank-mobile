import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_until.dart';
import 'tolerance_golden_comparator.dart';

void goldenTest(String description, WidgetTesterCallback callback) {
  testWidgets(description, (tester) async {
    useToleranceGoldenFileComparator();
    await callback(tester);
  }, tags: ['golden']);
}

ThemeData goldenTestTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppDesignTokens.colorPrimary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppDesignTokens.colorBgLight,
  );
}

Widget goldenTestMaterialApp({
  required Widget home,
  Map<String, WidgetBuilder>? routes,
}) {
  if (routes != null) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: goldenTestTheme(),
      routes: routes,
      home: home,
    );
  }
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: goldenTestTheme(),
    home: home,
  );
}

Widget goldenTestScaffold(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: goldenTestTheme(),
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: child,
          ),
        ),
      ),
    ),
  );
}

Future<void> pumpGolden(
  WidgetTester tester, {
  required Size size,
  required Widget child,
  Future<void> Function(WidgetTester tester)? afterPump,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(goldenTestScaffold(child));
  if (afterPump != null) {
    await afterPump(tester);
  } else {
    await pumpSettleAnimations(tester);
  }
}

Future<void> pumpGoldenMaterialApp(
  WidgetTester tester, {
  required Size size,
  required Widget home,
  Map<String, WidgetBuilder>? routes,
  Future<void> Function(WidgetTester tester)? afterPump,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(goldenTestMaterialApp(home: home, routes: routes));
  if (afterPump != null) {
    await afterPump(tester);
  } else {
    await pumpSettleAnimations(tester);
  }
}
