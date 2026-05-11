import 'package:cortex_bank_mobile/navigation/app_route_generator.dart';
import 'package:cortex_bank_mobile/core/widgets/app_connectivity.dart';
import 'package:cortex_bank_mobile/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/shared/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key, this.enableConnectivityWrapper = true, this.theme});

  final bool enableConnectivityWrapper;

  /// When set (e.g. integration tests), avoids [AppTheme.lightTheme] network font fetch.
  final ThemeData? theme;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cortex Bank Mobile',
      theme: widget.theme ?? AppTheme.lightTheme,
      builder: (context, child) {
        if (!widget.enableConnectivityWrapper) {
          return child!;
        }
        return ConnectivityWrapper(child: child!);
      },
      onGenerateRoute: AppRouteGenerator.generateRoute,
      home: const SplashPage(),
    );
  }
}
