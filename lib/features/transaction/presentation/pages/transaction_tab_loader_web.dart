import 'package:cortex_bank_mobile/core/code_splitting/deferred_page_loader.dart';
import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_form_page.dart'
    deferred as transaction_form_page;

class TransactionTabLoader extends StatelessWidget {
  const TransactionTabLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return DeferredPageLoader(
      loadLibrary: transaction_form_page.loadLibrary,
      builder: () => transaction_form_page.TransactionFormPage(),
    );
  }
}
