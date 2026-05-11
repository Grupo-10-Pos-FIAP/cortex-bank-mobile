import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/features/auth/domain/entities/user.dart';
import 'package:cortex_bank_mobile/features/contacts/domain/entities/contact.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';

/// Snapshot of mutable form state for validation (no [BuildContext]).
class TransactionFormValidationInput {
  const TransactionFormValidationInput({
    required this.selectedValueType,
    required this.selectedValueCategory,
    required this.selectedTitularidade,
    required this.selectedContact,
    required this.valueBrlText,
    required this.otherTitularName,
    required this.otherTitularBranch,
    required this.otherTitularAccount,
    required this.profileUser,
    required this.selectedDate,
  });

  final String? selectedValueType;
  final String? selectedValueCategory;
  final int? selectedTitularidade;
  final Contact? selectedContact;
  final String valueBrlText;
  final String otherTitularName;
  final String otherTitularBranch;
  final String otherTitularAccount;
  final User? profileUser;
  final DateTime selectedDate;
}

String? transactionFormFirstValidationError(
  TransactionFormValidationInput input,
) {
  if (input.selectedValueType == null) {
    return 'Tipo de transação é obrigatório.';
  }

  final selectedContact = input.selectedContact;
  if (selectedContact == null && input.selectedTitularidade == null) {
    return 'Informe a titularidade (mesma ou outra) ou selecione um contato.';
  }

  if (selectedContact == null) {
    if (input.selectedTitularidade == 0) {
      final u = input.profileUser;
      final name = u?.username.trim() ?? '';
      final branch = u?.branchCode.trim() ?? '';
      final account = u?.accountNumber.trim() ?? '';
      if (name.isEmpty) {
        return 'Nome no perfil é obrigatório para mesma titularidade.';
      }
      if (branch.isEmpty) {
        return 'Agência no perfil é obrigatória para mesma titularidade.';
      }
      if (account.isEmpty) {
        return 'Conta no perfil é obrigatória para mesma titularidade.';
      }
    } else if (input.selectedTitularidade == 1) {
      if (input.otherTitularName.trim().isEmpty) {
        return 'Informe o nome do favorecido (outra titularidade).';
      }
      if (input.otherTitularBranch.trim().isEmpty) {
        return 'Informe a agência do favorecido (outra titularidade).';
      }
      if (input.otherTitularAccount.trim().isEmpty) {
        return 'Informe a conta do favorecido (outra titularidade).';
      }
    }
  }

  final valueMsg = validateMinTransferValueBRL(input.valueBrlText);
  if (valueMsg != null) {
    return 'Valor: $valueMsg';
  }

  if (input.selectedValueCategory == null) {
    return 'Categoria é obrigatória.';
  }

  if (!TransactionDatePolicy.isAllowed(input.selectedDate)) {
    return TransactionDatePolicy.validationMessage;
  }

  return null;
}
