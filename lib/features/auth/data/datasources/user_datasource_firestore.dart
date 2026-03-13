import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'user_datasource.dart';

class UserDataSourceFirestore implements UserDataSource {
  final FirebaseFirestore _firestore;

  UserDataSourceFirestore(this._firestore);

  DocumentReference<Map<String, dynamic>> get _userDoc {
    final user = fa.FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception(
        'Erro: Tentativa de acessar Firestore sem usuário logado.',
      );
    }
    return _firestore.collection('users').doc(user.uid);
  }

  @override
  Future<void> createUserProfile(Map<String, dynamic> userData) async {
    await _userDoc.set(userData);
  }
}


