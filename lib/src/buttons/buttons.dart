import 'package:flutter/widgets.dart';

class const MKButton({
  super.key,
  required final MKButtonConfig config,
  required final VoidCallback onTap,
  bool? isEnabled,
  bool? showProgress,
  bool? isDisabledOnProgress,
}) extends StatelessWidget {
  final bool isEnabled;
  final bool showProgress;
  final bool isDisabledOnProgress;
  this
    : isEnabled = isEnabled ?? true,
      showProgress = showProgress ?? false,
      isDisabledOnProgress = isDisabledOnProgress ?? true;

  @override
  Widget build(BuildContext context) {
    return const Text('MKButton');
  }
}

abstract class MKButtonConfig();
