import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

import 'description_builder.dart';

// cSpell: ignore closable, closables
// ignore_for_file: strict_raw_type, argument_type_not_assignable, avoid-dynamic

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

class DisposeBag with Diagnosticable, DescriptionProvider implements Disposable {
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
    db.addValue(name, isQuoted: true);
  }

  @override
  void dispose() {
    if (_disposed) {
      assert(false, '$this has already been disposed');
      return;
    }
    _disposed = true;
    if (_logger.isEnabled) {
      _logger('Disposing $this...');
    }
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

  const _Item(this.object);

  void invoke();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('object', object));
  }
}

class _DisposableItem extends _Item {
  _DisposableItem(super.object)
    : assert(() {
        try {
          // Just a comment to self-explanatory code
          (object as dynamic).dispose;
          return true;
        } on NoSuchMethodError {
          return false;
        }
      }(), 'The ${object.runtimeType} type must have dispose() method');

  @override
  void invoke() {
    if (_logger.isEnabled) {
      _logger('Disposing $object...');
    }
    try {
      // Just a comment to self-explanatory code
      (object as dynamic).dispose();
    } on NoSuchMethodError {    
      if (_logger.isEnabled) {
        _logger("The '${object.runtimeType}' type has no dispose() method");
      }
    }
  }
}

class _SubscriptionItem extends _Item<StreamSubscription> {
  const _SubscriptionItem(super.object);

  @override
  void invoke() {
    if (_logger.isEnabled) {
      _logger('Canceling $object...');
    }

    // In rare cases when you really need await here do not use DisposeBag at all
    unawaited(object.cancel());
  }
}

class _ClosableItem extends _Item {
  _ClosableItem(super.object)
    : assert(() {
        try {
          // Just a comment to self-explanatory code
          (object as dynamic).close;
          return true;
        } on NoSuchMethodError {
          return false;
        }
      }(), 'The ${object.runtimeType} type must have close() method');

  @override
  void invoke() {
    if (_logger.isEnabled) {
      _logger('Closing $object...');
    }
    try {
      (object as dynamic).close();
    } on NoSuchMethodError {
        if (_logger.isEnabled) {
          _logger("The '${object.runtimeType}' type has no close() method");
        }
    }
  }
}

class _DisposeBagLogger {
  int level = 0;
  bool isEnabled = false;

  void call(String s) {
    if (!isEnabled) {
      return;
    }

    final padding = '  ' * level;
    dev.log(padding + s);
  }
}

// Let it be global for now
// ignore: prefer-static-class
final _logger = _DisposeBagLogger();
