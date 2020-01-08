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
  StreamController<ClockCondition> clockConditionStreamController;

  @override
  void initState() {
    super.initState();
    clockConditionStreamController = StreamController();
    widget.model.addListener(_updateModel);
    _updateTime();
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
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    _dateTime = DateTime.now();
    // Update once per minute. If you want to update every second, use the
    // following code.
//    _timer = Timer(
//      Duration(minutes: 1) - Duration(seconds: _dateTime.second) - Duration(milliseconds: _dateTime.millisecond),
//      _updateTime,
//    );
    final hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);

    clockConditionStreamController.add(ClockCondition(
      widget.digitPath[(_dateTime.second - _dateTime.second % 10) ~/ 10],
      widget.digitPath[_dateTime.second % 10],
      widget.digitPath[(_dateTime.second - _dateTime.second % 10) ~/ 10],
      widget.digitPath[_dateTime.second % 10],
    ));
    // Update once per second, but make sure to do it at the beginning of each
    // new second, so that the clock is accurate.
    _timer = Timer(
      Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      _updateTime,
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

    return ClockPad(clockConditionStreamController.stream);
  }
}

Path generatePathForCharacter(PMFont myFont, int character) =>
    myFont.generatePathForCharacter(character); // TODO move to hepler

class ClockPad extends StatefulWidget {
  Stream<ClockCondition> clockConditionStream;

  ClockPad(this.clockConditionStream);

  @override
  _ClockPadState createState() => _ClockPadState();
}

class _ClockPadState extends State<ClockPad> with TickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 10));
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ClockCondition>(
        stream: widget.clockConditionStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  clockCell(
                      child: AnimatedNeumorphismUp(
                          animationController: animationController,
                          clipPath: snapshot.data.firstSymbol,
                          elementElevation: 11)),
                  clockCell(
                      child: AnimatedNeumorphismUp(
                          animationController: animationController,
                          clipPath: snapshot.data.secondSymbol,
                          elementElevation: 11)),
                  clockCell(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Neumorphism(
                            clipper: CircleClipper(),
                            child: Container(
                              height: 30,
                              width: 30,
                              color: NeumorphismTheme.of(context).surfaceColor,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Neumorphism(
                          clipper: CircleClipper(),
                          child: Container(
                            height: 30,
                            width: 30,
                            color: NeumorphismTheme.of(context).surfaceColor,
                          ),
                        ),
                      )
                    ],
                  )),
                  clockCell(
                      child: AnimatedNeumorphismUp(
                          animationController: animationController,
                          clipPath: snapshot.data.thirdSymbol,
                          elementElevation: 11)),
                  clockCell(
                      child: AnimatedNeumorphismUp(
                          animationController: animationController,
                          clipPath: snapshot.data.forthSymbol,
                          elementElevation: 11)),
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Widget clockCell({Widget child, int flex = 2}) => Flexible(flex: flex, child: child);
}

Neumorphism buildNeumorphismSymbol({Path clipPath, final double elementElevation = 5, BuildContext context}) {
  return Neumorphism(
    elementElevation: elementElevation,
    clipper: FontSymbolClipper(clipPath),
    child: FractionallySizedBox(
      heightFactor: 0.5,
      child: Container(
        color: NeumorphismTheme.of(context).surfaceColor,
      ),
    ),
  );
}

class AnimatedNeumorphismUp extends StatefulWidget {
  final Path clipPath;
  final double elementElevation;

  final AnimationController animationController;

  AnimatedNeumorphismUp(
      {Key key, @required this.animationController, @required this.clipPath, this.elementElevation = 10})
      : super(key: key = GlobalKey());

  @override
  _AnimatedNeumorphismUpState createState() => _AnimatedNeumorphismUpState();
}

class _AnimatedNeumorphismUpState extends State<AnimatedNeumorphismUp> with SingleTickerProviderStateMixin {
  Animation<double> ascendAnimation;

    AnimationController s;
  @override
  void initState() {
    super.initState();
    s = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    ascendAnimation = Tween<double>(begin: 0, end: widget.elementElevation).animate(s);
    s.forward();

  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ascendAnimation,
      builder: (BuildContext context, Widget child) {
        print(ascendAnimation.value);
        return buildNeumorphismSymbol(
          elementElevation: ascendAnimation.value,
          clipPath: widget.clipPath,
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
