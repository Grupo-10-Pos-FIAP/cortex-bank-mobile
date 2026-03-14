import 'dart:math';

class BankAccountGenerator {
  static String generateBranch() => '0001'; /* Padrão de bancos digitais */

  static String generateAccountNumber() {
    final random = Random();
    final number = random.nextInt(900000) + 100000; /* 6 dígitos */
    final digit = random.nextInt(10); /* Dígito verificador */
    return '$number-$digit';
  }
}
