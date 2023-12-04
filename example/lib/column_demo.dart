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
          children: <Widget>[
            FixedChild(
              color: Colors.green,
              height: 120.0,
            ),

            MKSpacer(
              minHeight: 20,
              height: 40,
              isExpandable: true,
              child: SpacerChild(color: Colors.red, label: 'Expandable 40(>=20)'),
            ),

            MKSpacer(
              height: 80,
              minHeight: 40,
              isExpandable: true,
              child: SpacerChild(color: Colors.yellow, label: 'Expandable 80(>=40)'),
            ),

            MKSpacer(
              height: 100,
              minHeight: 0,
              isExpandable: true,
              child: SpacerChild(color: Colors.lightBlue, label: '100(>=0)'),
            ),

            MKSpacer(
              height: 60,
              minHeight: 60,
              child: SpacerChild(color: Colors.amber, label: '==60'),
            ),

            FixedChild(
              color: Colors.green,
              height: 120.0,
            ),
            // const MKSpacer(height: 50, minHeight: 16,),
            FixedChild(
              color: Colors.orange,
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

///
/// Fixed size component.
///
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
      child: Text('Fixed $height'),
    );
  }
}

///
/// Spacer content. MKSpace does not require a child, this is just for demo purposes
/// to show real height of the spacer.
///
class SpacerChild extends StatelessWidget {
  final Color color;
  final String label;

  const SpacerChild({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          color: color,
          alignment: Alignment.center,
        //   decoration: BoxDecoration1(),
          child: Text('$label | ${constraints.maxHeight}'),
        );
      },
    );
  }
}
