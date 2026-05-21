import 'dart:async';

import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart'
    show parseBRLMaskToCents;
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/features/extrato/constants/statement_period_policy.dart';
import 'package:cortex_bank_mobile/features/extrato/extrato_pagination.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/widgets/extrato_statement_filters_panel.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/widgets/transaction_card.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/statement/statement_filter_criteria.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/providers/transactions_notifier.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/state/transactions_state.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';

class ExtratoPage extends StatefulWidget {
  const ExtratoPage({super.key});

  @override
  State<ExtratoPage> createState() => _ExtratoPageState();
}

class _ExtratoPageState extends State<ExtratoPage> {
  static const _searchDebounceDuration = Duration(milliseconds: 320);

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minValueController = TextEditingController(
    text: 'R\$ 0,00',
  );
  final TextEditingController _maxValueController = TextEditingController(
    text: 'R\$ 0,00',
  );
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<String> _debouncedSearchQuery = ValueNotifier<String>('');

  Timer? _searchDebounceTimer;

  DateTime? _dateStart;
  DateTime? _dateEnd;
  String _tipoFiltro = 'todas';
  String _statusFiltro = 'todas';
  String _categoriaFiltro = 'todas';

  String _periodoPreset = 'last30';

  @override
  void initState() {
    super.initState();
    _debouncedSearchQuery.value = _searchController.text;
    _applyPreset('last30');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TransactionsNotifier>().loadBalanceSummary();
    });
  }

  void _scheduleCheckLoadMore() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkLoadMore();
    });
  }

  void _onSearchTextChanged(String _) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounceDuration, () {
      if (!mounted) return;
      final next = _searchController.text;
      if (_debouncedSearchQuery.value != next) {
        _debouncedSearchQuery.value = next;
      }
      _scheduleCheckLoadMore();
    });
  }

  void _checkLoadMore() {
    final tx = context.read<TransactionsNotifier>();
    final loaded = tx.transactions;
    // Filtra apenas por searchQuery (client-side); outros filtros já estão server-side
    // Aplicar filtros client-side (search + filtros não suportados server-side)
    final filtered = applyStatementFilter(loaded, _uiSearchOnlyCriteria());

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

  /// Lista vazia na UI: distingue falha de carga, lista vazia real e filtro sem match.
  String _extratoEmptyMessage(TransactionsNotifier tx) {
    if (tx.transactions.isEmpty) {
      return tx.transactionsError ?? 'Nenhuma transação encontrada';
    }
    return 'Nenhum resultado para os filtros selecionados.';
  }

  /// Critérios aplicados server-side (data + um filtro prioritário).
  StatementFilterCriteria _serverSideFilterCriteria() {
    return StatementFilterCriteria(
      searchQuery: '',
      dateStart: _dateStart,
      dateEnd: _dateEnd,
      tipoFiltro: _tipoFiltro,
      statusFiltro: _statusFiltro,
      categoriaFiltro: _categoriaFiltro,
      minCents: parseBRLMaskToCents(_minValueController.text),
      maxCents: parseBRLMaskToCents(_maxValueController.text),
    );
  }

  /// Busca textual na UI; data/tipo/status/categoria/valor vêm do Firestore.
  StatementFilterCriteria _uiSearchOnlyCriteria() {
    return StatementFilterCriteria(
      searchQuery: _debouncedSearchQuery.value,
      dateStart: null,
      dateEnd: null,
      tipoFiltro: 'todas',
      statusFiltro: 'todas',
      categoriaFiltro: 'todas',
      minCents: 0,
      maxCents: 0,
    );
  }

  /// Carrega transações com os filtros server-side atuais.
  Future<void> _loadWithServerSideFilters() async {
    await context.read<TransactionsNotifier>().loadTransactionsPaginated(
      criteria: _serverSideFilterCriteria(),
    );
  }

  /// Evita [notifyListeners] durante o mount (ex.: [initState] → [_applyPreset]).
  void _scheduleLoadWithServerSideFilters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadWithServerSideFilters();
    });
  }

  void _applyPreset(String preset) {
    final end = StatementPeriodPolicy.lastSelectableEnd;
    DateTime start;
    switch (preset) {
      case 'last7':
        start = StatementPeriodPolicy.today.subtract(const Duration(days: 6));
        break;
      case 'last15':
        start = StatementPeriodPolicy.today.subtract(const Duration(days: 14));
        break;
      case 'last30':
        start = StatementPeriodPolicy.today.subtract(const Duration(days: 29));
        break;
      case 'last90':
        start = StatementPeriodPolicy.earliestSelectableStart;
        break;
      default:
        return;
    }
    start = StatementPeriodPolicy.clampStartDay(start);
    setState(() {
      _periodoPreset = preset;
      _dateStart = DateTime(start.year, start.month, start.day);
      _dateEnd = end;
    });
    _scheduleLoadWithServerSideFilters();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _debouncedSearchQuery.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  void _limparFiltros() {
    _searchDebounceTimer?.cancel();
    _debouncedSearchQuery.value = '';
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
    final earliest = StatementPeriodPolicy.earliestSelectableStart;
    final today = StatementPeriodPolicy.today;

    final startPicked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: earliest,
      lastDate: today,
      helpText:
          'Data inicial (máx. ${StatementPeriodPolicy.maxInclusiveDays} dias até hoje)',
    );
    if (startPicked == null || !mounted) return;

    final startDay = StatementPeriodPolicy.clampStartDay(startPicked);
    final maxEndDay = StatementPeriodPolicy.maxEndDayForStart(startDay);
    final maxEndDateOnly = DateTime(
      maxEndDay.year,
      maxEndDay.month,
      maxEndDay.day,
    );

    var endInitial = StatementPeriodPolicy.clampEndDay(today);
    final endInitialDay = StatementPeriodPolicy.dateOnly(endInitial);
    if (endInitialDay.isBefore(StatementPeriodPolicy.dateOnly(startDay))) {
      endInitial = startDay;
    } else if (endInitialDay.isAfter(
      StatementPeriodPolicy.dateOnly(maxEndDateOnly),
    )) {
      endInitial = maxEndDateOnly;
    }

    final endPicked = await showDatePicker(
      context: context,
      initialDate: endInitial,
      firstDate: startDay,
      lastDate: maxEndDateOnly,
      helpText:
          'Data final (entre início e hoje, máx. ${StatementPeriodPolicy.maxInclusiveDays} dias)',
    );
    if (endPicked == null || !mounted) return;

    final rangeStart = DateTime(startDay.year, startDay.month, startDay.day);
    final endDay = StatementPeriodPolicy.clampEndDay(endPicked);
    final rangeEnd = StatementPeriodPolicy.endOfDay(endDay);

    if (!StatementPeriodPolicy.isValidRange(rangeStart, rangeEnd)) {
      AppSnackBar.error(
        context,
        StatementPeriodPolicy.rangeValidationMessage,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    setState(() {
      _periodoPreset = 'custom';
      _dateStart = rangeStart;
      _dateEnd = rangeEnd;
    });
    _loadWithServerSideFilters();
  }

  void _showPeriodoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppDesignTokens.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
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
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontSize: AppDesignTokens.fontSizeSubtitle,
                    fontWeight: AppDesignTokens.fontWeightSemibold,
                    color: AppDesignTokens.colorContentDefault,
                  ),
                ),
              ),
              _periodOption(
                sheetContext,
                'Últimos 7 dias',
                'last7',
                Icons.today,
              ),
              _periodOption(
                sheetContext,
                'Últimos 15 dias',
                'last15',
                Icons.date_range,
              ),
              _periodOption(
                sheetContext,
                'Últimos 30 dias',
                'last30',
                Icons.calendar_month,
              ),
              _periodOption(
                sheetContext,
                'Últimos 90 dias',
                'last90',
                Icons.calendar_view_month,
              ),
              _periodOption(
                sheetContext,
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

  Widget _periodOption(
    BuildContext modalContext,
    String label,
    String value,
    IconData icon,
  ) {
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
        style: Theme.of(modalContext).textTheme.bodyMedium?.copyWith(
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
        Navigator.pop(modalContext);
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: AppDesignTokens.fontWeightBold,
            color: AppDesignTokens.colorContentDefault,
          ),
        ),
        backgroundColor: AppDesignTokens.colorWhite,
        elevation: 0,
        centerTitle: false,
      ),
      body:
          Selector<
            TransactionsState,
            (int, bool, bool, bool, String?, TransactionsListPhase)
          >(
            selector: (_, s) {
              final idsVersion = Object.hashAll(
                s.transactions.map(
                  (e) => Object.hash(
                    e.id,
                    e.value,
                    e.date.millisecondsSinceEpoch,
                    e.status,
                    e.receiptUrls.length,
                  ),
                ),
              );
              return (
                idsVersion,
                s.isLoading,
                s.isLoadingMore,
                s.hasMore,
                s.transactionsError,
                s.listPhase,
              );
            },
            builder: (context, tuple, _) {
              final tx = context.read<TransactionsNotifier>();
              if (tx.isLoading && tx.transactions.isEmpty) {
                return const AppLoading();
              }
              return ValueListenableBuilder<String>(
                valueListenable: _debouncedSearchQuery,
                builder: (context, _, _) {
                  // Busca local sobre o conjunto já filtrado no Firestore (datasource).
                  final filtered = applyStatementFilter(
                    tx.transactions,
                    _uiSearchOnlyCriteria(),
                  );
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
                              onSearchChanged: _onSearchTextChanged,
                              periodoTexto: _periodoTexto,
                              onPeriodTap: _showPeriodoOptions,
                              tipoFiltro: _tipoFiltro,
                              onTipoChanged: (v) {
                                setState(() => _tipoFiltro = v ?? 'todas');
                                _loadWithServerSideFilters();
                              },
                              statusFiltro: _statusFiltro,
                              onStatusChanged: (v) {
                                setState(() => _statusFiltro = v ?? 'todas');
                                _loadWithServerSideFilters();
                              },
                              categoriaFiltro: _categoriaFiltro,
                              onCategoriaChanged: (v) {
                                setState(() => _categoriaFiltro = v ?? 'todas');
                                _loadWithServerSideFilters();
                              },
                              minValueController: _minValueController,
                              maxValueController: _maxValueController,
                              onMinMaxChanged: () {
                                setState(() {});
                                _loadWithServerSideFilters();
                              },
                              onClearFilters: _limparFiltros,
                            ),
                          ),
                          if (filtered.isEmpty)
                            SliverFillRemaining(
                              child: Center(
                                child:
                                    tx.isLoadingMore &&
                                        tx.transactions.isNotEmpty
                                    ? const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      )
                                    : Text(
                                        _extratoEmptyMessage(tx),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize:
                                                  AppDesignTokens.fontSizeBody,
                                              color: AppDesignTokens
                                                  .colorContentDisabled,
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
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  i,
                                ) {
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontSize:
                                                AppDesignTokens.fontSizeSmall,
                                            color: AppDesignTokens
                                                .colorContentDisabled,
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
              );
            },
          ),
    );
  }
}
