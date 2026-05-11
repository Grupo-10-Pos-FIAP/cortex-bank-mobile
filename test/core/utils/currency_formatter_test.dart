import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatCentsToBRL', () {
    test('deve formatar zero centavos', () {
      expect(formatCentsToBRL(0), r'R$ 0,00');
    });

    test('deve formatar menos de um real', () {
      expect(formatCentsToBRL(99), r'R$ 0,99');
    });

    test('deve formatar um real', () {
      expect(formatCentsToBRL(100), r'R$ 1,00');
    });

    test('deve incluir separador de milhares', () {
      expect(formatCentsToBRL(1234567), r'R$ 12.345,67');
    });

    test('deve incluir múltiplos separadores de milhares', () {
      expect(formatCentsToBRL(1234567890), r'R$ 12.345.678,90');
    });

    test('deve preservar sinal negativo', () {
      expect(formatCentsToBRL(-1234567), r'R$ -12.345,67');
    });
  });

  group('formatReaisToBRL', () {
    test('deve manter duas casas para inteiro', () {
      expect(formatReaisToBRL(1.0), r'R$ 1,00');
    });

    test('deve arredondar centavos', () {
      expect(formatReaisToBRL(12.345), r'R$ 12,35');
    });

    test('deve formatar zero', () {
      expect(formatReaisToBRL(0), r'R$ 0,00');
    });
  });

  group('parseBRLMaskToCents', () {
    test('deve retornar zero para string vazia', () {
      expect(parseBRLMaskToCents(''), 0);
    });

    test('deve retornar zero para apenas símbolo', () {
      expect(parseBRLMaskToCents(r'R$'), 0);
    });

    test('deve parsear máscara zero', () {
      expect(parseBRLMaskToCents(r'R$ 0,00'), 0);
    });

    test('deve parsear um real como 100 centavos', () {
      expect(parseBRLMaskToCents(r'R$ 1,00'), 100);
    });

    test('deve parsear valor com milhares', () {
      expect(parseBRLMaskToCents(r'R$ 12.345,67'), 1234567);
    });

    test('deve ignorar caracteres não numéricos exceto separadores', () {
      expect(parseBRLMaskToCents('abc 12.345,67 xyz'), 1234567);
    });
  });

  group('maskBRLFromDigits', () {
    test('deve retornar zero mascarado para entrada vazia', () {
      expect(maskBRLFromDigits(''), r'R$ 0,00');
    });

    test('deve posicionar único dígito nos centavos', () {
      expect(maskBRLFromDigits('5'), r'R$ 0,05');
    });

    test('deve agrupar centavos corretamente', () {
      expect(maskBRLFromDigits('12345'), r'R$ 123,45');
    });

    test('deve inserir separador de milhares', () {
      expect(maskBRLFromDigits('1234567'), r'R$ 12.345,67');
    });
  });

  group('CurrencyBRLInputFormatter', () {
    test('deve aplicar máscara em dígitos digitados', () {
      final formatter = CurrencyBRLInputFormatter();
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '12345');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, r'R$ 123,45');
      expect(result.selection.baseOffset, r'R$ 123,45'.length);
    });

    test('deve limitar quantidade máxima de dígitos', () {
      final formatter = CurrencyBRLInputFormatter(maxDigits: 4);
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '1234567');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, r'R$ 12,34');
    });

    test('deve remover não dígitos antes de mascarar', () {
      final formatter = CurrencyBRLInputFormatter();
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: r'R$ 1,99');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, r'R$ 1,99');
    });
  });
}
