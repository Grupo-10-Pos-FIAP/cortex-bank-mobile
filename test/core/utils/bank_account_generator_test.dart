import 'package:cortex_bank_mobile/core/utils/bank_account_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BankAccountGenerator', () {
    test('generateBranch deve retornar 0001', () {
      expect(BankAccountGenerator.generateBranch(), '0001');
    });

    test('generateAccountNumber deve seguir formato XXXXXX-X', () {
      final pattern = RegExp(r'^\d{6}-\d$');
      for (var i = 0; i < 50; i++) {
        final value = BankAccountGenerator.generateAccountNumber();
        expect(
          pattern.hasMatch(value),
          true,
          reason: 'Conta gerada "$value" deveria casar com XXXXXX-X',
        );
      }
    });

    test('generateAccountNumber deve variar entre chamadas', () {
      final values = <String>{};
      for (var i = 0; i < 20; i++) {
        values.add(BankAccountGenerator.generateAccountNumber());
      }
      expect(values.length, greaterThan(1));
    });
  });
}
