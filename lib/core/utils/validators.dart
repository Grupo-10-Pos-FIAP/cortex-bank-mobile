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

/// Returns error message if email is invalid, otherwise null.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obrigatório';
  }
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Digite um email válido';
  }
  return null;
}

/// Returns error message if full name doesn't have at least 2 words, otherwise null.
String? validateFullName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obrigatório';
  }
  final words = value.trim().split(RegExp(r'\s+'));
  if (words.length < 2) {
    return 'Digite seu nome completo (mínimo 2 palavras)';
  }
  return null;
}

/// Returns error message if password confirmation doesn't match password, otherwise null.
String? confirmPassword(String? value, String? password) {
  if (value == null || value.isEmpty) {
    return 'Campo obrigatório';
  }
  if (value != password) {
    return 'As senhas não coincidem';
  }
  return null;
}
