import 'package:flutter/material.dart';

import 'package:mk_kit/mk_kit.dart';

import 'splitter.dart';

class ColumnDemo extends StatelessWidget {
  const ColumnDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Column Demo')),
      body: Splitter(
        top: MKColumn(
          children: [
            const FixedHeightChild(color: Colors.green, height: 120.0),

            const MKColumnSpacer(
              minHeight: 20,
              height: 40,
              isExpandable: true,
              child: SpacerChild(color: Colors.red, label: 'Expandable 40(>=20)'),
            ),

            const MKColumnSpacer(
              height: 80,
              minHeight: 40,
              isExpandable: true,
              child: SpacerChild(color: Colors.yellow, label: 'Expandable 80(>=40)'),
            ),

            const MKColumnSpacer(
              height: 100,
              minHeight: 0,
              isExpandable: true,
              child: SpacerChild(color: Colors.lightBlue, label: '100(>=0)'),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'TextField'),
                onChanged: (_) {},
              ),
            ),

            const MKColumnSpacer(
              height: 60,
              minHeight: 60,
              child: SpacerChild(color: Colors.amber, label: '==60'),
            ),

            const FixedHeightChild(color: Colors.green, height: 120.0),
            // const MKSpacer(height: 50, minHeight: 16,),
            const FixedHeightChild(color: Colors.orange, height: 20.0),
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
class FixedHeightChild extends StatelessWidget {
  final Color color;
  final double height;

  const FixedHeightChild({super.key, required this.color, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(color: color, height: height, alignment: Alignment.center, child: Text('Fixed $height'));
  }
}

///
/// Spacer content. MKSpace does not require a child, this is just for demo purposes
/// to show real height of the spacer.
///
class SpacerChild extends StatelessWidget {
  final Color color;
  final String label;

  const SpacerChild({super.key, required this.color, required this.label});

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
