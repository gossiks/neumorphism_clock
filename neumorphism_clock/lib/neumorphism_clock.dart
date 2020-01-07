// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/neumorphism_helper/clipper.dart';
import 'package:digital_clock/neumorphism_helper/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
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

/// A basic digital clock.
///
/// You can do better than this!
class NeuomorphismClock extends StatefulWidget {
  const NeuomorphismClock(this.model);

  final ClockModel model;

  @override
  _NeuomorphismClockState createState() => _NeuomorphismClockState();
}

class _NeuomorphismClockState extends State<NeuomorphismClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(NeuomorphismClock oldWidget) {
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
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) - Duration(seconds: _dateTime.second) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
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

    return FutureBuilder<List<Path>>(
      future: rootBundle.load("asset/Roboto-Bold.ttf").then((ByteData data) {
        // Create a font reader
        var reader = PMFontReader();

        // Parse the font
        var myFont = reader.parseTTFAsset(data);

        // Generate the complete path for a specific character
        List<Path> numberPathList = List.generate(10, (index) => 48 + index)
            .asMap()
            .map((index, value) => MapEntry(index, generatePathForCharacter(myFont, value)))
            .values
            .toList();
        return numberPathList;
      }).catchError(print),
      builder: (BuildContext context, AsyncSnapshot<List<Path>> snapshot) {
        if (snapshot.hasData) {
          return ClockPad(
            snapshot.data.toList(),
          );
        } else {
          return Container();
        }
      },
    );
//    return Container(
//      color: colors[_Element.background],
//      child: Center(
//        child: DefaultTextStyle(
//          style: defaultStyle,
//          child: Stack(
//            children: <Widget>[
//              Positioned(left: offset, top: 0, child: Text(hour)),
//              Positioned(right: offset, bottom: offset, child: Text(minute)),
//            ],
//          ),
//        ),
//      ),
//    );
  }
}

Path generatePathForCharacter(PMFont myFont, int character) =>
    myFont.generatePathForCharacter(character); // TODO move to hepler

class ClockPad extends StatelessWidget {
  List<Path> symbolList;

  ClockPad(this.symbolList);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          clockCell(child: buildNeumorphismSymbol(8, context)),
          clockCell(child: buildNeumorphismSymbol(0, context)),
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
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Neumorphism(
                    clipper: CircleClipper(),
                    child: Container(
                      height: 30,
                      width: 30,
                      color: NeumorphismTheme.of(context).surfaceColor,
                    ),
                  ),
                ),
              )
            ],
          )),
          clockCell(child: buildNeumorphismSymbol(3, context)),
          clockCell(child: buildNeumorphismSymbol(4, context)),
        ],
      ),
    );
  }

  Neumorphism buildNeumorphismSymbol(int symbolIndex, BuildContext context) {
    return Neumorphism(
      clipper: FontSymbolClipper(symbolList[symbolIndex]),
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          color: NeumorphismTheme.of(context).surfaceColor,
        ),
      ),
    );
  }

  Widget clockCell({Widget child, int flex = 2}) => Flexible(flex: flex, child: child);
}
