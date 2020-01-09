// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/neumorphism_helper/clipper.dart';
import 'package:digital_clock/neumorphism_helper/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:neumorphism/neumorphism_lib.dart';
import 'package:rxdart/transformers.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.redAccent,
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Colors.red,
};

class NeumorphismClock extends StatefulWidget {
  final ClockModel model;
  final List<Path> digitPath;

  const NeumorphismClock(this.model, this.digitPath);

  @override
  _NeumorphismClockState createState() => _NeumorphismClockState();
}

class _NeumorphismClockState extends State<NeumorphismClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  Timer _timerSeconds;
  StreamController<ClockCondition> clockConditionStreamController;
  Stream<ClockCondition> clockConditionStream;

  StreamController<SecondsCondition> secondsSecondsConditionController;
  Stream<SecondsCondition> secondsConditionStream;

  @override
  void initState() {
    super.initState();
    clockConditionStreamController = StreamController();
    clockConditionStream = clockConditionStreamController.stream.asBroadcastStream();
    secondsSecondsConditionController = StreamController();
    secondsConditionStream = secondsSecondsConditionController.stream.asBroadcastStream();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateSeconds();
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
    _timer?.cancel();
    _timerSeconds?.cancel();
    clockConditionStreamController.close();
    secondsSecondsConditionController.close();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    _dateTime = DateTime.now();
    _timer = Timer(
      Duration(minutes: 1) - Duration(seconds: _dateTime.second) - Duration(milliseconds: _dateTime.millisecond),
      _updateTime,
    );
    clockConditionStreamController.add(extractClockCondition(widget.digitPath, _dateTime));
  }

  void _updateSeconds() {
    var dateTime = DateTime.now();
    secondsSecondsConditionController.add(extractSecondsCondition(widget.digitPath, dateTime));
    _timerSeconds = Timer(
      Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      _updateSeconds,
    );
  }

  SecondsCondition extractSecondsCondition(List<Path> pathList, DateTime dateTime) {
    return SecondsCondition(pathList[(dateTime.second - dateTime.second % 10) ~/ 10], pathList[dateTime.second % 10]);
  }

  ClockCondition extractClockCondition(List<Path> pathList, DateTime dateTime) {
    return ClockCondition(
      pathList[(dateTime.hour - dateTime.hour % 10) ~/ 10],
      pathList[dateTime.hour % 10],
      pathList[(dateTime.minute - dateTime.minute % 10) ~/ 10],
      pathList[dateTime.minute % 10],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light ? _lightTheme : _darkTheme;
    final hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);

    final fontSize = MediaQuery.of(context).size.width / 3.5;
    final offset = -fontSize / 7;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'PressStart2P',
      fontSize: fontSize,
      shadows: [
        Shadow(
          blurRadius: 0,
          color: colors[_Element.shadow],
          offset: Offset(10, 0),
        ),
      ],
    );
    ClockCondition initialClockCondition = extractClockCondition(widget.digitPath, _dateTime);
    SecondsCondition initialSecondsCondition = extractSecondsCondition(widget.digitPath, _dateTime);
    return Container(
        color: NeumorphismTheme.of(context).surfaceColor,
        child: ClockPad(
            clockConditionStream.scan(
                (List<ClockCondition> accumulated, ClockCondition value, int index) => [accumulated[1], value],
                [initialClockCondition, initialClockCondition]),
            secondsConditionStream.scan(
                (List<SecondsCondition> accumulated, SecondsCondition value, int index) => [accumulated[1], value],
                [initialSecondsCondition, initialSecondsCondition])));
  }

  List<T> accumulateTime<T>(List<T> accumulated, T value, int index) => [accumulated[1], value];
}

Path generatePathForCharacter(PMFont myFont, int character) =>
    myFont.generatePathForCharacter(character); // TODO move to hepler

class ClockPad extends StatefulWidget {
  final Stream<List<ClockCondition>> clockConditionStream;
  final Stream<List<SecondsCondition>> secondsConditionStream;

  ClockPad(this.clockConditionStream, this.secondsConditionStream);

  @override
  _ClockPadState createState() => _ClockPadState();
}

class _ClockPadState extends State<ClockPad> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClockCondition>>(
        stream: widget.clockConditionStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    flex: 10,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        clockCell(
                            child: buildAnimatedFontNeumorphism(
                                snapshot.data[1].firstSymbol, snapshot.data[0].firstSymbol)),
                        clockCell(
                            child: buildAnimatedFontNeumorphism(
                                snapshot.data[1].secondSymbol, snapshot.data[0].secondSymbol)),
                        clockCell(
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
                                    elementElevation: 3,
                                    clipper: CircleClipper(),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: AnimatedNeumorphism(
                                    elementElevation: 3,
                                    clipper: CircleClipper(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                        clockCell(
                            child: buildAnimatedFontNeumorphism(
                                snapshot.data[1].thirdSymbol, snapshot.data[0].thirdSymbol)),
                        clockCell(
                            child: buildAnimatedFontNeumorphism(
                                snapshot.data[1].forthSymbol, snapshot.data[0].forthSymbol)),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: 0.4,
                        child: StreamBuilder<List<SecondsCondition>>(
                            stream: widget.secondsConditionStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    clockCell(
                                        child: buildAnimatedFontNeumorphism(
                                            snapshot.data[1].firstSymbol, snapshot.data[0].firstSymbol)),
                                    clockCell(
                                        child: buildAnimatedFontNeumorphism(
                                            snapshot.data[1].secondSymbol, snapshot.data[0].secondSymbol)),
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            }),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Widget buildAnimatedFontNeumorphism(Path symbolTo, Path symbolFrom,
      {CustomClipper<Path> customClipper, double height}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: AnimatedNeumorphism(
        clipPathTo: symbolTo,
        clipPathFrom: symbolFrom,
        elementElevation: 3,
        clipper: customClipper,
        height: height,
      ),
    );
  }

  Widget clockCell({Widget child, int flex = 2}) => Flexible(flex: flex, child: child);
}

Widget buildNeumorphismSymbol(
    {Path clipPath, final double elementElevation, CustomClipper clipper, double height = 100, BuildContext context}) {
  return Container(
    child: Neumorphism(
      shift: elementElevation ?? 5,
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

  AnimatedNeumorphism(
      {Key key,
      @required this.clipPathTo,
      @required this.clipPathFrom,
      this.elementElevation = 10,
      this.height,
      this.clipper})
      : super(key: key = GlobalKey());

  @override
  _AnimatedNeumorphismState createState() => _AnimatedNeumorphismState();
}

class _AnimatedNeumorphismState extends State<AnimatedNeumorphism> with SingleTickerProviderStateMixin {
  Animation<double> ascendAnimation, descendAnimation;

  AnimationController s;

  @override
  void initState() {
    super.initState();
    s = AnimationController(vsync: this, duration: Duration(milliseconds: 4000));
    ascendAnimation =
        Tween<double>(begin: widget.elementElevation, end: 0).animate(CurvedAnimation(parent: s, curve: Curves.linear));
    startAnimation();
  }

  Future startAnimation() async {
    await s.forward();
    await s.reverse();
  }

  @override
  void dispose() {
    s.dispose();
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
}

class SecondsCondition {
  final Path firstSymbol, secondSymbol;

  SecondsCondition(this.firstSymbol, this.secondSymbol);
}
