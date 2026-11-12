import 'package:flutter/rendering.dart';

class ChildLayoutParentData<ID extends Object>() extends ContainerBoxParentData<RenderBox> {
  ID? layoutId;
  EdgeInsets? padding;
  Object? data;
  bool shouldPaint = true;
}
