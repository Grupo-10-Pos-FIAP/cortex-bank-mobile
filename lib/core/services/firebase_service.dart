import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DatabaseService {
  Future<void> saveData(int counter);
}

class FirestoreService implements DatabaseService {
  @override
  Future<void> saveData(int counter) async {
    await FirebaseFirestore.instance.collection('test_collection').add({
      'name': 'Sample Data',
      'value': counter,
    });
  }
}
