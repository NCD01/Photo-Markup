import 'dart:math' as math;
import 'dart:ui';

import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/area_measurement.dart';
import 'package:ncd_photo_markup/features/markup/models/multi_segment_measurement.dart';
import 'package:ncd_photo_markup/features/markup/models/scale_calibration.dart';

class MeasurementValueUtils {
  const MeasurementValueUtils._();

  static double? calibrationUnitsPerPixel(
    ScaleCalibration? calibration,
    Size? imagePixelSize,
  ) {
    if (calibration == null || imagePixelSize == null) {
      return null;
    }
    final double pixelDistance = distanceInImagePixels(
      calibration.startNormalized,
      calibration.endNormalized,
      imagePixelSize,
    );
    if (pixelDistance <= MeasurementToolConstants.minimumPixelDistance ||
        calibration.realDistance <= 0) {
      return null;
    }
    return calibration.realDistance / pixelDistance;
  }

  static double distanceInImagePixels(
    Offset startNormalized,
    Offset endNormalized,
    Size imagePixelSize,
  ) {
    final double dx =
        (endNormalized.dx - startNormalized.dx) * imagePixelSize.width;
    final double dy =
        (endNormalized.dy - startNormalized.dy) * imagePixelSize.height;
    return math.sqrt((dx * dx) + (dy * dy));
  }

  static double polylineLengthInImagePixels(
    List<Offset> normalizedPoints,
    Size imagePixelSize,
  ) {
    if (normalizedPoints.length < 2) {
      return 0;
    }
    double total = 0;
    for (int i = 1; i < normalizedPoints.length; i++) {
      total += distanceInImagePixels(
        normalizedPoints[i - 1],
        normalizedPoints[i],
        imagePixelSize,
      );
    }
    return total;
  }

  static double polygonAreaInImagePixels(
    List<Offset> normalizedPoints,
    Size imagePixelSize,
  ) {
    if (normalizedPoints.length < 3) {
      return 0;
    }
    double twiceArea = 0;
    for (int i = 0; i < normalizedPoints.length; i++) {
      final Offset current = normalizedPoints[i];
      final Offset next = normalizedPoints[(i + 1) % normalizedPoints.length];
      final double currentX = current.dx * imagePixelSize.width;
      final double currentY = current.dy * imagePixelSize.height;
      final double nextX = next.dx * imagePixelSize.width;
      final double nextY = next.dy * imagePixelSize.height;
      twiceArea += (currentX * nextY) - (nextX * currentY);
    }
    return twiceArea.abs() / 2;
  }

  static double? calibratedPolylineLength({
    required List<Offset> normalizedPoints,
    required ScaleCalibration? calibration,
    required Size? imagePixelSize,
  }) {
    final double? unitsPerPixel = calibrationUnitsPerPixel(
      calibration,
      imagePixelSize,
    );
    if (unitsPerPixel == null || imagePixelSize == null) {
      return null;
    }
    return polylineLengthInImagePixels(normalizedPoints, imagePixelSize) *
        unitsPerPixel;
  }

  static double? calibratedPolygonArea({
    required List<Offset> normalizedPoints,
    required ScaleCalibration? calibration,
    required Size? imagePixelSize,
  }) {
    final double? unitsPerPixel = calibrationUnitsPerPixel(
      calibration,
      imagePixelSize,
    );
    if (unitsPerPixel == null || imagePixelSize == null) {
      return null;
    }
    final double areaPixels = polygonAreaInImagePixels(
      normalizedPoints,
      imagePixelSize,
    );
    return areaPixels * unitsPerPixel * unitsPerPixel;
  }

  static String calibrationDisplayLabel(ScaleCalibration calibration) {
    return '${UiCopyConstants.scaleCalibrationLabelPrefix}: '
        '${_formatValue(calibration.realDistance)} '
        '${normalizeUnitLabel(calibration.unitLabel)}';
  }

