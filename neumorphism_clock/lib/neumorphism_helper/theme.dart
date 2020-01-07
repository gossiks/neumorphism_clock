import 'package:flutter/cupertino.dart';

class NeumorphismTheme extends InheritedWidget {
  final Color surfaceColor = Color(0xffefeeee);

  NeumorphismTheme({
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false; // TODO night mode
  }

  static NeumorphismTheme of(BuildContext context) => context.dependOnInheritedWidgetOfExactType();
}
