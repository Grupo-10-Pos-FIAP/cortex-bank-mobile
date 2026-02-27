import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart'
    show formatCentsToBRL, parseBRLMaskToCents, CurrencyBRLInputFormatter;
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart' as model;
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ExtratoPage extends StatefulWidget {
  const ExtratoPage({super.key});

  @override
  State<ExtratoPage> createState() => _ExtratoPageState();
}

class _ExtratoPageState extends State<ExtratoPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minValueController = TextEditingController(text: 'R\$ 0,00');
  final TextEditingController _maxValueController = TextEditingController(text: 'R\$ 0,00');

  DateTime? _dateStart;
  DateTime? _dateEnd;
  String _tipoFiltro = 'Todas';
  /// Preset: 'last7' | 'last15' | 'last30' | 'last90' | 'custom' (intervalo no calendário).
  String _periodoPreset = 'last30';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsProvider>().loadTransactions();
      context.read<TransactionsProvider>().loadBalanceSummary();
    });
    _applyPreset('last30');
  }

  void _applyPreset(String preset) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    DateTime start;
    switch (preset) {
      case 'last7':
        start = now.subtract(const Duration(days: 6));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'last15':
        start = now.subtract(const Duration(days: 14));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'last30':
        start = now.subtract(const Duration(days: 29));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'last90':
        start = now.subtract(const Duration(days: 89));
        start = DateTime(start.year, start.month, start.day);
        break;
      default:
        return;
    }
    setState(() {
      _periodoPreset = preset;
      _dateStart = start;
      _dateEnd = end;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  void _limparFiltros() {
    setState(() {
      _searchController.clear();
      _minValueController.text = 'R\$ 0,00';
      _maxValueController.text = 'R\$ 0,00';
      _tipoFiltro = 'Todas';
    });
    _applyPreset('last30');
  }

  /// Converte o texto com máscara BRL (ex.: "R\$ 12.345,67") para centavos.
  int _parseValorBRL(String text) {
    return parseBRLMaskToCents(text);
  }

  /// Filtros alinhados ao statement (front): busca por from, to, id, value; faixa por valor absoluto em reais.
  List<model.Transaction> _filtrar(List<model.Transaction> list) {
    var result = list;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((t) {
        if (t.from?.toLowerCase().contains(query) ?? false) return true;
        if (t.to?.toLowerCase().contains(query) ?? false) return true;
        if (t.id.toLowerCase().contains(query)) return true;
        if (t.value.toString().contains(query)) return true;
        return false;
      }).toList();
    }
    if (_dateStart != null) {
      final start = DateTime(_dateStart!.year, _dateStart!.month, _dateStart!.day);
      result = result.where((t) {
        final txDate = DateTime(t.date.year, t.date.month, t.date.day);
        return !txDate.isBefore(start);
      }).toList();
    }
    if (_dateEnd != null) {
      final end = DateTime(_dateEnd!.year, _dateEnd!.month, _dateEnd!.day, 23, 59, 59, 999);
      result = result.where((t) => t.date.isBefore(end) || t.date.isAtSameMomentAs(end)).toList();
    }
    if (_tipoFiltro == 'Crédito') {
      result = result.where((t) => t.type == model.TransactionType.credit).toList();
    } else if (_tipoFiltro == 'Débito') {
      result = result.where((t) => t.type == model.TransactionType.debit).toList();
    }
    final minCents = _parseValorBRL(_minValueController.text);
    final maxCents = _parseValorBRL(_maxValueController.text);
    if (minCents > 0) {
      result = result.where((t) => (t.value.abs() * 100).round() >= minCents).toList();
    }
    if (maxCents > 0) {
      result = result.where((t) => (t.value.abs() * 100).round() <= maxCents).toList();
    }
    return result;
  }

  Future<void> _pickDateRangeCalendar() async {
    final start = await showDatePicker(
      context: context,
      initialDate: _dateStart ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (start == null || !mounted) return;
    final end = await showDatePicker(
      context: context,
      initialDate: _dateEnd ?? start,
      firstDate: start,
      lastDate: DateTime.now(),
    );
    if (end != null && mounted) {
      setState(() {
        _periodoPreset = 'custom';
        _dateStart = DateTime(start.year, start.month, start.day);
        _dateEnd = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
      });
    }
  }

  void _showPeriodoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppDesignTokens.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Escolha o período',
                  style: GoogleFonts.roboto(
                    fontSize: AppDesignTokens.fontSizeSubtitle,
                    fontWeight: AppDesignTokens.fontWeightSemibold,
                    color: AppDesignTokens.colorContentDefault,
                  ),
                ),
              ),
              _periodOption('Últimos 7 dias', 'last7', Icons.today),
              _periodOption('Últimos 15 dias', 'last15', Icons.date_range),
              _periodOption('Últimos 30 dias', 'last30', Icons.calendar_month),
              _periodOption('Últimos 90 dias', 'last90', Icons.calendar_view_month),
              _periodOption('Escolher intervalo no calendário', 'custom', Icons.edit_calendar),
            ],
          ),
        ),
      ),
    );
  }

  Widget _periodOption(String label, String value, IconData icon) {
    final isSelected = _periodoPreset == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppDesignTokens.colorPrimary : AppDesignTokens.colorContentDisabled),
      title: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: AppDesignTokens.fontSizeBody,
          fontWeight: isSelected ? AppDesignTokens.fontWeightSemibold : AppDesignTokens.fontWeightRegular,
          color: AppDesignTokens.colorContentDefault,
        ),
      ),
      trailing: value == 'custom' ? const Icon(Icons.chevron_right) : (isSelected ? Icon(Icons.check, color: AppDesignTokens.colorPrimary) : null),
      onTap: () async {
        Navigator.pop(context);
        if (value == 'custom') {
          await _pickDateRangeCalendar();
        } else {
          _applyPreset(value);
        }
      },
    );
  }

  String get _periodoTexto {
    switch (_periodoPreset) {
      case 'last7':
        return 'Últimos 7 dias';
      case 'last15':
        return 'Últimos 15 dias';
      case 'last30':
        return 'Últimos 30 dias';
      case 'last90':
        return 'Últimos 90 dias';
      case 'custom':
        if (_dateStart == null || _dateEnd == null) return 'Selecionar período';
        final s = '${_dateStart!.day.toString().padLeft(2, '0')}/${_dateStart!.month.toString().padLeft(2, '0')}/${_dateStart!.year}';
        final e = '${_dateEnd!.day.toString().padLeft(2, '0')}/${_dateEnd!.month.toString().padLeft(2, '0')}/${_dateEnd!.year}';
        return '$s - $e';
      default:
        return 'Selecionar período';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignTokens.colorBgDefault,
      appBar: AppBar(
        title: Text(
          'Extrato',
          style: GoogleFonts.roboto(
            fontWeight: AppDesignTokens.fontWeightBold,
            color: AppDesignTokens.colorContentDefault,
          ),
        ),
        backgroundColor: AppDesignTokens.colorWhite,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<TransactionsProvider>(
        builder: (context, tx, _) {
          if (tx.loading && tx.transactions.isEmpty) {
            return const AppLoading();
          }
          final filtered = _filtrar(tx.transactions);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesignTokens.spacingMd,
                    vertical: AppDesignTokens.spacingSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Buscar por origem, destino, ID ou valor...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppDesignTokens.colorWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      InkWell(
                        onTap: _showPeriodoOptions,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppDesignTokens.colorWhite,
                            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
                            border: Border.all(color: AppDesignTokens.colorBorderDefault),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _periodoTexto,
                                style: GoogleFonts.roboto(
                                  fontSize: AppDesignTokens.fontSizeBody,
                                  color: AppDesignTokens.colorContentDefault,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      DropdownButtonFormField<String>(
                        value: _tipoFiltro,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Transação',
                          filled: true,
                          fillColor: AppDesignTokens.colorWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                          DropdownMenuItem(value: 'Crédito', child: Text('Crédito')),
                          DropdownMenuItem(value: 'Débito', child: Text('Débito')),
                        ],
                        onChanged: (v) => setState(() => _tipoFiltro = v ?? 'Todas'),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      TextField(
                        controller: _minValueController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Valor mínimo',
                          hintText: 'R\$ 0,00',
                          filled: true,
                          fillColor: AppDesignTokens.colorWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyBRLInputFormatter()],
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      TextField(
                        controller: _maxValueController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Valor máximo',
                          hintText: 'R\$ 0,00',
                          filled: true,
                          fillColor: AppDesignTokens.colorWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyBRLInputFormatter()],
                      ),
                      const SizedBox(height: AppDesignTokens.spacingLg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _limparFiltros,
                          icon: Icon(MdiIcons.eraser, size: 20),
                          label: const Text('Limpar Filtros'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppDesignTokens.colorPrimary,
                            foregroundColor: AppDesignTokens.colorWhite,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDesignTokens.spacingMd,
                              horizontal: AppDesignTokens.spacingLg,
                            ),
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingLg),
                    ],
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      tx.errorMessage ?? 'Nenhuma transação encontrada',
                      style: GoogleFonts.roboto(
                        fontSize: AppDesignTokens.fontSizeBody,
                        color: AppDesignTokens.colorContentDisabled,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingMd),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final t = filtered[i];
                        return _TransactionCard(
                          key: ValueKey(t.id),
                          transaction: t,
                          onDelete: () => tx.deleteTransaction(t.id),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  final model.Transaction transaction;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == model.TransactionType.credit;
    final transactionTypeLabel = isCredit ? 'Transferência recebida' : 'Transferência efetuada';
    final valueCents = (transaction.value.abs() * 100).round();
    final valorStr = isCredit
        ? '+${formatCentsToBRL(valueCents)}'
        : '-${formatCentsToBRL(valueCents)}';
    final dateStr =
        '${transaction.date.day.toString().padLeft(2, '0')}/${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}';
    final statusLabel = transaction.status == 'Pending' ? 'Pendente' : transaction.status;
    final hasFromTo = (transaction.from != null && transaction.from!.isNotEmpty) ||
        (transaction.to != null && transaction.to!.isNotEmpty);
    final fromToText = [
      if (transaction.from != null && transaction.from!.isNotEmpty) 'De ${transaction.from}',
      if (transaction.from != null && transaction.from!.isNotEmpty && transaction.to != null && transaction.to!.isNotEmpty) ' • ',
      if (transaction.to != null && transaction.to!.isNotEmpty) 'Para ${transaction.to}',
    ].join();

    return Card(
      margin: const EdgeInsets.only(bottom: AppDesignTokens.spacingSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusDefault),
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
                        ? AppDesignTokens.colorFeedbackSuccess.withOpacity(0.15)
                        : AppDesignTokens.colorFeedbackWarning.withOpacity(0.25),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppDesignTokens.colorFeedbackWarning.withOpacity(0.2),
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
                      if (transaction.status != 'Pending' && transaction.status.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
