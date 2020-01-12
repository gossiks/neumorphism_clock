import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ImagePathClipper extends CustomClipper<Path> {
  List<Offset> points; // normalized coordinates to 1. Always <=1

  ImagePathClipper(List<Offset> points) {
//    print(points.toString());
    if (points == null) {
      this.points = [];
    } else {
      this.points = points.where((p) => p != null).toList();
    }
  }

  @override
  Path getClip(Size size) {
    final path = Path();

    if (points.length > 2) {
      path.moveTo(0.0, points[0].dy);
      path.moveTo(points[0].dx * size.width, points[0].dy * size.height);
      points.sublist(1).forEach((Offset point) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      });
      path.lineTo(size.width, points.last.dy * size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(0.0, size.height);
      path.lineTo(0.0, points[0].dy * size.height);
    }
    path.close();
//    path.addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height));
//    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(ImagePathClipper oldClipper) =>
      true; //TODO reclip only if something is changed
}
