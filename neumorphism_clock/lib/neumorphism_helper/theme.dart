import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NeumorphismTheme extends InheritedWidget {
  final Color surfaceColor;
  final Paint shadowBottomPaint;
  final Paint shadowTopPaint;

  NeumorphismTheme({
    this.shadowBottomPaint,
    this.shadowTopPaint,
    this.surfaceColor,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  NeumorphismTheme.light({
    Key key,
    @required Widget child,
  }) : this(
            surfaceColor: const Color(0xffefeeee),
            shadowBottomPaint: Paint()
              ..color = Color(0xffd1cdc7).withAlpha(128)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, Shadow.convertRadiusToSigma(0)),
            shadowTopPaint: Paint()
              ..color = Colors.white.withAlpha(128)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, Shadow.convertRadiusToSigma(0)),
            key: key,
            child: child);

  NeumorphismTheme.dark({
    Key key,
    @required Widget child,
  }) : this(
            surfaceColor: const Color(0xff212121),
            shadowBottomPaint: Paint()..color = Color(0xff3A3E41)
                .withAlpha(128),
            shadowTopPaint: Paint()..color = Color(0xff9B9E9F)
                .withAlpha(128),
            key: key,
            child: child);

//  shadowBottomPaint = shadowBottomPaint ?? Paint()
//  ..color = Color(0xffd1cdc7).withAlpha(128)
//  ..maskFilter = MaskFilter.blur(BlurStyle.normal, Shadow.convertRadiusToSigma(0));
//  shadowTopPaint = shadowTopPaint = shadowTopPaint ?? Paint()
//  ..color = Colors.white.withAlpha(128)
//  ..maskFilter = MaskFilter.blur(BlurStyle.normal, Shadow.convertRadiusToSigma(0));

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true; // TODO night mode
  }

  static NeumorphismTheme of(BuildContext context) => context.dependOnInheritedWidgetOfExactType();
}
