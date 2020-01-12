import 'package:flutter/rendering.dart';

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
