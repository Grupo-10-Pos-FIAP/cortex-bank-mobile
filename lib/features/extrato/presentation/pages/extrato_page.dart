import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart'
    show parseBRLMaskToCents;
import 'package:cortex_bank_mobile/features/extrato/extrato_pagination.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/widgets/extrato_statement_filters_panel.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/widgets/transaction_card.dart';
import 'package:cortex_bank_mobile/features/extrato/statement_filter.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';

class ExtratoPage extends StatefulWidget {
  const ExtratoPage({super.key});

  @override
  State<ExtratoPage> createState() => _ExtratoPageState();
}

class _ExtratoPageState extends State<ExtratoPage> {
  TransactionsProvider? _transactionsProvider;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minValueController = TextEditingController(
    text: 'R\$ 0,00',
  );
  final TextEditingController _maxValueController = TextEditingController(
    text: 'R\$ 0,00',
  );
  final ScrollController _scrollController = ScrollController();

  DateTime? _dateStart;
  DateTime? _dateEnd;
  String _tipoFiltro = 'todas';
  String _statusFiltro = 'todas';
  String _categoriaFiltro = 'todas';

  String _periodoPreset = 'last30';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _transactionsProvider ??= context.read<TransactionsProvider>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsProvider>().loadTransactionsPaginated();
      context.read<TransactionsProvider>().loadBalanceSummary();
    });
    _applyPreset('last30');
    _scrollController.addListener(_onScroll);
  }

  void _scheduleCheckLoadMore() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkLoadMore();
    });
  }

  void _checkLoadMore() {
    final tx = context.read<TransactionsProvider>();
    final loaded = tx.transactions;
    final filtered = applyStatementFilter(loaded, _currentCriteria());

    var scrollHasClients = false;
    var hasViewportDimension = false;
    var extentAfter = 0.0;
    var maxScrollExtent = 0.0;
    if (_scrollController.hasClients) {
      scrollHasClients = true;
      final pos = _scrollController.position;
      hasViewportDimension = pos.hasViewportDimension;
      extentAfter = pos.extentAfter;
      maxScrollExtent = pos.maxScrollExtent;
    }

    final ctx = ExtratoLoadMoreContext(
      hasMore: tx.hasMore,
      isLoadingMore: tx.isLoadingMore,
      isLoading: tx.isLoading,
      loadedCount: loaded.length,
      filteredCount: filtered.length,
      scrollHasClients: scrollHasClients,
      hasViewportDimension: hasViewportDimension,
      extentAfter: extentAfter,
      maxScrollExtent: maxScrollExtent,
    );
    if (shouldRequestLoadMore(ctx)) {
      tx.loadMoreTransactions();
    }
  }

  void _onScroll() {
    _checkLoadMore();
  }

  StatementFilterCriteria _currentCriteria() {
    return StatementFilterCriteria(
      searchQuery: _searchController.text,
      dateStart: _dateStart,
      dateEnd: _dateEnd,
      tipoFiltro: _tipoFiltro,
      statusFiltro: _statusFiltro,
      categoriaFiltro: _categoriaFiltro,
      minCents: parseBRLMaskToCents(_minValueController.text),
      maxCents: parseBRLMaskToCents(_maxValueController.text),
    );
  }

  void _applyPreset(String preset) {
    final now = DateTime.now();
    // Inclui o fim da janela de agendamento (hoje+N dias), senão transações
    // futuras somem do extrato por causa do filtro de data.
    final maxDay = TransactionDatePolicy.maxSelectableDate;
    final end = DateTime(
      maxDay.year,
      maxDay.month,
      maxDay.day,
      23,
      59,
      59,
      999,
    );
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    final provider = _transactionsProvider;
    if (provider != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.loadTransactions();
      });
    }
    super.dispose();
  }

  void _limparFiltros() {
    setState(() {
      _searchController.clear();
      _minValueController.text = 'R\$ 0,00';
      _maxValueController.text = 'R\$ 0,00';
      _tipoFiltro = 'todas';
      _statusFiltro = 'todas';
      _categoriaFiltro = 'todas';
    });
    _applyPreset('last30');
  }

  Future<void> _pickDateRangeCalendar() async {
    final lastSelectable = TransactionDatePolicy.maxSelectableDate;
    final start = await showDatePicker(
      context: context,
      initialDate: _dateStart ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: lastSelectable,
    );
    if (start == null || !mounted) return;
    final end = await showDatePicker(
      context: context,
      initialDate: _dateEnd ?? start,
      firstDate: start,
      lastDate: lastSelectable,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
              _periodOption(
                'Últimos 90 dias',
                'last90',
                Icons.calendar_view_month,
              ),
              _periodOption(
                'Escolher intervalo no calendário',
                'custom',
                Icons.edit_calendar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _periodOption(String label, String value, IconData icon) {
    final isSelected = _periodoPreset == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? AppDesignTokens.colorPrimary
            : AppDesignTokens.colorContentDisabled,
      ),
      title: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: AppDesignTokens.fontSizeBody,
          fontWeight: isSelected
              ? AppDesignTokens.fontWeightSemibold
              : AppDesignTokens.fontWeightRegular,
          color: AppDesignTokens.colorContentDefault,
        ),
      ),
      trailing: value == 'custom'
          ? const Icon(Icons.chevron_right)
          : (isSelected
                ? Icon(Icons.check, color: AppDesignTokens.colorPrimary)
                : null),
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
        final s =
            '${_dateStart!.day.toString().padLeft(2, '0')}/${_dateStart!.month.toString().padLeft(2, '0')}/${_dateStart!.year}';
        final e =
            '${_dateEnd!.day.toString().padLeft(2, '0')}/${_dateEnd!.month.toString().padLeft(2, '0')}/${_dateEnd!.year}';
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
          if (tx.isLoading && tx.transactions.isEmpty) {
            return const AppLoading();
          }
          final filtered =
              applyStatementFilter(tx.transactions, _currentCriteria());
          _scheduleCheckLoadMore();
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification n) {
              if (n is ScrollUpdateNotification ||
                  n is ScrollEndNotification ||
                  n is OverscrollNotification) {
                _checkLoadMore();
              }
              return false;
            },
            child: NotificationListener<ScrollMetricsNotification>(
              onNotification: (_) {
                _scheduleCheckLoadMore();
                return false;
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: ExtratoStatementFiltersPanel(
                      searchController: _searchController,
                      onSearchChanged: (_) => setState(() {}),
                      periodoTexto: _periodoTexto,
                      onPeriodTap: _showPeriodoOptions,
                      tipoFiltro: _tipoFiltro,
                      onTipoChanged: (v) =>
                          setState(() => _tipoFiltro = v ?? 'todas'),
                      statusFiltro: _statusFiltro,
                      onStatusChanged: (v) =>
                          setState(() => _statusFiltro = v ?? 'todas'),
                      categoriaFiltro: _categoriaFiltro,
                      onCategoriaChanged: (v) =>
                          setState(() => _categoriaFiltro = v ?? 'todas'),
                      minValueController: _minValueController,
                      maxValueController: _maxValueController,
                      onMinMaxChanged: () => setState(() {}),
                      onClearFilters: _limparFiltros,
                    ),
                  ),
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: tx.isLoadingMore && tx.transactions.isNotEmpty
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : Text(
                                tx.errorMessage ??
                                    'Nenhuma transação encontrada',
                                style: GoogleFonts.roboto(
                                  fontSize: AppDesignTokens.fontSizeBody,
                                  color: AppDesignTokens.colorContentDisabled,
                                ),
                              ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacingMd,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final t = filtered[i];
                          return TransactionCard(
                            key: ValueKey(t.id),
                            transaction: t,
                            onDelete: () => tx.deleteTransaction(t.id),
                          );
                        }, childCount: filtered.length),
                      ),
                    ),
                    if (tx.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    if (!tx.hasMore && filtered.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Todas as transações carregadas',
                              style: GoogleFonts.roboto(
                                fontSize: AppDesignTokens.fontSizeSmall,
                                color: AppDesignTokens.colorContentDisabled,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
