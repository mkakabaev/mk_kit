import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

import 'description.dart';

// cSpell: ignore closable, Diagnosticable, closables

abstract interface class Disposable {
  void dispose();
}

typedef DisposableAdder<T> = void Function(T value);

class DisposableBagEntryAdapter<T extends Object> {
  final DisposableAdder _onAdd;
  const DisposableBagEntryAdapter(this._onAdd);

  void operator <<(T object) {
    _onAdd(object);
  }
}

class DisposeBag with DescriptionProvider, Diagnosticable implements Disposable {
  final List<_Item> _items;
  var _disposed = false;

  String? name;

  static bool get isLogEnabled => _logger.isEnabled;
  static set isLogEnabled(bool value) => _logger.isEnabled = value;

  factory DisposeBag({String? name}) {
    final items = <_Item>[];
    return DisposeBag._(
      name,
      items,
      DisposableBagEntryAdapter((v) => items.add(_SubscriptionItem(v))),
      DisposableBagEntryAdapter((v) => items.add(_DisposableItem(v))),
      DisposableBagEntryAdapter((v) => items.add(_ClosableItem(v))),
    );
  }

  DisposeBag._(this.name, this._items, this.subscriptions, this.disposables, this.closables);

  final DisposableBagEntryAdapter<StreamSubscription> subscriptions;
  final DisposableBagEntryAdapter closables;
  final DisposableBagEntryAdapter disposables;

  void addDisposable(Object object) {
    _items.add(_DisposableItem(object));
  }

  void addSubscription(StreamSubscription subscription) {
    _items.add(_SubscriptionItem(subscription));
  }

  void addClosable(Object closable) {
    _items.add(_ClosableItem(closable));
  }

  @override
  void configureDescription(DescriptionBuilder db) {
    db.addValue(name, quote: true);
  }

  @override
  void dispose() {
    if (_disposed) {
      assert(false, '$this has already been disposed');
      return;
    }
    _disposed = true;
    _logger(() => 'Disposing $this...');
    _logger.level += 1;
    try {
      // dispose in reversed order, LIFO order
      for (var i = _items.length - 1; i >= 0; i -= 1) {
        _items.elementAtOrNull(i)?.invoke();
      }
      _items.clear();
    } finally {
      _logger.level -= 1;
    }
    _items.clear();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('items', _items));
  }
}

mixin DisposeBagHolder implements Disposable {
  final disposeBag = DisposeBag();

  T autoDispose<T extends Disposable>(T disposable) {
    disposeBag.addDisposable(disposable);
    return disposable;
  }

  T autoClose<T extends Object>(T closable) {
    disposeBag.addClosable(closable);
    return closable;
  }

  StreamSubscription autoCancel(StreamSubscription subscription) {
    disposeBag.addSubscription(subscription);
    return subscription;
  }

  @override
  @mustCallSuper
  void dispose() {
    disposeBag.dispose();
  }
}

abstract interface class _Item<T extends Object> with Diagnosticable {
  final T object;
  _Item(this.object);

  void invoke();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('object', object));
  }
}

class _DisposableItem extends _Item {
  _DisposableItem(super.object)
      : assert(
          () {
            try {
              // Just a comment to self-explanatory code
              // ignore: avoid-dynamic, avoid-ignoring-return-values
              (object as dynamic).dispose;
              return true;
            } on NoSuchMethodError {
              return false;
            }
          }(),
          'The ${object.runtimeType} type must have dispose() method',
        );

  @override
  void invoke() {
    _logger(() => 'Disposing $object...');
    try {
      // Just a comment to self-explanatory code
      // ignore: avoid-dynamic, avoid-ignoring-return-values
      (object as dynamic).dispose();
    } on NoSuchMethodError {
      _logger(() => "The '${object.runtimeType}' type has no dispose() method");
    }
  }
}

class _SubscriptionItem extends _Item<StreamSubscription> {
  _SubscriptionItem(super.object);

  @override
  void invoke() {
    _logger(() => 'Canceling $object...');

    // In rare cases when you really need await here not not use DisposeBag at all
    // ignore: avoid-async-call-in-sync-function
    object.cancel();
  }
}

class _ClosableItem extends _Item {
  _ClosableItem(super.object)
      : assert(
          () {
            try {
              // Just a comment to self-explanatory code
              // ignore: avoid-dynamic, avoid-ignoring-return-values
              (object as dynamic).close;
              return true;
            } on NoSuchMethodError {
              return false;
            }
          }(),
          'The ${object.runtimeType} type must have close() method',
        );

  @override
  void invoke() {
    _logger(() => 'Closing $object...');
    try {
      // Just a comment to self-explanatory code
      // ignore: avoid-dynamic, avoid-ignoring-return-values
      (object as dynamic).close();
    } on NoSuchMethodError {
      _logger(() => "The '${object.runtimeType}' type has no close() method");
    }
  }
}

class _DisposeBagLogger {
  int level = 0;
  bool isEnabled = false;

  void call(String Function() f) {
    if (!isEnabled) {
      return;
    }

    final padding = '  ' * level;
    dev.log(padding + f());
  }
}

// Let it be global for now
final _logger = _DisposeBagLogger();
