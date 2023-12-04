import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

import './description.dart';

// cSpell: words Diagnosticable

abstract class Disposable {
    void dispose();
}

class DisposeBag with DescriptionProvider, Diagnosticable implements Disposable {
    final _items = <_Item>[];
    var _disposed = false;

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
        if (_disposed) {
            assert(false, '$this has already been disposed');
            return;
        }
        _disposed = true;
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

abstract class _Item<T extends Object> with Diagnosticable {
    final T object;
    _Item(this.object);

    void disposeAction();

    @override
    void debugFillProperties(DiagnosticPropertiesBuilder properties) {
        super.debugFillProperties(properties);
        properties.add(DiagnosticsProperty('object', object));
    }
}

class _DisposableItem extends _Item {
    _DisposableItem(super.object);

    @override
    void disposeAction() {
        _logger(() => 'Disposing $object...');
        try {
            (object as dynamic).dispose();
        } on NoSuchMethodError catch (e) {
            _logger(() => "The '${object.runtimeType}' type has no dispose() method: $e");
        }
    }
}

class _SubscriptionItem extends _Item<StreamSubscription> {
    _SubscriptionItem(super.object);

    @override
    void disposeAction() {
        _logger(() => 'Canceling $object...');
        object.cancel();
    }
}

class _ClosableItem extends _Item {
    _ClosableItem(super.object);

    @override
    void disposeAction() {
        _logger(() => 'Closing $object...');
        try {
            (object as dynamic).close();
        } on NoSuchMethodError catch (e) {
            _logger(() => "The '${object.runtimeType}' type has no close() method: $e");
        }
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
