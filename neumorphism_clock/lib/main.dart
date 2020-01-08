// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:digital_clock/neumorphism_clock.dart';
import 'package:digital_clock/neumorphism_helper/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';

void main() {
  // A temporary measure until Platform supports web and TargetPlatform supports
  // macOS.
  if (!kIsWeb && Platform.isMacOS) {
    // TODO(gspencergoog): Update this when TargetPlatform includes macOS.
    // https://github.com/flutter/flutter/issues/31366
    // See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override.
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  // This creates a clock that enables you to customize it.
  //
  // The [ClockCustomizer] takes in a [ClockBuilder] that consists of:
  //  - A clock widget (in this case, [DigitalClock])
  //  - A model (provided to you by [ClockModel])
  // For more information, see the flutter_clock_helper package.
  //
  // Your job is to edit [DigitalClock], or replace it with your
  // own clock widget. (Look in neumorphism_clock.dart for more details!)
  runApp(ClockCustomizer((ClockModel model) => NeumorphismTheme(
          child: FutureBuilder<List<Path>>(
        future: rootBundle.load("asset/Roboto-Bold.ttf").then((ByteData data) {
          List<Path> numberPathList = List.generate(10, (index) => 48 + index)
              .asMap()
              .map((index, value) =>
                  MapEntry(index, generatePathForCharacter(PMFontReader().parseTTFAsset(data), value)))
              .values
              .toList();
          return numberPathList;
        }).catchError(print),
        builder: (BuildContext context, AsyncSnapshot<List<Path>> snapshot) {
          if (snapshot.hasData) {
            return NeumorphismClock(model, snapshot.data);
          } else {
            return Container();
          }
        },
      ))));
}
