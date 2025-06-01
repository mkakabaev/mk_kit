import 'package:flutter/material.dart';

import 'package:example/column_demo/column_demo.dart';

void main() {
  runApp(const MKKitExampleApp());
}

class MKKitExampleApp extends StatelessWidget {
  const MKKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true);
    theme = theme.copyWith(appBarTheme: AppBarTheme(backgroundColor: theme.colorScheme.inversePrimary));

    return MaterialApp(title: 'Flutter Demo', theme: theme, home: const _HomePage());
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('mk-kit demo')),
      body: ListView(
        children: [_ListItem(title: 'MKColumn', screenBuilder: (_) => const ColumnDemo())],
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
