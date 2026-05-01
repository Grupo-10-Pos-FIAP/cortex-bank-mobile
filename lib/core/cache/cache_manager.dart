/// Cache em memória com suporte a TTL (Time To Live).
/// Armazena dados temporários para evitar requisições repetidas ao Firebase.
class CacheManager {
  CacheManager._();

  static final Map<String, _CacheEntry> _cache = {};

  /// Inicializa o gerenciador de cache.
  static Future<void> initialize() async {
    _cache.clear();
  }

  /// Armazena [value] com a [key] informada.
  /// Opcional: define [ttl] para expirar automaticamente.
  static void set(String key, dynamic value, {Duration? ttl}) {
    final expiry = ttl != null ? DateTime.now().add(ttl) : null;
    _cache[key] = _CacheEntry(value: value, expiry: expiry);
  }

  /// Recupera o valor associado a [key], ou `null` se inexistente/expirado.
  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T?;
  }

  /// Retorna `true` se a chave existe e não expirou.
  static bool isFresh(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    return !entry.isExpired;
  }

  /// Remove uma entrada específica.
  static void remove(String key) => _cache.remove(key);

  /// Limpa todo o cache.
  static void clear() => _cache.clear();

  /// Número de entradas ativas no cache.
  static int get size => _cache.length;
}

class _CacheEntry {
  final dynamic value;
  final DateTime? expiry;

  const _CacheEntry({required this.value, this.expiry});

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}
