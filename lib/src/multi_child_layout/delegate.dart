import 'package:flutter/rendering.dart';

import 'layout.dart';

///
/// Similar to [MultiChildLayoutDelegate] but with additional generic parameters for ID and DATA.
///
abstract class const ChildLayoutDelegate<ID extends Object>() {
  Size performLayout(Map<ID, ChildLayout<ID>> children, BoxConstraints constraints);
  bool shouldRelayout(covariant ChildLayoutDelegate<ID> oldDelegate) => this != oldDelegate;
}
