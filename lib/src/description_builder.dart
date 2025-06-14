import 'package:flutter/foundation.dart';

import 'misc.dart';

class DescriptionBuilder {
  final _items = <String>[];
  String? targetName;

  DescriptionBuilder(Object? target) {
    if (target != null) {
      targetName = target is String ? target : '${target.runtimeType}';
    }
  }

  void _add(String? name, Object? value, bool skipEmpty, bool isQuoted) {
    if (skipEmpty && isEmpty(value)) {
      return;
    }

    var s = stringify(value);
    if (isQuoted && s != null) {
      s = "'$s'";
    } else {
      s ??= '<null>';
    }

    if (name != null) {
      s = '$name: $s';
    }

    _items.add(s);
  }

  void add(String name, Object? value, {bool skipEmpty = true, bool isQuoted = false}) {
    _add(name, value, skipEmpty, isQuoted);
  }

  void addValue(Object? value, {bool skipEmpty = true, bool isQuoted = false}) {
    _add(null, value, skipEmpty, isQuoted);
  }

  void addFlag(String flagName, bool? value) {
    if (value == true) {
      _add(null, flagName, false, false);
    }
  }

  @override
  String toString() {
    final params = _items.join(', ');

    if (isEmpty(targetName)) {
      return params;
    }

    if (params.isNotEmpty) {
      return '<$targetName $params>';
    }

    return '<$targetName>';
  }

  String call() => toString();
}

mixin DescriptionProvider {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    final sb = DescriptionBuilder(this);
    configureDescription(sb);
    return sb();
  }

  void configureDescription(DescriptionBuilder _) {
    // nothing in the base
  }
}
