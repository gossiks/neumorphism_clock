// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:digital_clock/neumorphism_helper/clipper.dart';
import 'package:digital_clock/neumorphism_helper/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:neumorphism/neumorphism_lib.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';
import 'package:timer_builder/timer_builder.dart';

class NeumorphismClock extends StatefulWidget {
  final ClockModel model;
  final List<Path> digitPath;

  const NeumorphismClock(this.model, this.digitPath);

  @override
  _NeumorphismClockState createState() => _NeumorphismClockState();
}

class _NeumorphismClockState extends State<NeumorphismClock> {
  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateModel();
  }

  @override
  void didUpdateWidget(NeumorphismClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool lightTheme = Theme.of(context).brightness == Brightness.light;
    Widget clockWidget = ClockPad(widget.digitPath, widget.model.is24HourFormat, lightTheme);
    return lightTheme ? NeumorphismTheme.light(child: clockWidget) : NeumorphismTheme.dark(child: clockWidget);
  }
}

SecondsCondition extractSecondsCondition(List<Path> pathList, DateTime dateTime) {
  print(dateTime.second.toString() +
      " - " +
      ((dateTime.second - dateTime.second % 10) ~/ 10).toString() +
      " - " +
      (dateTime.second % 10).toString());
  return SecondsCondition(pathList[(dateTime.second - dateTime.second % 10) ~/ 10], pathList[dateTime.second % 10]);
}

ClockCondition extractClockCondition(List<Path> pathList, DateTime dateTime, bool is24HourFormat) {
//    final hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
//    final minute = DateFormat('mm').format(_dateTime);23 % 12
  int hour = is24HourFormat ? dateTime.hour : dateTime.hour % 12;
  return ClockCondition(
    pathList[(hour - hour % 10) ~/ 10],
    pathList[hour % 10],
    pathList[(dateTime.minute - dateTime.minute % 10) ~/ 10],
    pathList[dateTime.minute % 10],
  );
}

Path generatePathForCharacter(PMFont myFont, int character) =>
    myFont.generatePathForCharacter(character); // TODO move to hepler

class ClockPad extends StatefulWidget {
  final List<Path> digitPath;
  final bool is24hourFormat;
  final bool lightTheme;

  ClockPad(this.digitPath, this.is24hourFormat, this.lightTheme);

  @override
  _ClockPadState createState() => _ClockPadState();
}

class _ClockPadState extends State<ClockPad> with TickerProviderStateMixin {
  ClockCondition cachedClockCondition;
  SecondsCondition cachedSecondsClockCondition;

  @override
  void initState() {
    super.initState();
    cachedClockCondition = extractClockTimeCondition();
    cachedSecondsClockCondition = extractSecondsTimeCondition();
  }

  ClockCondition extractClockTimeCondition() =>
      extractClockCondition(widget.digitPath, DateTime.now(), widget.is24hourFormat);

  SecondsCondition extractSecondsTimeCondition() => extractSecondsCondition(widget.digitPath, DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NeumorphismTheme.of(context).surfaceColor,
      child: TimerBuilder.periodic(Duration(minutes: 1), builder: (context) {
        var currentTime = extractClockTimeCondition();
        var previousTime = cachedClockCondition;
        cachedClockCondition = currentTime;
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              clockCell(
                  child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: buildAnimatedFontNeumorphism(currentTime.firstSymbol, previousTime.firstSymbol,
                    lightTheme: widget.lightTheme),
              )),
              clockCell(
                  child: buildAnimatedFontNeumorphism(currentTime.secondSymbol, previousTime.secondSymbol,
                      lightTheme: widget.lightTheme)),
              TimerBuilder.periodic(const Duration(seconds: 2),
                  builder: (context) => clockCell(
                          child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0, top: 40.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: AnimatedNeumorphism(
                                  animationDuration: const Duration(milliseconds: 700),
                                  elementElevation: widget.lightTheme ? 3 : 1,
                                  clipper: CircleClipper(),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: AnimatedNeumorphism(
                                  animationDuration: const Duration(milliseconds: 700),
                                  elementElevation: widget.lightTheme ? 3 : 1,
                                  clipper: CircleClipper(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))),
              clockCell(
                  child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: buildAnimatedFontNeumorphism(currentTime.thirdSymbol, previousTime.thirdSymbol,
                    lightTheme: widget.lightTheme),
              )),
              clockCell(
                  child: buildAnimatedFontNeumorphism(currentTime.forthSymbol, previousTime.forthSymbol,
                      lightTheme: widget.lightTheme)),
            ],
          ),
        );
      }),
    );
  }

  Widget buildAnimatedFontNeumorphism(Path symbolTo, Path symbolFrom,
      {CustomClipper<Path> customClipper,
      double height,
      Duration animationDuration = const Duration(milliseconds: 1500),
      bool lightTheme}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: AnimatedNeumorphism(
        clipPathTo: symbolTo,
        clipPathFrom: symbolFrom,
        elementElevation: lightTheme ? 3 : 0.5,
        clipper: customClipper,
        height: height,
        animationDuration: animationDuration,
      ),
    );
  }

  Widget clockCell({Widget child, int flex = 2}) => Flexible(flex: flex, child: child);
}

