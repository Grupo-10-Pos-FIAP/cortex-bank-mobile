import 'package:flutter_test/flutter_test.dart';

Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 5),
  Duration step = const Duration(milliseconds: 50),
  String? reason,
}) async {
  final end = DateTime.now().add(timeout);
  if (predicate()) return;

  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (predicate()) return;
  }

  throw TestFailure(
    reason ??
        'pumpUntil timed out after ${timeout.inMilliseconds}ms waiting for '
            'predicate to become true.',
  );
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await pumpUntil(
    tester,
    () => finder.evaluate().isNotEmpty,
    timeout: timeout,
    reason: 'Timed out waiting for finder $finder',
  );
}

Future<void> pumpAfterNavigation(
  WidgetTester tester,
  Finder target, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await pumpUntilFound(tester, target, timeout: timeout);
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> pumpSettleAnimations(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 3),
  Duration step = const Duration(milliseconds: 16),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (!tester.hasRunningAnimations) {
      await tester.pump();
      return;
    }
    await tester.pump(step);
  }
  throw TestFailure(
    'pumpSettleAnimations timed out after ${timeout.inMilliseconds}ms '
    '(animations still running).',
  );
}

Future<void> pumpSettleShort(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

Future<void> pumpAfterLayoutStep(WidgetTester tester) async {
  await tester.pump();
  await pumpSettleShort(tester);
}
