import 'package:cortex_bank_mobile/features/contacts/domain/entities/contact.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/utils/transaction_form_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/factories/user_factory.dart';

void main() {
  group('transactionFormFirstValidationError', () {
    test('retorna erro quando tipo de transação é null', () {
      final msg = transactionFormFirstValidationError(
        TransactionFormValidationInput(
          selectedValueType: null,
          selectedValueCategory: 'x',
          selectedTitularidade: 0,
          selectedContact: null,
          valueBrlText: 'R\$ 10,00',
          otherTitularName: '',
          otherTitularBranch: '',
          otherTitularAccount: '',
          profileUser: buildUser(),
          selectedDate: TransactionDatePolicy.today,
        ),
      );
      expect(msg, 'Tipo de transação é obrigatório.');
    });

    test(
      'retorna null para rascunho mínimo válido (mesma titularidade + perfil)',
      () {
        final msg = transactionFormFirstValidationError(
          TransactionFormValidationInput(
            selectedValueType: 'credito',
            selectedValueCategory: 'alimentacao',
            selectedTitularidade: 0,
            selectedContact: null,
            valueBrlText: 'R\$ 10,00',
            otherTitularName: '',
            otherTitularBranch: '',
            otherTitularAccount: '',
            profileUser: buildUser(),
            selectedDate: TransactionDatePolicy.today,
          ),
        );
        expect(msg, isNull);
      },
    );

    test('retorna erro quando falta titularidade e contato', () {
      final msg = transactionFormFirstValidationError(
        TransactionFormValidationInput(
          selectedValueType: 'credito',
          selectedValueCategory: 'alimentacao',
          selectedTitularidade: null,
          selectedContact: null,
          valueBrlText: 'R\$ 10,00',
          otherTitularName: '',
          otherTitularBranch: '',
          otherTitularAccount: '',
          profileUser: buildUser(),
          selectedDate: TransactionDatePolicy.today,
        ),
      );
      expect(
        msg,
        'Informe a titularidade (mesma ou outra) ou selecione um contato.',
      );
    });

    test('com contato selecionado não exige titularidade', () {
      final msg = transactionFormFirstValidationError(
        TransactionFormValidationInput(
          selectedValueType: 'credito',
          selectedValueCategory: 'alimentacao',
          selectedTitularidade: null,
          selectedContact: Contact(id: 'c1', name: 'Fulano'),
          valueBrlText: 'R\$ 10,00',
          otherTitularName: '',
          otherTitularBranch: '',
          otherTitularAccount: '',
          profileUser: buildUser(),
          selectedDate: TransactionDatePolicy.today,
        ),
      );
      expect(msg, isNull);
    });
  });
}
