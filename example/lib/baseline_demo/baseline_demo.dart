import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:mk_kit/mk_kit.dart';

class const BaselineDemo({super.key}) extends StatefulWidget {
  @override
  State<BaselineDemo> createState() => _BaselineDemoState();
}

class _BaselineDemoState() extends State<BaselineDemo> {
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

class const _Preview({required final double alignment}) extends StatelessWidget {
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

class const _FlutterPreview({required final double baseline}) extends StatelessWidget {
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

class const _PreviewFrame({required final List<Widget> children}) extends StatelessWidget {
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

class const _Circle() extends StatelessWidget {
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

class const _RowBaseline({required super.child}) extends SingleChildRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) => _RenderRowBaseline();
}

class _RenderRowBaseline() extends RenderProxyBox {
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

class const _SliderControl({
  required final String label,
  required final double value,
  required final double min,
  required final double max,
  required final ValueChanged<double> onChanged,
  final int fractionDigits = 2,
}) extends StatelessWidget {
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
