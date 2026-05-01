import 'package:cortex_bank_mobile/core/code_splitting/deferred_page_loader.dart';
import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/register_page.dart'
    deferred as register_page;

class RegisterRouteLoader extends StatelessWidget {
  const RegisterRouteLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return DeferredPageLoader(
      loadLibrary: register_page.loadLibrary,
      builder: () => register_page.RegisterPage(),
    );
  }
}
