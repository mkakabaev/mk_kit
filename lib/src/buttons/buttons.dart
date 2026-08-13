import 'package:flutter/widgets.dart';

class MKButton extends StatelessWidget {
  final MKButtonConfig config;
  final bool isEnabled;
  final bool showProgress;
  final bool isDisabledOnProgress;
  final VoidCallback onTap;

  const MKButton({
    super.key,
    required this.config,
    required this.onTap,
    bool? isEnabled,
    bool? showProgress,
    bool? isDisabledOnProgress,
  }) : isEnabled = isEnabled ?? true,
       showProgress = showProgress ?? false,
       isDisabledOnProgress = isDisabledOnProgress ?? true;

  @override
  Widget build(BuildContext context) {
    return Text('MKButton');
  }
}

abstract class MKButtonConfig {}


// abstract class MKButtonLayoutConfig {
//   EdgeInsets padding;
//   final EdgeInsets margin;
//   final EdgeInsets border;
//   final EdgeInsets iconPadding;
//   final EdgeInsets textPadding;
//   final EdgeInsets contentPadding;
// }
