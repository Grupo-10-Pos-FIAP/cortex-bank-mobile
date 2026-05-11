import 'package:cortex_bank_mobile/core/utils/env_validator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void _loadEnv(Map<String, String> entries) {
  if (entries.isEmpty) {
    dotenv.loadFromString(envString: '', isOptional: true);
    return;
  }
  final body = entries.entries.map((e) => '${e.key}=${e.value}').join('\n');
  dotenv.loadFromString(envString: body, isOptional: true);
}

void main() {
  setUp(() {
    dotenv.clean();
  });

  group('getRequiredFirebaseEnvKeys', () {
    test(
      'deve retornar lista de chaves ou vazio conforme a plataforma atual',
      () {
        final keys = getRequiredFirebaseEnvKeys();
        expect(keys, isA<List<String>>());
        if (keys.isNotEmpty) {
          expect(keys, contains('FIREBASE_PROJECT_ID'));
        }
      },
    );
  });

  group('getMissingFirebaseEnvVars', () {
    test(
      'deve listar todas as chaves obrigatórias quando env estiver vazio',
      () {
        _loadEnv({});

        final missing = getMissingFirebaseEnvVars();
        final required = getRequiredFirebaseEnvKeys();

        expect(missing, equals(required));
      },
    );

    test(
      'deve retornar vazio quando todas as chaves obrigatórias estiverem definidas',
      () {
        final required = getRequiredFirebaseEnvKeys();
        if (required.isEmpty) return;

        _loadEnv({for (final k in required) k: 'value'});

        expect(getMissingFirebaseEnvVars(), isEmpty);
      },
    );

    test('deve tratar valor em branco como ausente', () {
      final required = getRequiredFirebaseEnvKeys();
      if (required.isEmpty) return;

      _loadEnv({
        for (final k in required) k: k == required.first ? '' : 'value',
      });

      expect(getMissingFirebaseEnvVars(), [required.first]);
    });

    test('deve tratar valor só com espaços como ausente', () {
      final required = getRequiredFirebaseEnvKeys();
      if (required.isEmpty) return;

      _loadEnv({
        for (final k in required) k: k == required.first ? '   ' : 'value',
      });

      expect(getMissingFirebaseEnvVars(), [required.first]);
    });
  });
}
