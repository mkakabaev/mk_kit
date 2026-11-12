import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

void main() {
  test('success interval delays the next run', () async {
    var runs = 0;
    final task = Task(
      name: 'interval',
      retrySuccessInterval: const Duration(milliseconds: 30),
      body: (_) async {
        runs += 1;
        return true;
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(runs, 1);

    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(runs, 2);

    task.dispose();
  });

  test('runOrRerun while running does not wait for the retry interval', () async {
    var runs = 0;

    // ignore: avoid-late-keyword
    late void Function(bool success) finish;

    final task = Task(
      name: 'restart',
      retrySuccessInterval: const Duration(hours: 1),
      retryFailInterval: const Duration(hours: 1),
      body: (_) {
        runs += 1;
        final completer = Completer<bool>();
        finish = completer.complete;
        return completer.future;
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(runs, 1);

    task.restart(TaskRestartOption.runOrRerun);
    finish(true);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(runs, 2);

    task.dispose();
  });
}
