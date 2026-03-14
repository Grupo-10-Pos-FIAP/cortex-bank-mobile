import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart' as model;
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final isCredit = transaction.type == model.TransactionType.credit;
    final transactionTypeLabel = isCredit
        ? 'Transferência recebida'
        : 'Transferência efetuada';
    final valueCents = (transaction.value.abs() * 100).round();
    final valorStr = isCredit
        ? '+${formatCentsToBRL(valueCents)}'
        : '-${formatCentsToBRL(valueCents)}';
    final dateStr =
        '${transaction.date.day.toString().padLeft(2, '0')}/${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}';
    final statusLabel = transaction.status == 'Pending'
        ? 'Pendente'
        : transaction.status;
    final hasFromTo =
        (transaction.from != null && transaction.from!.isNotEmpty) ||
        (transaction.to != null && transaction.to!.isNotEmpty);
    final fromToText = [
      if (transaction.from != null && transaction.from!.isNotEmpty)
        'De ${transaction.from}',
      if (transaction.from != null &&
          transaction.from!.isNotEmpty &&
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
                    color: isCredit
                        ? AppDesignTokens.colorFeedbackSuccess.withValues(
                            alpha: 0.15,
                          )
                        : AppDesignTokens.colorFeedbackWarning.withValues(
                            alpha: 0.25,
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isCredit
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
                        style: GoogleFonts.roboto(
                          fontWeight: AppDesignTokens.fontWeightSemibold,
                          fontSize: AppDesignTokens.fontSizeBody,
                          color: AppDesignTokens.colorContentDefault,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (transaction.status == 'Pending')
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
                            style: GoogleFonts.roboto(
                              fontSize: AppDesignTokens.fontSizeCaption,
                              color: AppDesignTokens.colorContentDefault,
                            ),
                          ),
                        ),
                      if (transaction.status != 'Pending' &&
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
                            style: GoogleFonts.roboto(
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
                                style: GoogleFonts.roboto(
                                  fontSize: AppDesignTokens.fontSizeSmall,
                                  color: AppDesignTokens.colorContentDisabled,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      valorStr,
                      style: GoogleFonts.roboto(
                        fontWeight: AppDesignTokens.fontWeightBold,
                        fontSize: AppDesignTokens.fontSizeBody,
                        color: isCredit
                            ? AppDesignTokens.colorFeedbackSuccess
                            : AppDesignTokens.colorFeedbackError,
                      ),
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
                          style: GoogleFonts.roboto(
                            fontSize: AppDesignTokens.fontSizeCaption,
                            color: AppDesignTokens.colorContentDisabled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
