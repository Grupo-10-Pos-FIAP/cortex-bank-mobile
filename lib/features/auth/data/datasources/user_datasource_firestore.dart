import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/user_datasource.dart';

class UserDataSourceFirestore implements UserDataSource {
  final FirebaseFirestore _firestore;

  UserDataSourceFirestore(this._firestore);

  @override
  Future<void> createUserProfile(Map<String, dynamic> userData) async {
    final uid = userData['uid'] as String?;
    if (uid == null) throw Exception('UID é obrigatório para criar perfil.');

    // Usa o UID como ID do documento para facilitar a busca posterior
    await _firestore.collection('users').doc(uid).set(userData);
  }

  @override
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw Exception('Perfil do usuário não encontrado no banco de dados.');
      }

      return doc.data() ?? {};
    } catch (e) {
      safeLogError('Erro ao buscar perfil no Firestore', e);
      rethrow;
    }
  }
}
