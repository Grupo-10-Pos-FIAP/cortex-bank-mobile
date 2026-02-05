import 'package:cortex_bank_mobile/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cortex_bank_mobile/pages/home_page.dart';

class MockDatabase implements DatabaseService {
  bool called = false;
  int lastValue = -1;

  @override
  Future<void> saveData(int counter) async {
    called = true;
    lastValue = counter;
  }
}

void main() {
  testWidgets('Verifica se o serviço de dados foi chamado', (
    WidgetTester tester,
  ) async {
    final mock = MockDatabase();

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(title: 'Teste', service: mock),
      ),
    );

    // Clica no botão e aguarda a animação
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(mock.called, isTrue);
    expect(mock.lastValue, 1);
  });
}