Widget buildNeumorphismSymbol(
    {Path clipPath, final double elementElevation, CustomClipper clipper, double height = 100, BuildContext context}) {
  return Container(
    child: Neumorphism(
      shadowBottomPaint: NeumorphismTheme.of(context).shadowBottomPaint,
      shadowTopPaint: NeumorphismTheme.of(context).shadowTopPaint,
      shift: elementElevation ?? 3,
      clipper: clipper ?? FontSymbolClipper(clipPath),
      child: Container(
        height: height,
        color: NeumorphismTheme.of(context).surfaceColor,
      ),
    ),
  );
}

class AnimatedNeumorphism extends StatefulWidget {
  final Path clipPathTo, clipPathFrom;
  final double elementElevation;
  final CustomClipper<Path> clipper;
  final double height;
  final Duration animationDuration;

  AnimatedNeumorphism(
      {Key key,
      @required this.clipPathTo,
      @required this.clipPathFrom,
      this.elementElevation = 10,
      this.height,
      this.clipper,
      this.animationDuration = const Duration(milliseconds: 4000)})
      : super(key: key = GlobalKey());

  @override
  _AnimatedNeumorphismState createState() => _AnimatedNeumorphismState();
}

class _AnimatedNeumorphismState extends State<AnimatedNeumorphism> with SingleTickerProviderStateMixin {
  Animation<double> ascendAnimation, descendAnimation;

  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: widget.animationDuration);
    ascendAnimation = Tween<double>(begin: widget.elementElevation, end: 0)
        .animate(CurvedAnimation(parent: animationController, curve: Curves.linear));
    startAnimation();
  }

  startAnimation() {
    animationController.forward().then((v) {
      animationController.reverse();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ascendAnimation,
      builder: (BuildContext context, Widget child) {
        return buildNeumorphismSymbol(
          elementElevation: ascendAnimation.value,
          clipPath: ascendAnimation.status == AnimationStatus.forward
              ? (widget.clipPathFrom ?? widget.clipPathTo)
              : widget.clipPathTo,
          clipper: widget.clipper,
          height: widget.height,
          context: context,
        );
      },
    );
  }
}

class ClockCondition {
  final Path firstSymbol, secondSymbol, thirdSymbol, forthSymbol;

  ClockCondition(this.firstSymbol, this.secondSymbol, this.thirdSymbol, this.forthSymbol);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClockCondition &&
          runtimeType == other.runtimeType &&
          firstSymbol == other.firstSymbol &&
          secondSymbol == other.secondSymbol &&
          thirdSymbol == other.thirdSymbol &&
          forthSymbol == other.forthSymbol;

  @override
  int get hashCode => firstSymbol.hashCode ^ secondSymbol.hashCode ^ thirdSymbol.hashCode ^ forthSymbol.hashCode;
}

class SecondsCondition {
  final Path firstSymbol, secondSymbol;

  SecondsCondition(this.firstSymbol, this.secondSymbol);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecondsCondition &&
          runtimeType == other.runtimeType &&
          firstSymbol == other.firstSymbol &&
          secondSymbol == other.secondSymbol;

  @override
  int get hashCode => firstSymbol.hashCode ^ secondSymbol.hashCode;
}
