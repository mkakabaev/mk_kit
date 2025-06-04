import 'description_builder.dart';
import 'equatable.dart';

final class ValueState<T, ERR extends Object, TAG> with DescriptionProvider, EquatableProps {
  final T? _value;
  final bool hasValue;
  final ERR? error;
  final ValueStateStatus status;
  final TAG? tag;

  const ValueState._(this._value, this.status, this.hasValue, this.error, this.tag);

  const ValueState.initial({TAG? tag}) : this._(null as T?, ValueStateStatus.initial, false, null as ERR?, tag);

  /// Switch state to loading with keeping the current value and clearing the error
  ValueState<T, ERR, TAG> toLoading() => ValueState._(_value, ValueStateStatus.loading, hasValue, null, tag);

  /// Switch state to loaded with setting a value and clearing the error
  ValueState<T, ERR, TAG> toLoaded(T value) => ValueState._(value, ValueStateStatus.loaded, true, null, tag);

  /// Switch state to error with setting a error value and keeping the current value
  ValueState<T, ERR, TAG> toLoadFailed(ERR error) =>
      ValueState._(_value, ValueStateStatus.loadFailed, hasValue, error, tag);

  /// Switch state to initial with clearing the value and error
  ValueState<T, ERR, TAG> toInitial() => ValueState.initial(tag: tag);

  T get requiredValue {
    if (!hasValue) {
      throw ValueStateException('The value is not available for this state');
    }
    // ignore: avoid-non-null-assertion
    return _value!;
  }

  ERR get requiredError {
    final result = error;
    if (result == null) {
      throw ValueStateException('The error is not available for this state');
    }
    return result;
  }

  @override
  void configureDescription(DescriptionBuilder builder) {
    builder.add('tag', tag);
    builder.add('status', status);
    builder.addFlag('hasValue', hasValue);
    builder.add('error', error);
  }
  
  @override
  List<Object?> get equatableProps => [tag, status, _value, error];
}

// ------------------------------------------------------------------------------------------------

enum ValueStateStatus { initial, loading, loaded, loadFailed }

// ------------------------------------------------------------------------------------------------

// An alternative to enum for value state status
// sealed class ValueStateStatusObject<T, ERR extends Object> {
//   const ValueStateStatusObject();
// }

// class ValueStateStatusInitial<T, ERR extends Object> extends ValueStateStatusObject<T, ERR> {
//   const ValueStateStatusInitial();
// }

// class ValueStateStatusLoading<T, ERR extends Object> extends ValueStateStatusObject<T, ERR> {
//   const ValueStateStatusLoading();
// }

// class ValueStateStatusLoaded<T, ERR extends Object> extends ValueStateStatusObject<T, ERR> {
//   final T value;
//   const ValueStateStatusLoaded(this.value);
// }

// class ValueStateStatusLoadFailed<T, ERR extends Object> extends ValueStateStatusObject<T, ERR> {
//   final ERR error;
//   const ValueStateStatusLoadFailed(this.error);
// }

// ------------------------------------------------------------------------------------------------

class ValueStateException implements Exception {
  final String message;

  const ValueStateException(this.message);

  @override
  String toString() {
    return 'ValueStateException: $message';
  }
}
