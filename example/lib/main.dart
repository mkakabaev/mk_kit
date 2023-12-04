import 'package:example/column_demo.dart';
import 'package:example/mdi_demo.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );

    theme = theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
    );

    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('mk-kit demo'),
      ),
      body: ListView(
        children: [
          MyListTile(title: 'MKColumn', screenBuilder: (_) => const ColumnDemo()),
          MyListTile(title: 'MDI', screenBuilder: (_) => const MDIDemo()),
        ],
      ),
    );
  }
}

class MyListTile extends StatelessWidget {
  const MyListTile({
    Key? key,
    required this.title,
    required this.screenBuilder,
  }) : super(key: key);

  final String title;
  final WidgetBuilder screenBuilder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<dynamic>(
            builder: (context) => screenBuilder(context),
          ),
        );
      },
    );
  }
}
