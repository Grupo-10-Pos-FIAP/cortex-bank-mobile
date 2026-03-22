import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/utils/date_formatter.dart';
import 'package:cortex_bank_mobile/core/utils/download_comprovante.dart';
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/features/extrato/data/comprovante_content.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/widgets/transaction_detail_modal.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/attachment_constants.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart'
    as model;
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> _downloadComprovante(
  BuildContext context,
  model.Transaction transaction,
) async {
  final deValue = context.read<AuthProvider>().user?.username ??
      transaction.from ??
      '—';
  final content = ComprovanteContent.build(transaction, deValue);
  final filename = 'comprovante-${transaction.id}.txt';
  try {
    await downloadComprovante(filename, content);
    if (context.mounted) {
      Navigator.of(context).pop();
      AppSnackBar.success(context, 'Comprovante baixado com sucesso.');
    }
  } on UnsupportedError catch (_) {
    if (context.mounted) {
      Navigator.of(context).pop();
      AppSnackBar.warning(context, 'Comprovante disponível em breve.');
    }
  }
}

/// Upload de recibos desabilitado temporariamente.
Future<model.Transaction?> _uploadReceiptDisabled(BuildContext context) async {
  if (!context.mounted) return null;
  AppSnackBar.error(context, 'Upload de recibos temporariamente desabilitado.');
  return null;
}

Future<model.Transaction?> _uploadReceipt(
  BuildContext context,
  model.Transaction transaction,
) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: AttachmentConstants.allowedExtensions,
    withData: true,
  );
  if (result == null || result.files.isEmpty || !context.mounted) {
    return null;
  }
  final file = result.files.single;
  final bytes = file.bytes;
  final name = file.name;
  if (bytes == null || name.isEmpty) return null;
  final provider = context.read<TransactionsProvider>();
  return provider.uploadReceipt(transaction, bytes, name);
}

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  final model.Transaction transaction;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final isIncome = transaction.type == model.TransactionType.credit;

    String transactionTypeLabel;
    if (transaction.type == model.TransactionType.credit) {
      transactionTypeLabel = 'Transação recebida';
    } else if (transaction.type == model.TransactionType.ted) {
      transactionTypeLabel = 'TED efetuada';
    } else {
      transactionTypeLabel = 'Transação efetuada';
    }

    final valueCents = (transaction.value.abs() * 100).round();
    final valorStr = isIncome
        ? '+${formatCentsToBRL(valueCents)}'
        : '-${formatCentsToBRL(valueCents)}';

    final dateStr = DateFormatter.formatDate(transaction.date);
    final statusLabel = transaction.status == model.TransactionStatus.pending
        ? 'Pendente'
        : transaction.status;
    final titularName = context.read<AuthProvider>().user?.username;
    final deLabel = (titularName != null && titularName.isNotEmpty)
        ? titularName
        : transaction.from;
    final hasFromTo =
        (deLabel != null && deLabel.isNotEmpty) ||
        (transaction.to != null && transaction.to!.isNotEmpty);
    final fromToText = [
      if (deLabel != null && deLabel.isNotEmpty) 'De $deLabel',
      if (deLabel != null &&
          deLabel.isNotEmpty &&
          transaction.to != null &&
          transaction.to!.isNotEmpty)
        ' • ',
      if (transaction.to != null && transaction.to!.isNotEmpty)
        'Para ${transaction.to}',
    ].join();

    return Card(
      margin: const EdgeInsets.only(bottom: AppDesignTokens.spacingSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDesignTokens.borderRadiusDefault,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () async {
            await showDialog<void>(
              context: context,
              builder: (ctx) => TransactionDetailModal(
                transaction: transaction,
                onDownloadComprovante:
                    transaction.status != model.TransactionStatus.pending
                        ? () => _downloadComprovante(context, transaction)
                        : null,
                onUploadReceipt:
                    transaction.status == model.TransactionStatus.pending
                        ? () => _uploadReceiptDisabled(context)
                        : null,
              ),
            );
          },

          child: Padding(
            padding: const EdgeInsets.all(AppDesignTokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isIncome
                            ? AppDesignTokens.colorFeedbackSuccess.withValues(
                                alpha: 0.15,
                              )
                            : AppDesignTokens.colorFeedbackWarning.withValues(
                                alpha: 0.25,
                              ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome
                            ? AppDesignTokens.colorFeedbackSuccess
                            : AppDesignTokens.colorFeedbackWarning,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transactionTypeLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: AppDesignTokens.fontWeightSemibold,
                              fontSize: AppDesignTokens.fontSizeBody,
                              color: AppDesignTokens.colorContentDefault,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (transaction.status ==
                              model.TransactionStatus.pending)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppDesignTokens.colorFeedbackWarning
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusLabel,
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: AppDesignTokens.fontSizeCaption,
                                  color: AppDesignTokens.colorContentDefault,
                                ),
                              ),
                            ),
                          if (transaction.status !=
                                  model.TransactionStatus.pending &&
                              transaction.status.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppDesignTokens.colorGray200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusLabel,
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: AppDesignTokens.fontSizeCaption,
                                  color: AppDesignTokens.colorContentDefault,
                                ),
                              ),
                            ),
                          if (hasFromTo) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: AppDesignTokens.colorContentDisabled,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    fromToText,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: AppDesignTokens.fontSizeSmall,
                                      color:
                                          AppDesignTokens.colorContentDisabled,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              valorStr,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: AppDesignTokens.fontWeightBold,
                                fontSize: AppDesignTokens.fontSizeBody,
                                color: isIncome
                                    ? AppDesignTokens.colorFeedbackSuccess
                                    : AppDesignTokens.colorFeedbackError,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: AppDesignTokens.colorContentDisabled,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateStr,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: AppDesignTokens.fontSizeCaption,
                                    color: AppDesignTokens.colorContentDisabled,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
