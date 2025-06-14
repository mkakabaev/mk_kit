import 'dart:math';

import 'package:flutter/widgets.dart';

import 'equatable.dart';

class Responsive extends StatelessWidget {
  final Widget child;
  final ResponsiveDataProducer producer;

  const Responsive({super.key, this.producer = const DefaultResponsiveDataProducer(), required this.child});

  static ResponsiveData of(BuildContext context) {
    final r = context.dependOnInheritedWidgetOfExactType<InheritedResponsive>();
    assert(() {
      if (r == null) {
        throw FlutterError.fromParts([
          ErrorSummary('No InheritedResponsive found.'),
          ErrorDescription(
            '${context.widget.runtimeType} widget require InheritedResponsive '
            'to be provided by a Responsive or similar widget ancestor.',
          ),
          ...context.describeMissingAncestor(expectedAncestorType: InheritedResponsive),
        ]);
      }
      return true;
    }());

    return r!.data; // ignore: avoid-non-null-assertion
  }

  static ResponsiveData get(BuildContext context) {
    final r = context.getInheritedWidgetOfExactType<InheritedResponsive>();
    assert(() {
      if (r == null) {
        throw FlutterError.fromParts([
          ErrorSummary('No InheritedResponsive found.'),
          ErrorDescription(
            '${context.widget.runtimeType} widget require InheritedResponsive '
            'to be provided by a Responsive or similar widget ancestor.',
          ),
          ...context.describeMissingAncestor(expectedAncestorType: InheritedResponsive),
        ]);
      }
      return true;
    }());

    return r!.data; // ignore: avoid-non-null-assertion
  }

  @override
  Widget build(BuildContext context) {
    final data = producer.produce(context);
    return InheritedResponsive(data: data, child: child);
  }
}

// ------------------------------------------------------------------------------------------------

class InheritedResponsive extends InheritedWidget {
  final ResponsiveData data;

  const InheritedResponsive({super.key, required this.data, required super.child});

  @override
  bool updateShouldNotify(InheritedResponsive oldWidget) {
    return oldWidget.data != data;
  }
}

// ------------------------------------------------------------------------------------------------

class ResponsiveData with EquatableProps {
  final EdgeInsets screenMargin;
  final double spacing2;
  final double spacing4;
  final double spacing6;
  final double spacing8;
  final double spacing10;
  final double spacing12;
  final double spacing16;
  final double spacing20;
  final double spacing24;
  final double spacing32;
  final double spacing48;

  const ResponsiveData({
    required this.screenMargin,
    required this.spacing2,
    required this.spacing4,
    required this.spacing6,
    required this.spacing8,
    required this.spacing10,
    required this.spacing12,
    required this.spacing16,
    required this.spacing20,
    required this.spacing24,
    required this.spacing32,
    required this.spacing48,
  });

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

class DefaultResponsiveDataProducer implements ResponsiveDataProducer {
  /// This is a value that is used as a base to calculate (scale) all other
  /// Typically this is taken from a design mockup.
  final double referenceScreenWidth;

  const DefaultResponsiveDataProducer({this.referenceScreenWidth = 390});

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
