/// Linha persistida em [Transaction.to] para TED (mesma ou outra titularidade).
class TedRecipientLine {
  TedRecipientLine._();

  static bool looksLike(String t) {
    return t.contains('|') && (t.contains('Ag.:') || t.contains('Cc.:'));
  }

  static String format({
    required String name,
    required String branch,
    required String account,
  }) {
    final n = name.trim();
    final b = branch.trim();
    final a = account.trim();
    return '$n | Ag.: $b | Cc.: $a';
  }

  /// Retorna null se não for o formato `nome | Ag.: … | Cc.: …`.
  static ({String name, String branch, String account})? tryParse(String raw) {
    final t = raw.trim();
    if (!looksLike(t)) return null;
    final parts = t.split('|').map((p) => p.trim()).toList();
    int? agI;
    int? ccI;
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].startsWith('Ag.:')) agI ??= i;
      if (parts[i].startsWith('Cc.:')) ccI ??= i;
    }
    if (agI == null || ccI == null || agI >= ccI) return null;
    final name = parts.sublist(0, agI).join('|').trim();
    final branch = parts[agI].substring('Ag.:'.length).trim();
    final account = parts[ccI].substring('Cc.:'.length).trim();
    if (name.isEmpty || branch.isEmpty || account.isEmpty) return null;
    return (name: name, branch: branch, account: account);
  }
}
