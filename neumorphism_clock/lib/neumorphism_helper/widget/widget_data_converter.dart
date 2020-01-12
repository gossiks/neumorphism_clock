import 'package:flutter/rendering.dart';
import 'package:neumorphism_clock/neumorphism_helper/data/clock_data.dart';

ClockCondition extractClockCondition(List<Path> pathList, DateTime dateTime, bool is24HourFormat) {
  int hour = is24HourFormat ? dateTime.hour : dateTime.hour % 12;
  return ClockCondition(
    pathList[(hour - hour % 10) ~/ 10],
    pathList[hour % 10],
    pathList[(dateTime.minute - dateTime.minute % 10) ~/ 10],
    pathList[dateTime.minute % 10],
  );
}

SecondsCondition extractSecondsCondition(List<Path> pathList, DateTime dateTime) =>
    SecondsCondition(pathList[(dateTime.second - dateTime.second % 10) ~/ 10], pathList[dateTime.second % 10]);
