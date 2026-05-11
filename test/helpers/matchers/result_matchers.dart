import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher isSuccessWith(Object? expectedValue) => _IsSuccessWith(expectedValue);

Matcher get isSuccess => const _IsSuccess();

Matcher isFailureWithMessage(String expectedMessage) =>
    _IsFailureWithMessage(expectedMessage);

Matcher get isFailure => const _IsFailure();

class _IsSuccessWith extends Matcher {
  const _IsSuccessWith(this.expectedValue);
  final Object? expectedValue;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! Result) return false;
    if (!item.isSuccess) return false;
    return equals(expectedValue).matches(item.valueOrNull, matchState);
  }

  @override
  Description describe(Description description) =>
      description.add('is Success with value ').addDescriptionOf(expectedValue);
}

class _IsSuccess extends Matcher {
  const _IsSuccess();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Result && item.isSuccess;

  @override
  Description describe(Description description) =>
      description.add('is Success');
}

class _IsFailureWithMessage extends Matcher {
  const _IsFailureWithMessage(this.expectedMessage);
  final String expectedMessage;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! Result) return false;
    if (!item.isFailure) return false;
    return item.failureOrNull?.message == expectedMessage;
  }

  @override
  Description describe(Description description) => description
      .add('is FailureResult with message ')
      .addDescriptionOf(expectedMessage);
}

class _IsFailure extends Matcher {
  const _IsFailure();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Result && item.isFailure;

  @override
  Description describe(Description description) =>
      description.add('is FailureResult');
}
