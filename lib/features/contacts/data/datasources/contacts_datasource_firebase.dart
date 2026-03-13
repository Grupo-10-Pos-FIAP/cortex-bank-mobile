import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'contacts_datasource.dart';
import '../../models/contact.dart';

class ContactsDataSourceFirestore implements ContactsDataSource {
  final FirebaseFirestore _firestore;
  ContactsDataSourceFirestore(this._firestore);

  CollectionReference<Map<String, dynamic>> get _contactsCol {
    final user = fa.FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    return _firestore.collection('users').doc(user.uid).collection('contacts');
  }

  @override
  Future<List<Contact>> getAll() async {
    final snapshot = await _contactsCol.get();
    return snapshot.docs
        .map((d) => Contact.fromFirestore(d.data(), d.id))
        .toList();
  }

  @override
  Future<String> add(String name) async {
    final docRef = await _contactsCol.add({
      'name': name,
      'isFavorite': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  @override
  Future<void> updateFavorite(String id, bool isFavorite) async {
    await _contactsCol.doc(id).update({'isFavorite': isFavorite});
  }

  @override
  Future<void> delete(String id) async {
    await _contactsCol.doc(id).delete();
  }
}
