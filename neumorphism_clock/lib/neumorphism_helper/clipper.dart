import 'package:flutter/rendering.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';

class FontSymbolClipper extends CustomClipper<Path> {
  Path clipPath;

  FontSymbolClipper(this.clipPath);

  @override
  Path getClip(Size size) {
    double shrinkHeight = 0.9 * size.width / clipPath.getBounds().width;
    return PMTransform.moveAndScale(clipPath, 0.0, size.height, shrinkHeight, shrinkHeight);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper is FontSymbolClipper && oldClipper.clipPath == clipPath) {
      return false;
    } else {
      return true;
    }
  }
}

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(new Rect.fromCircle(center: new Offset(size.width / 2, size.height / 2), radius: size.width * 0.5));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
