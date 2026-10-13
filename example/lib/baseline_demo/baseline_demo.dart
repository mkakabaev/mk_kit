import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

import 'package:mk_kit/mk_kit.dart';

class BaselineDemo extends StatefulWidget {
  const BaselineDemo({super.key});

  @override
  State<BaselineDemo> createState() => _BaselineDemoState();
}

class _BaselineDemoState extends State<BaselineDemo> {
  var _alignment = 0.0;
  var _flutterBaseline = 56.0;

  @override
  Widget build(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('Baseline Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'The circle has no text baseline of its own. BaselineBox reports one so it lines up with the text. '
            '0 is the bottom of the circle, 1 is the top, and values outside that range sit past the circle.',
            style: body,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: _Preview(alignment: _alignment),
          ),
          _SliderControl(
            label: 'Alignment',
            value: _alignment,
            min: -1,
            max: 2,
            onChanged: (value) => setState(() => _alignment = value),
          ),
          const SizedBox(height: 24),
          Text('Flutter Baseline', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            "Baseline places the child's alphabetic baseline this many pixels from the top. "
            "The circle has no baseline, so its bottom is used.",
            style: body,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: _FlutterPreview(baseline: _flutterBaseline),
          ),
          _SliderControl(
            label: 'Baseline',
            value: _flutterBaseline,
            min: 0,
            max: 120,
            fractionDigits: 0,
            onChanged: (value) => setState(() => _flutterBaseline = value),
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.alignment});

  final double alignment;

  @override
  Widget build(BuildContext context) {
    return _PreviewFrame(
      children: [
        const Text('Ay', style: TextStyle(fontSize: 48)),
        BaselineBox(
          delegate: FractionalBaselineDelegate(alignment: alignment),
          child: const _Circle(),
        ),
        BaselineBox(
          delegate: FractionalBaselineDelegate(alignment: alignment),
          child: const Text("Ay", style: TextStyle(fontSize: 48)),
        ),
      ],
    );
  }
}

class _FlutterPreview extends StatelessWidget {
  const _FlutterPreview({required this.baseline});

  final double baseline;

  @override
  Widget build(BuildContext context) {
    return _PreviewFrame(
      children: [
        Baseline(
          baseline: baseline,
          baselineType: TextBaseline.alphabetic,
          child: const Text('Ay', style: TextStyle(fontSize: 48)),
        ),
        Baseline(baseline: baseline, baselineType: TextBaseline.alphabetic, child: const _Circle()),
        Baseline(
          baseline: baseline,
          baselineType: TextBaseline.alphabetic,
          child: const Text("Ay", style: TextStyle(fontSize: 48)),
        ),
      ],
    );
  }
}

class _PreviewFrame extends StatelessWidget {
  final List<Widget> children;

  const _PreviewFrame({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        border: const Border.fromBorderSide(BorderSide(color: Colors.black12)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          border: const Border.symmetric(horizontal: BorderSide(color: Colors.black12)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _RowBaseline(
          child: Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      ),
    );
  }
}

class _RowBaseline extends SingleChildRenderObjectWidget {
  const _RowBaseline({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderRowBaseline();
}

class _RenderRowBaseline extends RenderProxyBox {
  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    final baseline = getDistanceToBaseline(TextBaseline.alphabetic);
    if (baseline == null) {
      return;
    }

    context.canvas.drawLine(
      offset + Offset(0, baseline),
      offset + Offset(size.width, baseline),
      Paint()
        ..color = Colors.blue.withValues(alpha: 0.5)
        ..strokeWidth = 1,
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
    this.fractionDigits = 2,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int fractionDigits;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$label  ${value.toStringAsFixed(fractionDigits)}'),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
