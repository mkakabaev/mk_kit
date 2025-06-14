import 'dart:math';

import 'package:flutter/material.dart';

class Splitter extends StatefulWidget {
  final Widget top;
  final Widget bottomPanel;
  final double minTopHeight;
  final double minBottomHeight;

  const Splitter({
    super.key,
    required this.top,
    required this.bottomPanel,
    required this.minTopHeight,
    required this.minBottomHeight,
  });

  @override
  State createState() => _SplitterState();
}

class _SplitterState extends State<Splitter> {
  var _split = 0.5;
  var _initY = 0.0;
  var _initY0 = 0.0;
  var _height = 0.0;
  var _isDown = false;
  final _dividerHeight = 16.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _height = constraints.maxHeight;
        final y = (_split * _height).roundToDouble() - _dividerHeight / 2;
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(top: 0, left: 0, right: 0, height: y, child: widget.top),
            Positioned(
              top: y,
              left: 0,
              right: 0,
              height: _dividerHeight,
              child: GestureDetector(
                onPanStart: (details) => _handleDrag(details),
                onPanUpdate: _handleUpdate,
                onPanDown: (_) => setState(() => _isDown = true),
                onPanEnd: (_) => setState(() => _isDown = false),
                child: Container(
                  color: Colors.grey.shade300,
                  child: Center(
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: const StadiumBorder(),
                        color: _isDown ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      height: 6,
                      width: 50,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: y + _dividerHeight,
              left: 0,
              right: 0,
              height: _height - y - _dividerHeight,
              child: widget.bottomPanel,
            ),
            Positioned(
              left: 0,
              top: y + _dividerHeight,
              right: 0,
              // height: 100,
              child: OverflowBar(
                alignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.arrow_upward), onPressed: () => _moveRel(-1)),
                  IconButton(icon: const Icon(Icons.arrow_downward), onPressed: () => _moveRel(1)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _moveRel(double dy) {
    _move((_split * _height).roundToDouble() + dy);
  }

  void _move(double y) {
    final adjustedY = min(
      max(widget.minTopHeight + _dividerHeight / 2, y),
      _height - widget.minBottomHeight - _dividerHeight / 2,
    );
    setState(() {
      _split = adjustedY / _height;
    });
  }

  void _handleDrag(DragStartDetails details) {
    setState(() {
      _initY = details.globalPosition.dy;
      _initY0 = _split * _height;
    });
  }

  void _handleUpdate(DragUpdateDetails details) {
    _move(details.globalPosition.dy - _initY + _initY0);
  }
}
