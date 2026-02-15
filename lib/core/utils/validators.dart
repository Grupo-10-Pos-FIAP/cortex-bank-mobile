/// Returns error message if value is null or empty, otherwise null.
String? requiredField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obrigatório';
  }
  return null;
}

/// Returns error message if value length is less than [minLength], otherwise null.
String? minLength(String? value, int minLength) {
  if (value == null) return 'Campo obrigatório';
  if (value.length < minLength) {
    return 'Mínimo de $minLength caracteres';
  }
  return null;
}
