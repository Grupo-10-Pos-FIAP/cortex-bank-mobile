import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('requiredField', () {
    test('deve exigir campo quando valor for null', () {
      expect(requiredField(null), 'Campo obrigatório');
    });

    test('deve exigir campo quando string for vazia', () {
      expect(requiredField(''), 'Campo obrigatório');
    });

    test('deve exigir campo quando string for só espaços', () {
      expect(requiredField('   '), 'Campo obrigatório');
    });

    test('deve aceitar texto não vazio', () {
      expect(requiredField('abc'), isNull);
    });
  });

  group('minLength', () {
    test('deve exigir campo quando valor for null', () {
      expect(minLength(null, 3), 'Campo obrigatório');
    });

    test('deve exigir mínimo quando texto for mais curto', () {
      expect(minLength('ab', 3), 'Mínimo de 3 caracteres');
    });

    test('deve aceitar texto com tamanho exato do mínimo', () {
      expect(minLength('abc', 3), isNull);
    });

    test('deve aceitar texto acima do mínimo', () {
      expect(minLength('abcd', 3), isNull);
    });
  });

  group('validateEmail', () {
    test('deve exigir email quando for null', () {
      expect(validateEmail(null), 'Email é obrigatório');
    });

    test('deve exigir email quando for só espaços', () {
      expect(validateEmail('   '), 'Email é obrigatório');
    });

    test('deve rejeitar email sem @', () {
      expect(validateEmail('abc.com'), 'Digite um email válido');
    });

    test('deve rejeitar email com múltiplos @', () {
      expect(validateEmail('a@b@c.com'), 'Digite um email válido');
    });

    test('deve rejeitar email sem TLD adequado', () {
      expect(validateEmail('abc@def'), 'Digite um email válido');
    });

    test('deve rejeitar TLD muito curto', () {
      expect(validateEmail('abc@def.c'), 'Digite um email válido');
    });

    test('deve aceitar email simples válido', () {
      expect(validateEmail('test@example.com'), isNull);
    });

    test('deve aceitar email com ponto e mais na parte local', () {
      expect(validateEmail('user.name+tag@sub.example.com'), isNull);
    });

    test('deve rejeitar quando não houver texto antes do @', () {
      expect(validateEmail('@example.com'), 'Digite um email válido');
    });

    test('deve rejeitar quando não houver domínio após o @', () {
      expect(validateEmail('user@'), 'Digite um email válido');
    });
  });

  group('validateFullName', () {
    test('deve exigir nome quando for null', () {
      expect(validateFullName(null), 'Campo obrigatório');
    });

    test('deve exigir nome quando string for vazia', () {
      expect(validateFullName(''), 'Campo obrigatório');
    });

    test('deve exigir pelo menos duas palavras', () {
      expect(
        validateFullName('Gabrielle'),
        'Digite seu nome completo (mínimo 2 palavras)',
      );
    });

    test('deve aceitar duas palavras', () {
      expect(validateFullName('Gabrielle Martins'), isNull);
    });

    test('deve tratar múltiplos espaços como separador de palavras', () {
      expect(validateFullName('  Gabrielle    Martins  '), isNull);
    });
  });

  group('validatePassword', () {
    test('deve exigir senha quando for null', () {
      expect(validatePassword(null), 'Campo obrigatório');
    });

    test('deve exigir senha quando string for vazia', () {
      expect(validatePassword(''), 'Campo obrigatório');
    });

    test('deve exigir mínimo de 8 caracteres', () {
      expect(validatePassword('1234567'), 'Mínimo de 8 caracteres');
    });

    test('deve aceitar senha com 8 caracteres', () {
      expect(validatePassword('12345678'), isNull);
    });
  });

  group('confirmPassword', () {
    test('deve exigir confirmação quando for null', () {
      expect(confirmPassword(null, '12345678'), 'Campo obrigatório');
    });

    test('deve exigir confirmação quando string for vazia', () {
      expect(confirmPassword('', '12345678'), 'Campo obrigatório');
    });

    test('deve rejeitar quando confirmação não coincidir', () {
      expect(confirmPassword('abc', '12345678'), 'As senhas não coincidem');
    });

    test('deve aceitar quando confirmação coincidir', () {
      expect(confirmPassword('12345678', '12345678'), isNull);
    });
  });

  group('validateMinTransferValueBRL', () {
    test('deve exigir valor quando for null', () {
      expect(validateMinTransferValueBRL(null), 'Campo obrigatório');
    });

    test('deve exigir valor quando string for vazia', () {
      expect(validateMinTransferValueBRL(''), 'Campo obrigatório');
    });

    test('deve rejeitar valor zero', () {
      expect(
        validateMinTransferValueBRL(r'R$ 0,00'),
        r'O valor mínimo é R$ 1,00',
      );
    });

    test('deve rejeitar valor abaixo de um real', () {
      expect(
        validateMinTransferValueBRL(r'R$ 0,99'),
        r'O valor mínimo é R$ 1,00',
      );
    });

    test('deve aceitar exatamente um real', () {
      expect(validateMinTransferValueBRL(r'R$ 1,00'), isNull);
    });

    test('deve aceitar valor acima de um real', () {
      expect(validateMinTransferValueBRL(r'R$ 1.234,56'), isNull);
    });
  });
}
