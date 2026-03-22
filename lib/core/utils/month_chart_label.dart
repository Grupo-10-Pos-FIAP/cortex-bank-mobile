String prevMonthKey(String yyyyMm) {
  final parts = yyyyMm.split('-');
  if (parts.length != 2) return yyyyMm;
  var y = int.tryParse(parts[0]);
  var m = int.tryParse(parts[1]);
  if (y == null || m == null || m < 1 || m > 12) return yyyyMm;
  if (m > 1) {
    m--;
  } else {
    m = 12;
    y--;
  }
  return '$y-${m.toString().padLeft(2, '0')}';
}

String monthKeyToShortLabel(String yyyyMm) {
  final parts = yyyyMm.split('-');
  if (parts.length != 2) return yyyyMm;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (y == null || m == null || m < 1 || m > 12) return yyyyMm;
  const names = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];
  return '${names[m - 1]}/${(y % 100).toString().padLeft(2, '0')}';
}
