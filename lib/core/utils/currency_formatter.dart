import 'package:flutter/services.dart';

/// Formats [amountCents] as BRL currency (e.g. 12345 -> "R\$ 123,45").
String formatCentsToBRL(int amountCents) {
  final reais = amountCents ~/ 100;
  final centavos = (amountCents.abs() % 100).toString().padLeft(2, '0');
  final signal = amountCents < 0 ? '-' : '';
  return 'R\$ $signal${reais.abs()},$centavos';
}

/// Formata centavos em BRL com separador de milhares (ex.: 1234567 -> "R\$ 12.345,67").
String formatCentsToBRLWithThousands(int amountCents) {
  final abs = amountCents.abs();
  final reais = abs ~/ 100;
  final centavos = (abs % 100).toString().padLeft(2, '0');
  final reaisStr = reais.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  final signal = amountCents < 0 ? '-' : '';
  return 'R\$ $signal$reaisStr,$centavos';
}

/// Extrai apenas dígitos de [maskedBRL] (ex.: "R\$ 12.345,67" -> 1234567) e retorna o valor em centavos.
int parseBRLMaskToCents(String maskedBRL) {
  final digits = maskedBRL.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.isEmpty) return 0;
  return int.tryParse(digits) ?? 0;
}

/// Aplica máscara de moeda BRL a uma string contendo apenas dígitos (valor em centavos).
/// Ex.: "12345" -> "R\$ 123,45"; "1234567" -> "R\$ 12.345,67".
String maskBRLFromDigits(String digitsOnly) {
  if (digitsOnly.isEmpty) return 'R\$ 0,00';
  final cents = int.tryParse(digitsOnly) ?? 0;
  return formatCentsToBRLWithThousands(cents);
}

/// [TextInputFormatter] que aplica máscara de moeda brasileira (R\$ 0,00) enquanto o usuário digita.
class CurrencyBRLInputFormatter extends TextInputFormatter {
  /// Máximo de dígitos (ex.: 11 = até 99.999.999,99).
  final int maxDigits;

  CurrencyBRLInputFormatter({this.maxDigits = 11});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final limited = digits.length > maxDigits ? digits.substring(0, maxDigits) : digits;
    final masked = maskBRLFromDigits(limited);
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}
