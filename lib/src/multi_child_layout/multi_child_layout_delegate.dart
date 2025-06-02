import 'package:flutter/rendering.dart';

import 'child_layout.dart';

///
/// Similar to [MultiChildLayoutDelegate] but with additional generic parameters for ID and DATA.
///
abstract class MKMultiChildLayoutDelegate<ID extends Object> {

  const MKMultiChildLayoutDelegate();  

  Size performLayout(Map<ID, MKChildLayout<ID>> children, BoxConstraints constraints);
  bool shouldRelayout(covariant MKMultiChildLayoutDelegate<ID> oldDelegate) => this != oldDelegate;
}
