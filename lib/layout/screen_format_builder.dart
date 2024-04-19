import 'package:flutter/widgets.dart';

class ScreenFormatBuilder extends StatelessWidget {
  const ScreenFormatBuilder(
      {super.key, required this.phoneLayout, required this.tabletLayout});

  final Widget Function() phoneLayout;
  final Widget Function() tabletLayout;

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var isTablet = mediaQuery.size.width > 900 &&
        mediaQuery.size.width > mediaQuery.size.height;

    return isTablet ? tabletLayout() : phoneLayout();
  }
}
