import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

class ScaleCalibration {
  const ScaleCalibration({
    required this.id,
    required this.startNormalized,
    required this.endNormalized,
    required this.realDistance,
    required this.unitLabel,
    this.fontFamily = MarkupTypographyConstants.defaultFontFamily,
    this.fontSize = MarkupTypographyConstants.defaultFontSize,
    this.stylePresetId = MarkupStylePresets.defaultPresetId,
  });

  final int id;
  final Offset startNormalized;
  final Offset endNormalized;
  final double realDistance;
  final String unitLabel;
  final String fontFamily;
  final double fontSize;
  final MarkupStylePresetId stylePresetId;

  factory ScaleCalibration.fromCanvasPoints({
    required int id,
    required Offset startPoint,
    required Offset endPoint,
    required Rect imageRect,
    required double realDistance,
    required String unitLabel,
    String fontFamily = MarkupTypographyConstants.defaultFontFamily,
    double fontSize = MarkupTypographyConstants.defaultFontSize,
    MarkupStylePresetId stylePresetId = MarkupStylePresets.defaultPresetId,
  }) {
    return ScaleCalibration(
      id: id,
      startNormalized: _normalizePoint(
        _clampPoint(startPoint, imageRect),
        imageRect,
      ),
      endNormalized: _normalizePoint(
        _clampPoint(endPoint, imageRect),
        imageRect,
      ),
      realDistance: realDistance,
      unitLabel: unitLabel,
      fontFamily: fontFamily,
      fontSize: fontSize,
      stylePresetId: stylePresetId,
    );
  }

  ScaleCalibration copyWith({
    int? id,
    Offset? startNormalized,
    Offset? endNormalized,
    double? realDistance,
    String? unitLabel,
    String? fontFamily,
    double? fontSize,
    MarkupStylePresetId? stylePresetId,
  }) {
    return ScaleCalibration(
      id: id ?? this.id,
      startNormalized: startNormalized ?? this.startNormalized,
      endNormalized: endNormalized ?? this.endNormalized,
      realDistance: realDistance ?? this.realDistance,
      unitLabel: unitLabel ?? this.unitLabel,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      stylePresetId: stylePresetId ?? this.stylePresetId,
    );
  }

  Offset startInRect(Rect imageRect) =>
      _denormalizePoint(startNormalized, imageRect);

  Offset endInRect(Rect imageRect) =>
      _denormalizePoint(endNormalized, imageRect);

  Offset midpointInRect(Rect imageRect) {
    final Offset start = startInRect(imageRect);
    final Offset end = endInRect(imageRect);
    return Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
  }

  double lengthInRect(Rect imageRect) =>
      (endInRect(imageRect) - startInRect(imageRect)).distance;

  double distanceToPointInRect(Offset point, Rect imageRect) {
    final Offset start = startInRect(imageRect);
    final Offset end = endInRect(imageRect);
    final Offset segment = end - start;
    final double segmentLengthSquared =
        (segment.dx * segment.dx) + (segment.dy * segment.dy);

    if (segmentLengthSquared == 0) {
      return (point - start).distance;
    }

    final double projection =
        (((point.dx - start.dx) * segment.dx) +
            ((point.dy - start.dy) * segment.dy)) /
        segmentLengthSquared;
    final double clampedProjection = projection.clamp(0.0, 1.0);
    final Offset nearest = Offset(
      start.dx + (segment.dx * clampedProjection),
      start.dy + (segment.dy * clampedProjection),
    );
    return (point - nearest).distance;
  }

  static Offset clampToRect(Offset point, Rect rect) =>
      _clampPoint(point, rect);

  static Offset _normalizePoint(Offset point, Rect imageRect) {
    if (imageRect.width <= 0 || imageRect.height <= 0) {
      return Offset.zero;
    }
    return Offset(
      ((point.dx - imageRect.left) / imageRect.width).clamp(0.0, 1.0),
      ((point.dy - imageRect.top) / imageRect.height).clamp(0.0, 1.0),
    );
  }

  static Offset _denormalizePoint(Offset normalized, Rect imageRect) {
    return Offset(
      imageRect.left + (normalized.dx * imageRect.width),
      imageRect.top + (normalized.dy * imageRect.height),
    );
  }

  static Offset _clampPoint(Offset point, Rect rect) {
    return Offset(
      point.dx.clamp(rect.left, rect.right),
      point.dy.clamp(rect.top, rect.bottom),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ScaleCalibration &&
        other.id == id &&
        other.startNormalized == startNormalized &&
        other.endNormalized == endNormalized &&
        other.realDistance == realDistance &&
        other.unitLabel == unitLabel &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize &&
        other.stylePresetId == stylePresetId;
  }

  @override
  int get hashCode => Object.hash(
    id,
    startNormalized,
    endNormalized,
    realDistance,
    unitLabel,
    fontFamily,
    fontSize,
    stylePresetId,
  );
}
