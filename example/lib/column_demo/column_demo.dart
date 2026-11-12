import 'package:flutter/material.dart';

import 'package:mk_kit/mk_kit.dart';

import 'splitter.dart';

class const ColumnDemo({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Column Demo')),
      body: Splitter(
        top: SpacerColumn(
          children: [
            const FixedHeightChild(color: Colors.green, height: 120.0),

            const ColumnSpacer(
              minHeight: 20,
              height: 40,
              isExpandable: true,
              child: SpacerChild(color: Colors.red, label: 'Expandable 40(>=20)'),
            ),

            const ColumnSpacer(
              height: 80,
              minHeight: 40,
              isExpandable: true,
              child: SpacerChild(color: Colors.yellow, label: 'Expandable 80(>=40)'),
            ),

            const ColumnSpacer(
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

            const ColumnSpacer(
              height: 60,
              minHeight: 60,
              child: SpacerChild(color: Colors.amber, label: '==60'),
            ),

            const FixedHeightChild(color: Colors.green, height: 120.0),
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
class const FixedHeightChild({super.key, required final Color color, required final double height})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(color: color, height: height, alignment: Alignment.center, child: Text('Fixed $height'));
  }
}

///
/// Spacer content. ColumnSpacer does not require a child, this is just for demo purposes
/// to show real height of the spacer.
///
class const SpacerChild({super.key, required final Color color, required final String label}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(color: color, alignment: Alignment.center, child: Text('$label | ${constraints.maxHeight}'));
      },
    );
  }
}
