import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:neumorphism_clock/neumorphism_helper/wrap/misc/image_clip.dart';

Offset toOffset(el) => Offset(el.x, el.y);

class PicturClipWidget extends StatelessWidget {
  PicturClipWidget(
      {this.imageKey,
      @required this.imageProvider,
      this.backgroundParams = const BackgroundParams(type: BackgroundType.FLOATING, normalizedPosition: 0),
      this.imageParams = const ImageParams(type: ImageType.CLIPPED, clipIt: true)})
      : assert(
            imageParams.clipPath.where((v) => v.dx > 1 || v.dy > 1).length == 0, "clipPath has values greater than 1"),
        super();

  final GlobalKey imageKey;
  final ImageProvider imageProvider;
  final BackgroundParams backgroundParams;
  final ImageParams imageParams;

  PicturClipWidget.network({
    GlobalKey key,
    String urlImage,
    BackgroundParams backgroundParams,
    ImageParams imageParams,
  }) : this(
            imageKey: key,
            imageProvider: NetworkImage(urlImage),
            backgroundParams: backgroundParams,
            imageParams: imageParams);

  PicturClipWidget.networkState({
    GlobalKey key,
    String urlImage,
    BackgroundParams backgroundParams,
    ImageParams imageParams,
  }) : this.network(key: key, urlImage: urlImage, backgroundParams: backgroundParams, imageParams: imageParams);

  PicturClipWidget.localFile({
    GlobalKey key,
    String localFilePath,
    BackgroundParams backgroundParams,
    ImageParams imageParams,
  }) : this(
            imageKey: key,
            imageProvider: FileImage(
              File(localFilePath),
            ),
            backgroundParams: backgroundParams,
            imageParams: imageParams);

  @override
  Widget build(BuildContext context) {
    Image image = Image(
      image: imageProvider,
    );
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        key: imageKey,
        children: <Widget>[
          buildBackground(backgroundParams, image),
          buildImage(image, imageParams),
        ],
      );
    });
  }
}

class ImageParams {
  final ImageType type;
  final double normalizedPosition;
  final bool clipIt;
  final List<Offset> clipPath;

  const ImageParams({this.type, this.normalizedPosition, this.clipIt, this.clipPath});
}

enum ImageType { CLIPPED, CLIPPED_FLOATING, ORIGINAL_IMAGE }

Widget buildImage(Image image, ImageParams imageParams) {
  Widget result;
  switch (imageParams.type) {
    case ImageType.CLIPPED:
      result = LayoutBuilder(builder: (context, constrains) {
        return Container(
          child: ((imageParams.clipPath.isEmpty || imageParams.clipPath.length <= 2) || !imageParams.clipIt)
              ? image
              : ClipPath(
                  clipper: ImagePathClipper(imageParams.clipPath),
                  child: image,
                ),
        );
      });
      break;
    case ImageType.CLIPPED_FLOATING:
      double fraction = normalizeToModule1(imageParams.normalizedPosition);
      result = LayoutBuilder(builder: (context, constrains) {
        return Container(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment(0, fraction),
                child: FractionallySizedBox(
                  heightFactor: 0.8,
                  child: ((imageParams.clipPath.isEmpty || imageParams.clipPath.length <= 2) || !imageParams.clipIt)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: image,
                        )
                      : ClipPath(
                          clipper: ImagePathClipper(imageParams.clipPath),
                          child: ClipRRect(borderRadius: BorderRadius.circular(20), child: image),
                        ),
                ),
              ),
            ],
          ),
        );
      });
      break;
    case ImageType.ORIGINAL_IMAGE:
      result = image;
      break;
  }

  return result;
}

Widget buildBackground(BackgroundParams params, Widget image) {
  Widget result;
  switch (params.type) {
    case BackgroundType.FLOATING:
      result = FractionedBackground(params.normalizedPosition);
      break;
    case BackgroundType.FADE_IMAGE:
      result = FadeImageBackground(image);
      break;
  }
  return result;
}

class BackgroundParams {
  final BackgroundType type;
  final double normalizedPosition; // normalized to half widget height up and down to scroll area

  const BackgroundParams({this.type, this.normalizedPosition});
}

enum BackgroundType { FLOATING, FADE_IMAGE }

const double fractionFractionedBackgroundX = 0.9;
const double fractionFractionedBackgroundY = 0.7;
const double leftNorma = -10;
const double rightNorma = 1;

double normalizeToModule1(double normalizedPosition) {
  if (normalizedPosition == null || normalizedPosition < 0 || normalizedPosition > 1) {
    return 0.5;
  } else {
    return (leftNorma.abs() + rightNorma) * (normalizedPosition - 1 / 2);
  }
}

class FractionedBackground extends StatelessWidget {
  final double _normalizedPosition;

  FractionedBackground(double normalizedPosition)
      : _normalizedPosition =
            normalizeToModule1(normalizedPosition); //TODO add parameters to change height and position

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(children: <Widget>[
          Align(
              alignment: Alignment(0, _normalizedPosition),
              child: Container(
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(8))),
                height: constraints.maxHeight * fractionFractionedBackgroundY,
                width: constraints.maxWidth * fractionFractionedBackgroundX,
              ))
        ]);
      },
    );
  }
}

class FadeImageBackground extends StatelessWidget {
  final Widget image;

  FadeImageBackground(this.image);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: image,
    );
  }
}
