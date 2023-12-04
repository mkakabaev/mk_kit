// import 'package:flutter/material.dart';

import 'window.dart';
import 'window_state.dart';

sealed class MDIControllerCommand {}

// ------------------------------------------------------------------------------------------------

class MDIController {
    // extends ValueNotifier<CValue> {
//   MDIController() : super(CValue());

    final List<MDIWindowState> _windows = [];

//   CValue get cValue => value;

//   set cValue(CValue newValue) {
//     value = newValue;
//   }

    MDIController({List<MDIWindow>? initialWindows}) {
        if (initialWindows != null) {
            for (final window in initialWindows) {
                // addWindows(window);
            }
        }
    }

    void dispose() {}
}

/*
class MDI extends StatefulWidget {
  final MDIController controller;

  const MDI({
    super.key,
    required this.controller,
  });

  @override
  State createState() => _MDIState();
}

class _MDIState extends State<MDI> {
  CValue? _cValue;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
  }

  @override
  void dispose() {
    _detachController(widget.controller);
    super.dispose();
  }

  @override
  void didUpdateWidget(MDI oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _detachController(oldWidget.controller);
      _attachController(widget.controller);
    }
  }

  void _detachController(MDIController controller) {
    // controller.removeListener(_didChangeController);
  }

  void _attachController(MDIController controller) {
    // controller.addListener(_didChangeController);
    _updateFromController();
  }

  void _updateFromController() {
    // _cValue = widget.controller?.cValue;
  }

  void _didChangeController() {
    setState(() {
      _updateFromController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: <OverlayEntry>[
        OverlayEntry(
          builder: (BuildContext context) {
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 1.0,
                ),
              ),
              child: Text('MDI' * 100),
            );
          },
        ),
        OverlayEntry(
          builder: (BuildContext context) {
            return Positioned(
              left: 10,
              top: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1.0,
                  ),
                ),
                child: Text('MDI' * 100),
              ),
            );
          },
        ),
      ],
    );
  }
}

*/
