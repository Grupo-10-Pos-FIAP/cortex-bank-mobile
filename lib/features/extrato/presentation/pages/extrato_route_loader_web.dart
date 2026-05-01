import 'package:cortex_bank_mobile/core/code_splitting/deferred_page_loader.dart';
import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/pages/extrato_page.dart'
    deferred as extrato_page;

class ExtratoRouteLoader extends StatelessWidget {
  const ExtratoRouteLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return DeferredPageLoader(
      loadLibrary: extrato_page.loadLibrary,
      builder: () => extrato_page.ExtratoPage(),
    );
  }
}