  /// Real-world value for a straight two-point segment, or null when there is
  /// no usable scale yet. Used to pre-fill a new dimension label so the photo
  /// scale is worth setting for dimensions too, not just the polyline tools.
  static String? calibratedSegmentDisplayValue({
    required Offset startNormalized,
    required Offset endNormalized,
    required ScaleCalibration? calibration,
    required Size? imagePixelSize,
  }) {
    final double? length = calibratedPolylineLength(
      normalizedPoints: <Offset>[startNormalized, endNormalized],
      calibration: calibration,
      imagePixelSize: imagePixelSize,
    );
    if (length == null || calibration == null) {
      return null;
    }
    return '${_formatValue(length)} ${normalizeUnitLabel(calibration.unitLabel)}';
  }

  static String multiSegmentDisplayLabel({
    required MultiSegmentMeasurement measurement,
    required ScaleCalibration? calibration,
    required Size? imagePixelSize,
  }) {
    final double? length = calibratedPolylineLength(
      normalizedPoints: measurement.normalizedPoints,
      calibration: calibration,
      imagePixelSize: imagePixelSize,
    );
    if (length == null) {
      return UiCopyConstants.measurementNeedsScaleLabel;
    }
    final String unitLabel = normalizeUnitLabel(calibration!.unitLabel);
    return '${UiCopyConstants.multiSegmentLabelPrefix}: ${_formatValue(length)} $unitLabel';
  }

  static String areaDisplayLabel({
    required AreaMeasurement measurement,
    required ScaleCalibration? calibration,
    required Size? imagePixelSize,
  }) {
    final double? perimeter = calibratedPolylineLength(
      normalizedPoints: <Offset>[
        ...measurement.normalizedPoints,
        if (measurement.normalizedPoints.isNotEmpty)
          measurement.normalizedPoints.first,
      ],
      calibration: calibration,
      imagePixelSize: imagePixelSize,
    );
    final double? area = calibratedPolygonArea(
      normalizedPoints: measurement.normalizedPoints,
      calibration: calibration,
      imagePixelSize: imagePixelSize,
    );
    if (perimeter == null || area == null || calibration == null) {
      return UiCopyConstants.measurementNeedsScaleLabel;
    }
    final String unitLabel = normalizeUnitLabel(calibration.unitLabel);
    return '${UiCopyConstants.areaLabelPrefix}: ${_formatValue(area)} sq $unitLabel\n'
        '${UiCopyConstants.perimeterLabelPrefix}: ${_formatValue(perimeter)} $unitLabel';
  }

  static String normalizeUnitLabel(String rawUnit) {
    final String trimmed = rawUnit.trim();
    if (trimmed.isEmpty) {
      return MeasurementToolConstants.defaultUnitLabel;
    }
    return trimmed;
  }

  static Offset polylineLabelAnchor(List<Offset> points) {
    if (points.isEmpty) {
      return Offset.zero;
    }
    if (points.length == 1) {
      return points.first;
    }
    double totalLength = 0;
    final List<double> segmentLengths = <double>[];
    for (int i = 1; i < points.length; i++) {
      final double length = (points[i] - points[i - 1]).distance;
      segmentLengths.add(length);
      totalLength += length;
    }
    if (totalLength <= MeasurementToolConstants.minimumPixelDistance) {
      return points.first;
    }
    final double halfway = totalLength / 2;
    double traversed = 0;
    for (int i = 1; i < points.length; i++) {
      final double segmentLength = segmentLengths[i - 1];
      if (traversed + segmentLength >= halfway) {
        final double t = (halfway - traversed) / segmentLength;
        return Offset.lerp(points[i - 1], points[i], t) ?? points[i];
      }
      traversed += segmentLength;
    }
    return points.last;
  }

  static Offset polygonLabelAnchor(List<Offset> points) {
    if (points.isEmpty) {
      return Offset.zero;
    }
    double x = 0;
    double y = 0;
    for (final Offset point in points) {
      x += point.dx;
      y += point.dy;
    }
    return Offset(x / points.length, y / points.length);
  }

  static String _formatValue(double value) {
    final String fixed = value.toStringAsFixed(
      MeasurementToolConstants.displayPrecision,
    );
    return fixed
        .replaceFirst(RegExp(r'\.0+$'), '')
        .replaceFirst(RegExp(r'(\.\d*?)0+$'), r'$1');
  }
}
