
import 'package:flutter/widgets.dart';

class MKColumnSpacer extends StatelessWidget {
  final double height;
  final double minHeight;
  final bool isExpandable;
  final Widget? child;

  static const defaultMinHeight = 8.0;

  const MKColumnSpacer({
    super.key,
    required this.height,
    this.minHeight = defaultMinHeight,
    this.isExpandable = false,
    this.child,
  }) : assert(minHeight >= 0),
       assert(height >= minHeight);

  @override
  Widget build(BuildContext context) {
    assert(false, 'should not be called directly');
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight, maxHeight: height),
      child: child,
    );
  }
}
