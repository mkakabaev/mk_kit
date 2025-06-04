// ignore_for_file: avoid-duplicate-initializers, avoid-unnecessary-reassignment, avoid-duplicate-test-assertions

import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

void main() {
  group('ValueState', () {
    test('initial state', () {
      final state = ValueState<int, String, void>.initial();
      expect(state.status, ValueStateStatus.initial);
      expect(state.hasValue, false);
      expect(state.error, null);
      expect(() => state.requiredValue, throwsA(isA<ValueStateException>()));
      expect(() => state.requiredError, throwsA(isA<ValueStateException>()));
    });

    test('loading state', () {
      final state = ValueState<int, String, void>.initial().toLoading();
      expect(state.status, ValueStateStatus.loading);
      expect(state.hasValue, false);
      expect(state.error, null);
      expect(state.tag as Object?, null);
      expect(() => state.requiredValue, throwsA(isA<ValueStateException>()));
      expect(() => state.requiredError, throwsA(isA<ValueStateException>()));
    });

    test('loaded state', () {
      const value = 42;
      final state = ValueState<int, String, void>.initial().toLoaded(value);
      expect(state.status, ValueStateStatus.loaded);
      expect(state.hasValue, true);
      expect(state.error, null);
      expect(state.requiredValue, value);
      expect(() => state.requiredError, throwsA(isA<ValueStateException>()));
    });

    test('load failed state', () {
      const error = 'Failed to load';
      final state = ValueState<int, String, void>.initial().toLoadFailed(error);
      expect(state.status, ValueStateStatus.loadFailed);
      expect(state.hasValue, false);
      expect(state.error, error);
      expect(() => state.requiredValue, throwsA(isA<ValueStateException>()));
      expect(state.requiredError, error);
    });

    test('state transitions', () {
      for (final tag in [null, 'test-tag', 42, true, false, '']) {
        var state = ValueState<int, String, Object>.initial(tag: tag);

        // Test initial
        expect(state.tag, tag);

        // Initial -> Loading
        state = state.toLoading();
        expect(state.status, ValueStateStatus.loading);
        expect(state.tag, tag);

        // Loading -> Loaded
        state = state.toLoaded(42);
        expect(state.status, ValueStateStatus.loaded);
        expect(state.requiredValue, 42);
        expect(state.tag, tag);

        // Loaded -> Load Failed
        state = state.toLoadFailed('Error');
        expect(state.status, ValueStateStatus.loadFailed);
        expect(state.requiredError, 'Error');
        expect(state.tag, tag);

        // Load Failed -> Initial
        state = state.toInitial();
        expect(state.status, ValueStateStatus.initial);
        expect(state.hasValue, false);
        expect(state.error, null);
        expect(state.tag, tag);
      }
    });

    test('state with tag', () {
      const tag = 'test-tag';
      final state = ValueState<int, String, String>.initial(tag: tag);
      expect(state.tag, tag);

      final loadedState = state.toLoaded(42);
      expect(loadedState.tag, tag);

      final failedState = loadedState.toLoadFailed('Error');
      expect(failedState.tag, tag);
    });

    test('state equality', () {
      final state1 = ValueState<int, String, void>.initial();
      final state2 = ValueState<int, String, void>.initial();
      expect(state1, equals(state2));

      final state3 = state1.toLoaded(42);
      final state4 = state1.toLoaded(42);
      expect(state3, equals(state4));

      final state5 = state1.toLoadFailed('Error');
      final state6 = state1.toLoadFailed('Error');
      expect(state5, equals(state6));

      expect(state1, isNot(equals(state3)));
      expect(state3, isNot(equals(state5)));
    });
  });
}
