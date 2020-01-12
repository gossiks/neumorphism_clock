import 'package:flutter/widgets.dart';
import 'package:neumorphism_clock/neumorphism_helper/clipper.dart';
import 'package:neumorphism_clock/neumorphism_helper/theme.dart';
import 'package:neumorphism_clock/neumorphism_helper/wrap/neumorphism.dart';

Widget buildAnimatedFontNeumorphism(BuildContext context, Path symbolTo, Path symbolFrom,
    {CustomClipper<Path> customClipper,
    double height,
    Duration animationDuration = const Duration(milliseconds: 1500)}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 40.0),
    child: AnimatedNeumorphism(
      clipPathTo: symbolTo,
      clipPathFrom: symbolFrom,
      elementElevation: NeumorphismTheme.of(context).elementElevation,
      clipper: customClipper,
      height: height,
      animationDuration: animationDuration,
    ),
  );
}

class AnimatedNeumorphism extends StatefulWidget {
  final Path clipPathTo, clipPathFrom;
  final double elementElevation;
  final CustomClipper<Path> clipper;
  final double height;
  final Duration animationDuration;

  AnimatedNeumorphism(
      {Key key,
      this.clipPathTo,
      this.clipPathFrom,
      this.elementElevation = 10,
      this.height,
      this.clipper,
      this.animationDuration = const Duration(milliseconds: 4000)})
      : super(key: key = GlobalKey());

  @override
  _AnimatedNeumorphismState createState() => _AnimatedNeumorphismState();
}

class _AnimatedNeumorphismState extends State<AnimatedNeumorphism> with SingleTickerProviderStateMixin {
  Animation<double> ascendAnimation, descendAnimation;

  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: widget.animationDuration);
    ascendAnimation = Tween<double>(begin: widget.elementElevation, end: 0)
        .animate(CurvedAnimation(parent: animationController, curve: Curves.linear));
    startAnimation();
  }

  startAnimation() {
    animationController.forward().then((v) {
      animationController.reverse();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
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

Widget buildNeumorphismSymbol(
    {Path clipPath, final double elementElevation, CustomClipper clipper, double height = 100, BuildContext context}) {
  return Container(
    child: Neumorphism(
      shadowBottomPaint: NeumorphismTheme.of(context).shadowBottomPaint,
      shadowTopPaint: NeumorphismTheme.of(context).shadowTopPaint,
      shift: elementElevation ?? 3,
      clipper: clipper ?? FontSymbolClipper(clipPath),
      child: Container(
        height: height,
        color: NeumorphismTheme.of(context).surfaceColor,
      ),
    ),
  );
}
