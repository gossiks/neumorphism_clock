library neumorphism;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Neumorphism extends StatelessWidget {
  final CustomClipper<Path> clipper;
  final Widget child;
  final double shift; // shift of target child, pixel
  final Paint shadowBottomPaint, shadowTopPaint;

  Neumorphism(
      {Key key,
      this.clipper = const NeumorphismEmptyClipper(),
      this.child,
      this.shift,
      this.shadowBottomPaint,
      this.shadowTopPaint})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: NeumorphismPainter(
        shift: shift,
        clipper: clipper,
        shadowBottomPaint: shadowBottomPaint,
        shadowTopPaint: shadowTopPaint,
      ),
      child: ClipPath(
        child: child,
        clipper: clipper,
      ),
    );
  }
}

class NeumorphismEmptyClipper extends CustomClipper<Path> {
  const NeumorphismEmptyClipper();

  @override
  getClip(Size size) => Path()..addRect(Rect.fromLTRB(0.0, 0.0, size.width, size.height));

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}

class NeumorphismPainter extends CustomPainter {
  final CustomClipper<Path> clipper;
  final double shift;
  Paint shadowBottomPaint, shadowTopPaint;

  NeumorphismPainter(
      {this.clipper = const NeumorphismEmptyClipper(), this.shift, this.shadowBottomPaint, this.shadowTopPaint});

  @override
  void paint(Canvas canvas, Size size) {
    if (shift > 0) {
      Path clipPathBottom = clipper.getClip(size).shift(Offset(shift, shift));
      Path clipPathTop = clipper.getClip(size).shift(Offset(-shift, -shift));
      canvas.drawPath(clipPathTop, shadowTopPaint);
      canvas.drawPath(clipPathBottom, shadowBottomPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is NeumorphismPainter && oldDelegate.shift == shift && oldDelegate.clipper == clipper) {
      return false;
    }
    return true;
  }
}
