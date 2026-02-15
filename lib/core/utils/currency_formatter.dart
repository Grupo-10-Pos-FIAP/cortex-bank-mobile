/// Formats [amountCents] as BRL currency (e.g. 12345 -> "R\$ 123,45").
String formatCentsToBRL(int amountCents) {
  final reais = amountCents ~/ 100;
  final centavos = (amountCents.abs() % 100).toString().padLeft(2, '0');
  final signal = amountCents < 0 ? '-' : '';
  return 'R\$ $signal${reais.abs()},$centavos';
}
