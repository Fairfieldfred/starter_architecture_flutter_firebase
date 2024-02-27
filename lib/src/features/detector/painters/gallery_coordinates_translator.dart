import 'dart:ui';

import 'package:camera/camera.dart';

double translateX(
  double x,
  Size canvasSize,
  Size imageSize,
  CameraLensDirection cameraLensDirection,
) {
  final double imageAspectRatio = (imageSize.width) / (imageSize.height);
  final double boxAspectRatio = canvasSize.width / canvasSize.height;
  final bool fittedByWidth = imageAspectRatio > boxAspectRatio;

  double scaleX, offsetX, scaleY, offsetY;

  if (fittedByWidth) {
    scaleX = canvasSize.width / imageSize.width;
    offsetX = 0.0;
    scaleY = scaleX;
    offsetY = (canvasSize.height - imageSize.height * scaleY) / 2;
  } else {
    scaleY = canvasSize.height / imageSize.height;
    offsetY = 0.0;
    scaleX = scaleY;
    offsetX = (canvasSize.width - imageSize.width * scaleX) / 2;
  }

  return x * scaleX + offsetX;
}

double translateY(
  double y,
  Size canvasSize,
  Size imageSize,
  CameraLensDirection cameraLensDirection,
) {
  final double imageAspectRatio = (imageSize.width) / (imageSize.height);
  final double boxAspectRatio = canvasSize.width / canvasSize.height;
  final bool fittedByWidth = imageAspectRatio > boxAspectRatio;

  double scaleX, offsetX, scaleY, offsetY;

  if (fittedByWidth) {
    scaleX = canvasSize.width / imageSize.width;
    offsetX = 0.0;
    scaleY = scaleX;
    offsetY = (canvasSize.height - imageSize.height * scaleY) / 2;
  } else {
    scaleY = canvasSize.height / imageSize.height;
    offsetY = 0.0;
    scaleX = scaleY;
    offsetX = (canvasSize.width - imageSize.width * scaleX) / 2;
  }
  return y * scaleY + offsetY;
}
