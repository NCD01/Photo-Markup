import 'dart:math' as math;

import 'package:ncd_photo_markup/core/constants/app_constants.dart';

class CanvasViewTransformUtils {
  const CanvasViewTransformUtils._();

  static double clampScale(double scale) {
    return scale.clamp(
      ViewControlConstants.minScale,
      ViewControlConstants.maxScale,
    );
  }

  static double zoomInStep(double currentScale) {
    return clampScale(currentScale + ViewControlConstants.buttonZoomStep);
  }

  static double zoomOutStep(double currentScale) {
    return clampScale(currentScale - ViewControlConstants.buttonZoomStep);
  }

  static double wheelScaleDelta(double scrollDeltaDy) {
    return math.exp(-scrollDeltaDy * ViewControlConstants.wheelZoomSensitivity);
  }

  static int zoomPercent(double scale) {
    return (scale * 100).round();
  }
}

