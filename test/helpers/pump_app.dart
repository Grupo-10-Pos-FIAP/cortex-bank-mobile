import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<SingleChildWidget> providers = const <SingleChildWidget>[],
  ThemeData? theme,
  Map<String, WidgetBuilder>? routes,
  String? initialRoute,
  NavigatorObserver? navigatorObserver,
  Locale? locale,
}) async {
  assert(
    initialRoute == null,
    'pumpApp: não use `initialRoute` com `child` como home. '
    'Use apenas `routes` + `home` (este helper fixa `home: child`) ou um '
    'MaterialApp próprio no teste.',
  );

  final app = MaterialApp(
    theme: theme,
    locale: locale,
    routes: routes ?? const <String, WidgetBuilder>{},
    initialRoute: initialRoute,
    navigatorObservers: navigatorObserver != null
        ? <NavigatorObserver>[navigatorObserver]
        : const <NavigatorObserver>[],
    home: child,
  );

  if (providers.isEmpty) {
    await tester.pumpWidget(app);
    return;
  }

  await tester.pumpWidget(MultiProvider(providers: providers, child: app));
}

Future<void> pumpAppBuilder(
  WidgetTester tester,
  WidgetBuilder builder, {
  List<SingleChildWidget> providers = const <SingleChildWidget>[],
  ThemeData? theme,
}) async {
  await pumpApp(
    tester,
    Builder(builder: builder),
    providers: providers,
    theme: theme,
  );
}
