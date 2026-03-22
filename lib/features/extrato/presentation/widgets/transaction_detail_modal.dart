import 'package:cached_network_image/cached_network_image.dart';
import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/utils/date_formatter.dart';
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/widgets/transaction_edit_modal.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart'
    as model;
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionDetailModal extends StatefulWidget {
  const TransactionDetailModal({
    super.key,
    required this.transaction,
    this.onDownloadComprovante,
    this.onUploadReceipt,
  });

  final model.Transaction transaction;
  final VoidCallback? onDownloadComprovante;
  final Future<model.Transaction?> Function()? onUploadReceipt;

  @override
  State<TransactionDetailModal> createState() => _TransactionDetailModalState();
}

class _TransactionDetailModalState extends State<TransactionDetailModal> {
  late model.Transaction _transaction;
  bool _isUploadingReceipt = false;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  @override
  void didUpdateWidget(TransactionDetailModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transaction.id != widget.transaction.id) {
      _transaction = widget.transaction;
    }
  }

  static const String _bankName = 'CortexBank';

  bool get _isPending => _transaction.status == model.TransactionStatus.pending;
  bool get _canDownloadComprovante =>
      _transaction.status != model.TransactionStatus.pending;

  String _dateFormatted(model.Transaction t) =>
      DateFormatter.formatDate(t.date);
  String _timeFormatted(model.Transaction t) =>
      DateFormatter.formatTime(t.date);
  String _valueFormatted(model.Transaction t) {
    final cents = (t.value.abs() * 100).round();
    return formatCentsToBRL(cents);
  }

  String _tipoLabel(model.Transaction t) {
    if (t.type == model.TransactionType.ted) return 'DOC/TED';
    return t.type.label;
  }

  Future<void> _handleUploadReceipt() async {
    final onUpload = widget.onUploadReceipt;
    if (onUpload == null) return;
    setState(() => _isUploadingReceipt = true);
    try {
      final updated = await onUpload();
      if (updated != null && mounted) {
        setState(() {
          _transaction = updated;
          _isUploadingReceipt = false;
        });

        AppSnackBar.success(context, 'Recibo anexado com sucesso.');
      } else if (mounted) {
        setState(() => _isUploadingReceipt = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isUploadingReceipt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isUploadingReceipt = _isUploadingReceipt;
    final titularName = context.read<AuthProvider>().user?.username;
    final deValue = (titularName != null && titularName.isNotEmpty)
        ? titularName
        : (_transaction.from ?? '—');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.spacingLg),
      ),
      backgroundColor: AppDesignTokens.colorWhite,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDesignTokens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Detalhamento',
                    textAlign: TextAlign.left,
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Fechar',
                  style: IconButton.styleFrom(
                    foregroundColor: AppDesignTokens.colorContentDisabled,
                    padding: const EdgeInsets.all(4),
                    minimumSize: const Size(36, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDesignTokens.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dateFormatted(_transaction),
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppDesignTokens.colorContentDisabled,
                  ),
                ),
                Text(
                  _timeFormatted(_transaction),
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppDesignTokens.colorContentDisabled,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDesignTokens.spacingMd),
            _DetailRow(icon: Icons.arrow_back, label: 'De', value: deValue),
            _DetailRow(
              icon: Icons.arrow_forward,
              label: 'Para',
              value: _transaction.to ?? '—',
            ),
            const Divider(height: 1, color: Color(0xFFD9D9E0)),
            _DetailRow(icon: MdiIcons.bank, label: 'Banco', value: _bankName),
            _DetailRow(
              icon: MdiIcons.fileDocumentOutline,
              label: 'Tipo',
              value: _tipoLabel(_transaction),
            ),
            _DetailRow(
              icon: Icons.attach_money,
              label: 'Valor',
              value: _valueFormatted(_transaction),
              valueStyle: textTheme.labelLarge,
            ),
            if (_transaction.description != null &&
                _transaction.description!.isNotEmpty)
              _DetailRow(
                icon: Icons.description_outlined,
                label: 'Descrição',
                value: _transaction.description!,
              ),
            const Divider(height: 1, color: Color(0xFFD9D9E0)),
            if (_transaction.receiptUrls.isNotEmpty) ...[
              const SizedBox(height: AppDesignTokens.spacingMd),
              Text(
                'Recibos anexados',
                style: textTheme.bodySmall?.copyWith(
                  color: AppDesignTokens.colorContentDisabled,
                ),
              ),
              const SizedBox(height: AppDesignTokens.spacingXs),
              ..._transaction.receiptUrls.asMap().entries.map(
                (entry) {
                  final url = entry.value;
                  final isImage = url.contains('.jpg') ||
                      url.contains('.jpeg') ||
                      url.contains('.png');
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDesignTokens.spacingSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isImage)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDesignTokens.borderRadiusDefault,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => const SizedBox(
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (_, _, _) => const SizedBox(
                                height: 60,
                                child: Center(
                                  child: Icon(Icons.broken_image, size: 32),
                                ),
                              ),
                            ),
                          ),
                        InkWell(
                          onTap: () => launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isImage
                                    ? Icons.image_outlined
                                    : Icons.picture_as_pdf,
                                size: 18,
                                color: AppDesignTokens.colorPrimary,
                              ),
                              const SizedBox(
                                width: AppDesignTokens.spacingSm,
                              ),
                              Expanded(
                                child: Text(
                                  isImage
                                      ? 'Abrir imagem'
                                      : 'Abrir PDF',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppDesignTokens.colorPrimary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDesignTokens.spacingSm),
            ],
            const SizedBox(height: AppDesignTokens.spacingMd),
            Builder(
              builder: (context) {
                final width = MediaQuery.sizeOf(context).width;
                final isSmall =
                    width < AppDesignTokens.breakpointDetailModalActions;

                final List<Widget> buttons = [];

                if (_isPending) {
                  buttons.add(
                    TextButton(
                      onPressed: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (ctx) => TransactionEditModal(
                            data: _transaction,
                          ),
                        );
                      },
                      child: Text(
                        'Editar',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppDesignTokens.colorContentDisabled,
                        ),
                      ),
                    ),
                  );
                }

                if (_canDownloadComprovante) {
                  buttons.add(
                    TextButton(
                      onPressed:
                          widget.onDownloadComprovante ??
                          () {
                                  AppSnackBar.warning(
                              context,
                              'Comprovante disponível em breve.',
                            );
                          },
                      child: Text(
                        'Baixar comprovante',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppDesignTokens.colorPrimary,
                        ),
                      ),
                    ),
                  );
                }

                if (widget.onUploadReceipt != null) {
                  buttons.add(
                    TextButton(
                      onPressed: isUploadingReceipt
                          ? null
                          : () {
                              _handleUploadReceipt();
                            },
                      child: isUploadingReceipt
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Anexar recibo',
                              style: textTheme.labelLarge?.copyWith(
                                color: AppDesignTokens.colorPrimary,
                              ),
                            ),
                    ),
                  );
                }

                if (buttons.isEmpty) return const SizedBox.shrink();

                return Align(
                  alignment: isSmall ? Alignment.center : Alignment.centerRight,
                  child: isSmall
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: buttons,
                        )
                      : Row(mainAxisSize: MainAxisSize.min, children: buttons),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final defaultValueStyle = textTheme.bodyLarge;
    final labelStyle = textTheme.bodySmall?.copyWith(
      color: AppDesignTokens.colorContentDisabled,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDesignTokens.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppDesignTokens.colorContentDisabled),
          const SizedBox(width: AppDesignTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: AppDesignTokens.spacingXs),
                Text(
                  value,
                  style: valueStyle ?? defaultValueStyle ?? textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
