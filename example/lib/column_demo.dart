// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:mk_kit/mk_kit.dart';

import './helpers/splitter.dart';

class ColumnDemo extends StatefulWidget {
  const ColumnDemo({super.key});

  @override
  State createState() => _ColumnDemoState();
}

class _ColumnDemoState extends State<ColumnDemo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Column Demo'),
      ),
      body: Splitter(
        top: MKColumn(
          // mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FixedChild(
              color: Colors.green, // Green
              height: 120.0,
            ),

            MKSpacer(
              minHeight: 20,
              height: 75,
              isExpandable: true,
              child: SpacerChild(color: Colors.red),
            ),

            MKSpacer(
              height: 80,
              minHeight: 40,
              isExpandable: true,
              child: SpacerChild(color: Colors.yellow),
            ),

            MKSpacer(
              height: 100,
              minHeight: 0,
              isExpandable: true,
              child: SpacerChild(color: Colors.lightBlue),
            ),

            MKSpacer(
              height: 60,
              minHeight: 60,
              child: SpacerChild(color: Colors.amber),
            ),

            FixedChild(
              color: Colors.green, // Green
              height: 120.0,
            ),
            // const MKSpacer(height: 50, minHeight: 16,),
            FixedChild(
              color: Colors.orange, // Green
              height: 20.0,
            ),
          ],
        ),
        bottomPanel: Container(),
        minBottomHeight: 8,
        minTopHeight: 8,
      ),
    );
  }
}

class FixedChild extends StatelessWidget {
  final Color color;
  final double height;

  const FixedChild({
    super.key,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      height: height,
      alignment: Alignment.center,
      child: Text('Fixed Height Content $height'),
    );
  }
}

class SpacerChild extends StatelessWidget {
  final Color color;

  const SpacerChild({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final text = 'h: ${constraints.minHeight} ${constraints.maxHeight}';
        return Container(
          color: color,
          alignment: Alignment.center,
          child: Text(text),
        );
      },
    );
  }
}
