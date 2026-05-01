import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';
import 'package:flutter/material.dart';

class DeferredPageLoader extends StatefulWidget {
  const DeferredPageLoader({
    super.key,
    required this.loadLibrary,
    required this.builder,
  });

  final Future<void> Function() loadLibrary;
  final Widget Function() builder;

  @override
  State<DeferredPageLoader> createState() => _DeferredPageLoaderState();
}

class _DeferredPageLoaderState extends State<DeferredPageLoader> {
  late final Future<void> _loader = widget.loadLibrary();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loader,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erro ao carregar página: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: AppLoading());
        }

        return widget.builder();
      },
    );
  }
}
