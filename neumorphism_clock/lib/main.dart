// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:neumorphism_clock/neumorphism_clock.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';

import 'neumorphism_clock.dart';

void main() {
  if (!kIsWeb && Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  runApp(ClockCustomizer((ClockModel model) => FutureBuilder<List<Path>>(
        future: rootBundle
            .load("asset/Roboto-Bold.ttf")
            .then((ByteData data) => List.generate(10, (index) => 48 + index)
                .asMap()
                .map((index, value) =>
                    MapEntry(index, PMFontReader().parseTTFAsset(data).generatePathForCharacter(value)))
                .values
                .toList())
            .catchError(print),
        builder: (BuildContext context, AsyncSnapshot<List<Path>> snapshot) {
          if (snapshot.hasData) {
            return NeumorphismClock(model, snapshot.data);
          } else {
            return Container();
          }
        },
      )));
}
