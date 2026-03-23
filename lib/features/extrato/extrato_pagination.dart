/// Distância do fim do conteúdo abaixo da viewport; contrato com o extrato atual.
const double extratoLoadMoreScrollThreshold = 520;

/// Entrada imutável para decidir se deve pedir mais itens ao [TransactionsProvider].
class ExtratoLoadMoreContext {
  const ExtratoLoadMoreContext({
    required this.hasMore,
    required this.isLoadingMore,
    required this.isLoading,
    required this.loadedCount,
    required this.filteredCount,
    required this.scrollHasClients,
    required this.hasViewportDimension,
    required this.extentAfter,
    required this.maxScrollExtent,
  });

  final bool hasMore;
  final bool isLoadingMore;
  final bool isLoading;
  final int loadedCount;
  final int filteredCount;
  final bool scrollHasClients;
  final bool hasViewportDimension;
  final double extentAfter;
  final double maxScrollExtent;
}

/// Replica a árvore de decisão de `_checkLoadMore` da [ExtratoPage].
bool shouldRequestLoadMore(ExtratoLoadMoreContext ctx) {
  if (!ctx.hasMore || ctx.isLoadingMore) return false;
  if (ctx.isLoading && ctx.loadedCount == 0) return false;

  if (ctx.filteredCount == 0 && ctx.loadedCount > 0) return true;
  if (ctx.filteredCount == 0) return false;

  if (!ctx.scrollHasClients) return false;
  if (!ctx.hasViewportDimension) return false;

  final shortViewport =
      ctx.maxScrollExtent <= extratoLoadMoreScrollThreshold;
  if (shortViewport || ctx.extentAfter <= extratoLoadMoreScrollThreshold) {
    return true;
  }
  return false;
}
