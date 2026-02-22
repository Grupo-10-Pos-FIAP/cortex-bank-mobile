import 'package:cortex_bank_mobile/features/auth/models/user.dart';

/// Mapeia documento Firestore da coleção `users` para o modelo [User].
class UserMapper {
  UserMapper._();

  /// Converte [data] (mapa do doc Firestore) em [User].
  /// [id] é o uid do usuário; [fallbackEmail] é usado se o doc não tiver email.
  static User fromFirestore(
    Map<String, dynamic> data, {
    required String id,
    String? fallbackEmail,
  }) {
    return User(
      id: id,
      name: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? fallbackEmail ?? '',
      token: '',
    );
  }
}
