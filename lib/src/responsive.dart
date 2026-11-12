// ignore_for_file: use_primary_constructors

import 'dart:math';

import 'package:flutter/widgets.dart';

import 'equatable.dart';

/// Responsive utilities and widgets for Flutter.
///
/// This library provides the [Responsive] widget and related classes to scale
/// spacing and screen margin from the current screen size and text scale.
///
/// The [Responsive] widget injects a [ResponsiveData] object into the widget tree,
/// which can be accessed using [Responsive.of] or [Responsive.get]. This data can
/// be used to adjust layout, sizing, and other properties based on the current
/// context.
///
/// Example usage:
/// ```dart
/// Responsive(
///   child: Builder(
///     builder: (context) {
///       final data = Responsive.of(context);
///       return Padding(padding: data.screenMargin, child: const Text('Content'));
///     },
///   ),
/// )
/// ```
///
/// You can customize how [ResponsiveData] is produced by providing a custom
/// [ResponsiveDataProducer] to the [Responsive] widget.
///
/// See also:
///  - [InheritedResponsive], which provides the [ResponsiveData] to descendants.
///  - [ResponsiveData], which holds the screen margin and spacing scale.
///  - [ResponsiveDataProducer], for customizing the data generation logic.

class const Responsive({
  super.key,
  final ResponsiveDataProducer producer = const DefaultResponsiveDataProducer(),
  required final Widget child,
}) extends StatelessWidget {
  static ResponsiveData of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<InheritedResponsive>();
    if (inherited == null) {
      _missingAncestor(context);
    }
    return inherited.data;
  }

  static ResponsiveData get(BuildContext context) {
    final inherited = context.getInheritedWidgetOfExactType<InheritedResponsive>();
    if (inherited == null) {
      _missingAncestor(context);
    }
    return inherited.data;
  }

  static Never _missingAncestor(BuildContext context) {
    throw FlutterError.fromParts([
      ErrorSummary('No InheritedResponsive found.'),
      ErrorDescription(
        '${context.widget.runtimeType} widget requires an InheritedResponsive '
        'ancestor, usually a Responsive widget.',
      ),
      ...context.describeMissingAncestor(expectedAncestorType: InheritedResponsive),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final data = producer.produce(context);
    return InheritedResponsive(data: data, child: child);
  }
}

// ------------------------------------------------------------------------------------------------

class const InheritedResponsive({super.key, required final ResponsiveData data, required super.child})
    extends InheritedWidget {
  @override
  bool updateShouldNotify(InheritedResponsive oldWidget) {
    return oldWidget.data != data;
  }
}

// ------------------------------------------------------------------------------------------------

class const ResponsiveData({
  required final EdgeInsets screenMargin,
  required final double spacing2,
  required final double spacing4,
  required final double spacing6,
  required final double spacing8,
  required final double spacing10,
  required final double spacing12,
  required final double spacing16,
  required final double spacing20,
  required final double spacing24,
  required final double spacing32,
  required final double spacing48,
}) with EquatableProps {
  @override
  List<Object?> get equatableProps => [
    screenMargin,
    spacing2,
    spacing4,
    spacing6,
    spacing8,
    spacing10,
    spacing12,
    spacing16,
    spacing20,
    spacing24,
    spacing32,
    spacing48,
  ];
}

// ------------------------------------------------------------------------------------------------

abstract class ResponsiveDataProducer {
  ResponsiveData produce(BuildContext context);
}

class const DefaultResponsiveDataProducer({
  /// This is a value that is used as a base to calculate (scale) all other
  /// Typically this is taken from a design mockup.
  final double referenceScreenWidth = 390,
}) implements ResponsiveDataProducer {
  double screenMarginDimensions(Size screenSize) {
    final minDimension = screenSize.shortestSide;

    // Convenient link to get modern device sizes: https://gist.github.com/ricsantos/e7baee6885626b9cb87c021a5097623f

    // Small screens
    if (minDimension <= 375) {
      return 16;
    }

    // Typical large smartphone screen
    if (screenSize.width < 768) {
      return 20;
    }

    // Tablets
    return 24;
  }

  @override
  ResponsiveData produce(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final textScaler = MediaQuery.textScalerOf(context);

    final smd = screenMarginDimensions(screenSize);
    final screenMargin = EdgeInsets.all(textScaler.scale(smd).roundToDouble());

    final widthScale = min(max(1.0, screenSize.shortestSide / referenceScreenWidth), 1.1);

    return ResponsiveData(
      screenMargin: screenMargin,
      spacing2: textScaler.scale(widthScale * 2).roundToDouble(),
      spacing4: textScaler.scale(widthScale * 4).roundToDouble(),
      spacing6: textScaler.scale(widthScale * 6).roundToDouble(),
      spacing8: textScaler.scale(widthScale * 8).roundToDouble(),
      spacing10: textScaler.scale(widthScale * 10).roundToDouble(),
      spacing12: textScaler.scale(widthScale * 12).roundToDouble(),
      spacing16: textScaler.scale(widthScale * 16).roundToDouble(),
      spacing20: textScaler.scale(widthScale * 20).roundToDouble(),
      spacing24: textScaler.scale(widthScale * 24).roundToDouble(),
      spacing32: textScaler.scale(widthScale * 32).roundToDouble(),
      spacing48: textScaler.scale(widthScale * 48).roundToDouble(),
    );
  }
}
