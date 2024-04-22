import 'package:flutter/widgets.dart';

/// Changes displayed content based on if the device is in phone or tablet mode
class ScreenFormatBuilder extends StatelessWidget {
  const ScreenFormatBuilder(
      {super.key, required this.phoneLayout, required this.tabletLayout});

  /// Content to display if the device is in phone mode
  final Widget Function() phoneLayout;

  /// Content to display if the device is in tablet mode
  final Widget Function() tabletLayout;

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var isTablet = mediaQuery.size.width > 900 &&
        mediaQuery.size.width > mediaQuery.size.height;

    return isTablet ? tabletLayout() : phoneLayout();
  }
}
