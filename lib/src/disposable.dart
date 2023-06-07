import 'dart:developer' as dev;
import 'dart:async';

import './description.dart';

abstract class Disposable {
  void dispose();
}

class DisposeBag with DescriptionProvider implements Disposable {
  final _items = <_Item>[];

  String? name;

  static bool get isLogEnabled => _logger.isEnabled;
  static set isLogEnabled(bool value) => _logger.isEnabled = value;

  DisposeBag({this.name});

  void addDisposable(Object object) {
    _items.add(_DisposableItem(object));
  }

  void addSubscription(StreamSubscription subscription) {
    _items.add(_SubscriptionItem(subscription));
  }

  void addClosable(Object stream) {
    _items.add(_ClosableItem(stream));
  }

  @override
  void configureDescription(DescriptionBuilder db) {
    db.addValue(name, quote: true);
  }

  @override
  void dispose() {
    _logger(() => 'Disposing $this...');
    _logger.level += 1;
    try {
      // dispose in reversed order: best for most cases
      for (var i = _items.length - 1; i >= 0; i--) {
        _items[i].disposeAction();
      }
      _items.clear();
    } finally {
      _logger.level -= 1;
    }
  }
}

mixin DisposeBagHolder {
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
}

class _DisposeBagLogger {
  int level = 0;
  bool isEnabled = false;

  void call(String Function() f) {
    if (isEnabled) {
      final padding = '  ' * level;
      dev.log(padding + f());
    }
  }
}

final _logger = _DisposeBagLogger();

abstract class _Item {
  void disposeAction();
}

class _DisposableItem extends _Item {
  final Object disposable;

  _DisposableItem(this.disposable);

  @override
  void disposeAction() {
    _logger(() => 'Disposing $disposable...');
    try {
      (disposable as dynamic).dispose();
    } on NoSuchMethodError catch (e) {
      _logger(() => "The '${disposable.runtimeType}' type has no dispose() method: $e");
    }
  }
}

class _SubscriptionItem extends _Item {
  final StreamSubscription subscription;

  _SubscriptionItem(this.subscription);

  @override
  void disposeAction() {
    _logger(() => 'Canceling $subscription...');
    subscription.cancel();
  }
}

class _ClosableItem extends _Item {
  final Object closable;

  _ClosableItem(this.closable);

  @override
  void disposeAction() {
    _logger(() => 'Closing $closable...');
    try {
      (closable as dynamic).close();
    } on NoSuchMethodError catch (e) {
      _logger(() => "The '${closable.runtimeType}' type has no close() method: $e");
    }
  }
}
