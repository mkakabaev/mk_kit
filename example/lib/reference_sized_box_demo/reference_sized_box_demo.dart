import 'dart:math';

import 'package:flutter/material.dart';

import 'package:mk_kit/mk_kit.dart';

class ReferenceSizedBoxDemo extends StatefulWidget {
  const ReferenceSizedBoxDemo({super.key});

  @override
  State<ReferenceSizedBoxDemo> createState() => _ReferenceSizedBoxDemoState();
}

class _ReferenceSizedBoxDemoState extends State<ReferenceSizedBoxDemo> {
  var _referenceWidth = 160.0;
  var _referenceHeight = 88.0;
  var _width = _AxisRule.exact;
  var _height = _AxisRule.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ReferenceSizedBox')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'The orange rectangle is the reference size. ReferenceSizedBox measures it and does not paint it. '
            'The blue rectangle is the child.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _Preview(
            referenceWidth: _referenceWidth,
            referenceHeight: _referenceHeight,
            width: _width.rule,
            height: _height.rule,
          ),
          const SizedBox(height: 8),
          const _Legend(),
          const SizedBox(height: 24),
          _SliderControl(
            label: 'Reference width',
            value: _referenceWidth,
            min: 48,
            max: 280,
            onChanged: (value) => setState(() => _referenceWidth = value),
          ),
          _SliderControl(
            label: 'Reference height',
            value: _referenceHeight,
            min: 32,
            max: 180,
            onChanged: (value) => setState(() => _referenceHeight = value),
          ),
          const SizedBox(height: 8),
          _RulePicker(
            label: 'Width',
            value: _width,
            onChanged: (value) => setState(() => _width = value),
          ),
          const SizedBox(height: 12),
          _RulePicker(label: 'Height', value: _height, onChanged: (value) => setState(() => _height = value)),
          const SizedBox(height: 16),
          Text(_width.description('width'), style: Theme.of(context).textTheme.bodySmall),
          Text(_height.description('height'), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

enum _AxisRule {
  none,
  exact,
  half;

  String get label => switch (this) {
    none => 'None',
    exact => 'Exact',
    half => 'Half',
  };

  ReferenceSize get rule => switch (this) {
    none => ReferenceSize.none,
    exact => ReferenceSize.exact,
    half => const _HalfRule(),
  };

  String description(String axis) => switch (this) {
    none => '$label: child uses the preview constraints for $axis.',
    exact => '$label: child $axis matches the reference.',
    half => '$label: custom rule, child $axis is half the reference.',
  };
}

class _HalfRule implements ReferenceSize {
  const _HalfRule();

  @override
  ReferenceSizeResult getSize(double extent) {
    final size = extent / 2;
    return (minSize: size, maxSize: size);
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.referenceWidth,
    required this.referenceHeight,
    required this.width,
    required this.height,
  });

  final double referenceWidth;
  final double referenceHeight;
  final ReferenceSize width;
  final ReferenceSize height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: SizedBox(
        height: 240,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fittedWidth = min(referenceWidth, constraints.maxWidth);
              final fittedHeight = min(referenceHeight, constraints.maxHeight - 24);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        _TopLeft(
                          child: _ReferenceBox(width: fittedWidth, height: fittedHeight),
                        ),
                        _TopLeft(
                          child: ReferenceSizedBox(
                            reference: SizedBox(width: fittedWidth, height: fittedHeight),
                            width: width,
                            height: height,
                            child: const _ChildBox(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reference ${fittedWidth.toStringAsFixed(0)} × ${fittedHeight.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopLeft extends StatelessWidget {
  const _TopLeft({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.topLeft, child: child);
  }
}

class _ReferenceBox extends StatelessWidget {
  const _ReferenceBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(
        color: Color(0x66EF6C00),
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Text('reference', style: TextStyle(fontSize: 12, color: Color(0xFF9A3412))),
          ),
        ),
      ),
    );
  }
}

class _ChildBox extends StatelessWidget {
  const _ChildBox();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xBF1565C0),
      child: SizedBox.expand(
        child: Center(
          child: FittedBox(
            child: Text(
              'child',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _Swatch(color: Color(0x66EF6C00), label: 'Reference'),
        SizedBox(width: 16),
        _Swatch(color: Color(0xBF1565C0), label: 'Child'),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 14, height: 14, child: ColoredBox(color: color)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _SliderControl extends StatelessWidget {
  const _SliderControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$label  ${value.toStringAsFixed(0)}'),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

class _RulePicker extends StatelessWidget {
  const _RulePicker({required this.label, required this.value, required this.onChanged});

  final String label;
  final _AxisRule value;
  final ValueChanged<_AxisRule> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label),
        const SizedBox(height: 8),
        SegmentedButton<_AxisRule>(
          showSelectedIcon: false,
          segments: [
            for (final rule in _AxisRule.values) ButtonSegment<_AxisRule>(value: rule, label: Text(rule.label)),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ],
    );
  }
}
