import 'package:flutter/widgets.dart';

class const ColumnSpacer({
  super.key,
  required final double height,
  final double minHeight = defaultMinHeight,
  final bool isExpandable = false,
  final Widget? child,
}) extends StatelessWidget {
  static const defaultMinHeight = 8.0;

  this : assert(minHeight >= 0), assert(height >= minHeight);

  @override
  Widget build(BuildContext context) {
    assert(false, 'should not be called directly');
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight, maxHeight: height),
      child: child,
    );
  }
}
