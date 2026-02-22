import 'package:cortex_bank_mobile/core/services/firebase_service.dart';

class MockDatabase implements DatabaseService {
  bool called = false;
  int lastValue = -1;

  @override
  Future<void> saveData(int counter) async {
    called = true;
    lastValue = counter;
  }
}
