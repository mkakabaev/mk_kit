import 'package:flutter/material.dart';
import 'package:mk_kit/mk_kit.dart';

class MDIDemo extends StatefulWidget {
    const MDIDemo({
        super.key,
    });

    @override
    State createState() => _MDIDemoState();
}

class _MDIDemoState extends State<MDIDemo> {
    late final MDIController _controller;

    @override
    void initState() {
        super.initState();

        _controller = const MDIController();
    }

    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('MDI Demo'),
            ),
            body: Container()
            //MDI(
            //  controller: _controller,
            //),
            );
    }
}
