import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';
import 'package:mocktail/mocktail.dart';

void registerCommonFallbackValues() {
  registerFallbackValue(_TransactionFallback());
}

class _TransactionFallback extends Fake implements Transaction {}
