// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:neumorphism_clock/neumorphism_helper/clipper.dart';
import 'package:neumorphism_clock/neumorphism_helper/data/clock_data.dart';
import 'package:neumorphism_clock/neumorphism_helper/theme.dart';
import 'package:neumorphism_clock/neumorphism_helper/widget/neumorphism_animated.dart';
import 'package:neumorphism_clock/neumorphism_helper/widget/widget_data_converter.dart';
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
    Widget clockWidget = ClockPad(widget.digitPath, widget.model.is24HourFormat);
    return Theme.of(context).brightness == Brightness.light
        ? NeumorphismTheme.light(child: clockWidget)
        : NeumorphismTheme.dark(child: clockWidget);
  }
}

class ClockPad extends StatefulWidget {
  final List<Path> digitPath;
  final bool is24hourFormat;

  ClockPad(this.digitPath, this.is24hourFormat);

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
                child: buildAnimatedFontNeumorphism(context, currentTime.firstSymbol, previousTime.firstSymbol),
              )),
              clockCell(
                  child: buildAnimatedFontNeumorphism(context, currentTime.secondSymbol, previousTime.secondSymbol)),
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
                                  elementElevation: NeumorphismTheme.of(context).elementElevation,
                                  clipper: CircleClipper(),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: AnimatedNeumorphism(
                                  animationDuration: const Duration(milliseconds: 700),
                                  elementElevation: NeumorphismTheme.of(context).elementElevation,
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
                child: buildAnimatedFontNeumorphism(context, currentTime.thirdSymbol, previousTime.thirdSymbol),
              )),
              clockCell(
                  child: buildAnimatedFontNeumorphism(context, currentTime.forthSymbol, previousTime.forthSymbol)),
            ],
          ),
        );
      }),
    );
  }

  ClockCondition extractClockTimeCondition() =>
      extractClockCondition(widget.digitPath, DateTime.now(), widget.is24hourFormat);

  SecondsCondition extractSecondsTimeCondition() => extractSecondsCondition(widget.digitPath, DateTime.now());

  Widget clockCell({Widget child, int flex = 2}) => Flexible(flex: flex, child: child);
}
