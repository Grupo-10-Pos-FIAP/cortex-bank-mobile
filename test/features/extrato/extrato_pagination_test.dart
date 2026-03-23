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
  test('hasMore false never requests', () {
    expect(shouldRequestLoadMore(ctx(hasMore: false)), false);
  });

  test('isLoadingMore true never requests', () {
    expect(shouldRequestLoadMore(ctx(isLoadingMore: true)), false);
  });

  test('isLoading and empty loaded never requests', () {
    expect(
      shouldRequestLoadMore(
        ctx(isLoading: true, loadedCount: 0, filteredCount: 0),
      ),
      false,
    );
  });

  test('filteredEmpty and loadedNotEmpty requests without scroll', () {
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
  });

  test('filteredEmpty and loadedEmpty does not request', () {
    expect(
      shouldRequestLoadMore(ctx(filteredCount: 0, loadedCount: 0)),
      false,
    );
  });

  test('filtered not empty without scroll clients does not request', () {
    expect(
      shouldRequestLoadMore(
        ctx(
          filteredCount: 3,
          loadedCount: 3,
          scrollHasClients: false,
        ),
      ),
      false,
    );
  });

  test('filtered not empty without viewport dimension does not request', () {
    expect(
      shouldRequestLoadMore(
        ctx(
          filteredCount: 3,
          hasViewportDimension: false,
        ),
      ),
      false,
    );
  });

  test('shortViewport requests load more', () {
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

  test('extentAfter below threshold requests load more', () {
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

  test('extentAfter above threshold and tall viewport does not request', () {
    expect(
      shouldRequestLoadMore(
        ctx(
          maxScrollExtent: 5000,
          extentAfter: extratoLoadMoreScrollThreshold + 1,
        ),
      ),
      false,
    );
  });
}
