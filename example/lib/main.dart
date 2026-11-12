import 'package:flutter/material.dart';

import 'package:mk_kit/mk_kit.dart';

import 'baseline_demo/baseline_demo.dart';
import 'buttons_demo/buttons_demo.dart';
import 'column_demo/column_demo.dart';
import 'responsive_demo/responsive_demo.dart';
import 'reference_sized_box_demo/reference_sized_box_demo.dart';

void main() {
  runApp(const MKKitExampleApp());
}

class const MKKitExampleApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true);
    return Responsive(
      child: MaterialApp(
        title: 'MK-Kit Demo',
        theme: baseTheme.copyWith(appBarTheme: AppBarTheme(backgroundColor: baseTheme.colorScheme.inversePrimary)),
        home: const _HomePage(),
      ),
    );
  }
}

class const _HomePage() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('mk-kit demo')),
      body: ListView(
        children: [
          _ListItem(title: 'Column', screenBuilder: (_) => const ColumnDemo()),
          _ListItem(title: 'Responsive', screenBuilder: (_) => const ResponsiveDemo()),
          _ListItem(title: 'Baseline', screenBuilder: (_) => const BaselineDemo()),
          _ListItem(title: 'ReferenceSizedBox', screenBuilder: (_) => const ReferenceSizedBoxDemo()),
          _ListItem(title: 'Buttons', screenBuilder: (_) => const ButtonsDemo()),
        ],
      ),
    );
  }
}

class const _ListItem({required final String title, required final WidgetBuilder screenBuilder})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => screenBuilder(context)));
      },
    );
  }
}
