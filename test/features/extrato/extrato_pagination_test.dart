import 'package:cortex_bank_mobile/features/extrato/extrato_pagination.dart';
import 'package:flutter_test/flutter_test.dart';

ExtratoLoadMoreContext ctx({
  bool hasMore = true,
  bool isLoadingMore = false,
  bool isLoading = false,
  int loadedCount = 10,
  int filteredCount = 5,
  bool scrollHasClients = true,
  bool hasViewportDimension = true,
  double extentAfter = 1000,
  double maxScrollExtent = 5000,
}) {
  return ExtratoLoadMoreContext(
    hasMore: hasMore,
    isLoadingMore: isLoadingMore,
    isLoading: isLoading,
    loadedCount: loadedCount,
    filteredCount: filteredCount,
    scrollHasClients: scrollHasClients,
    hasViewportDimension: hasViewportDimension,
    extentAfter: extentAfter,
    maxScrollExtent: maxScrollExtent,
  );
}

void main() {
  group('shouldRequestLoadMore', () {
    test('não deve solicitar quando hasMore for falso', () {
      expect(shouldRequestLoadMore(ctx(hasMore: false)), false);
    });

    test('não deve solicitar quando isLoadingMore for verdadeiro', () {
      expect(shouldRequestLoadMore(ctx(isLoadingMore: true)), false);
    });

    test('não deve solicitar quando estiver carregando e lista vazia', () {
      expect(
        shouldRequestLoadMore(
          ctx(isLoading: true, loadedCount: 0, filteredCount: 0),
        ),
        false,
      );
    });

    test(
      'deve solicitar quando filtro vazio mas já houver itens carregados sem scroll',
      () {
        expect(
          shouldRequestLoadMore(
            ctx(
              filteredCount: 0,
              loadedCount: 3,
              scrollHasClients: false,
              hasViewportDimension: false,
            ),
          ),
          true,
        );
      },
    );

    test(
      'não deve solicitar quando filtro e lista carregada estiverem vazios',
      () {
        expect(
          shouldRequestLoadMore(ctx(filteredCount: 0, loadedCount: 0)),
          false,
        );
      },
    );

    test(
      'não deve solicitar quando houver itens mas scroll não tiver clients',
      () {
        expect(
          shouldRequestLoadMore(
            ctx(filteredCount: 3, loadedCount: 3, scrollHasClients: false),
          ),
          false,
        );
      },
    );

    test('não deve solicitar quando não houver dimensão de viewport', () {
      expect(
        shouldRequestLoadMore(
          ctx(filteredCount: 3, hasViewportDimension: false),
        ),
        false,
      );
    });

    test('deve solicitar quando viewport for curta', () {
      expect(
        shouldRequestLoadMore(
          ctx(
            maxScrollExtent: extratoLoadMoreScrollThreshold,
            extentAfter: 1000,
          ),
        ),
        true,
      );
    });

    test('deve solicitar quando extentAfter estiver abaixo do limiar', () {
      expect(
        shouldRequestLoadMore(
          ctx(
            maxScrollExtent: 5000,
            extentAfter: extratoLoadMoreScrollThreshold,
          ),
        ),
        true,
      );
    });

    test(
      'não deve solicitar quando extentAfter acima do limiar e viewport alto',
      () {
        expect(
          shouldRequestLoadMore(
            ctx(
              maxScrollExtent: 5000,
              extentAfter: extratoLoadMoreScrollThreshold + 1,
            ),
          ),
          false,
        );
      },
    );
  });
}
