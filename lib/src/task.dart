import 'dart:async';

import 'package:mk_kit/mk_kit.dart';

typedef TaskBody = Future<bool> Function(TaskContext context);

/// Provides context to a [TaskBody], including cancellation status.
abstract class TaskContext {
  /// Whether the task has been canceled.
  bool get isCanceled;
}

/// The current status of a [Task].
enum TaskStatus { pendingFirstRun, running, completed, failed }

///
/// [TaskRestartOption] controls the behavior when attempting to restart a task:
///
enum TaskRestartOption {
  /// Only run the task if it hasn't started yet.
  runIfNotYet,

  /// Start the task immediately if it is not running, or restart it after completion.
  runOrRerun,
}

/// A [Task] represents a unit of asynchronous work that can be scheduled, retried, and canceled.
///
/// Tasks are defined by a [TaskBody] function, which receives a [TaskContext] and returns a [Future<bool>]
/// indicating success (`true`) or failure (`false`). The [Task] manages its own execution state,
/// supports automatic retries with configurable intervals, and can be canceled or restarted.
///
/// Example usage:
/// ```dart
/// final task = Task(
///   name: 'SyncData',
///   body: (context) async {
///     // Perform some async work
///     if (context.isCanceled) return false;
///     // ...
///     return true;
///   },
///   retrySuccessInterval: Duration(minutes: 5),
///   retryFailInterval: Duration(seconds: 30),
/// );
/// ```
///
class Task with DescriptionProvider implements TaskContext {
  final TaskBody body;
  final String name;

  final Duration? retrySuccessInterval;
  final Duration? retryFailInterval;

  var _isCanceled = false;
  var _status = TaskStatus.pendingFirstRun;
  int _retryFailDelayFactor = 0;
  Timer? _timer;
  bool _restartImmediately = false;

  Task({
    required this.body,
    required this.name,
    this.retrySuccessInterval,
    this.retryFailInterval,
    Duration? initialDelay,
  }) {
    _schedulePoll(delay: initialDelay);
  }

  @override
  void configureDescription(DescriptionBuilder sb) {
    sb.addValue(name, isQuoted: true);
    sb.addValue(_status);
  }

  void dispose() {
    _isCanceled = true;
    _timer?.cancel();
  }

  void cancel() {
    _isCanceled = true;
  }

  @override
  bool get isCanceled => _isCanceled;

  void resetRetryFailDelayFactor() {
    _retryFailDelayFactor = 0;
  }

  void restart(TaskRestartOption option) {
    resetRetryFailDelayFactor();

    switch (_status) {
      case TaskStatus.running:
        _restartImmediately = option == TaskRestartOption.runOrRerun;

      case TaskStatus.completed:
      case TaskStatus.pendingFirstRun:
      case TaskStatus.failed:
        _schedulePoll();
    }
  }

  void _schedulePoll({Duration? delay}) {
    assert(!_isCanceled, 'assertion_20230608_768822');
    _timer?.cancel();
    _timer = Timer(delay ?? const Duration(milliseconds: 0), _run);
  }

  void _run() async {
    if (_isCanceled) {
      return;
    }

    if (_status == TaskStatus.running) {
      assert(false, 'assertion_20230608_718814');
      return;
    }

    _status = TaskStatus.running;
    var succeeded = false;
    try {
      if (await body(this)) {
        _status = TaskStatus.completed;
        succeeded = true;
        resetRetryFailDelayFactor();
      } else {
        _status = TaskStatus.failed;
        _retryFailDelayFactor++;
      }
    } catch (e) {
      _status = TaskStatus.failed;
      _retryFailDelayFactor++;
    }

    if (_isCanceled) {
      return;
    }

    // Restart immediately
    if (_restartImmediately) {
      _restartImmediately = false;
      _schedulePoll();
    }

    // Success
    if (succeeded) {
      final retrySuccessInterval = this.retrySuccessInterval;
      if (retrySuccessInterval != null) {
        _schedulePoll(delay: retrySuccessInterval);
      }
    } else {
      final retryFailInterval = this.retryFailInterval;
      if (retryFailInterval != null) {
        var newInterval = retryFailInterval * _retryFailDelayFactor;
        const maxInterval = Duration(minutes: 5);
        if (newInterval > maxInterval) {
          newInterval = maxInterval;
        }
        _schedulePoll(delay: newInterval);
      }
    }
  }
}
