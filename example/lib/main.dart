import 'package:flutter/material.dart';

import 'package:mk_kit/mk_kit.dart';

import 'column_demo/column_demo.dart';
import 'responsive_demo/responsive_demo.dart';

void main() {
  runApp(const MKKitExampleApp());
}

class MKKitExampleApp extends StatelessWidget {
  const MKKitExampleApp({super.key});

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

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('mk-kit demo')),
      body: ListView(
        children: [
          _ListItem(title: 'MKColumn', screenBuilder: (_) => const ColumnDemo()),
          _ListItem(title: 'Responsive', screenBuilder: (_) => const ResponsiveDemo()),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({required this.title, required this.screenBuilder});

  final String title;
  final WidgetBuilder screenBuilder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => screenBuilder(context)));
      },
    );
  }
}
