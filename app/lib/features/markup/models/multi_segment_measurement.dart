import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

class MultiSegmentMeasurement {
  MultiSegmentMeasurement({
    required this.id,
    required List<Offset> normalizedPoints,
    this.fontFamily = MarkupTypographyConstants.defaultFontFamily,
    this.fontSize = MarkupTypographyConstants.defaultFontSize,
    this.stylePresetId = MarkupStylePresets.defaultPresetId,
  }) : normalizedPoints = List<Offset>.unmodifiable(normalizedPoints);

  final int id;
  final List<Offset> normalizedPoints;
  final String fontFamily;
  final double fontSize;
  final MarkupStylePresetId stylePresetId;

  factory MultiSegmentMeasurement.fromCanvasPoints({
    required int id,
    required List<Offset> points,
    required Rect imageRect,
    String fontFamily = MarkupTypographyConstants.defaultFontFamily,
    double fontSize = MarkupTypographyConstants.defaultFontSize,
    MarkupStylePresetId stylePresetId = MarkupStylePresets.defaultPresetId,
  }) {
    final List<Offset> normalized = <Offset>[];
    for (final Offset point in points) {
      normalized.add(_normalizePoint(_clampPoint(point, imageRect), imageRect));
    }
    return MultiSegmentMeasurement(
      id: id,
      normalizedPoints: normalized,
      fontFamily: fontFamily,
      fontSize: fontSize,
      stylePresetId: stylePresetId,
    );
  }

  MultiSegmentMeasurement copyWith({
    int? id,
    List<Offset>? normalizedPoints,
    String? fontFamily,
    double? fontSize,
    MarkupStylePresetId? stylePresetId,
  }) {
    return MultiSegmentMeasurement(
      id: id ?? this.id,
      normalizedPoints: normalizedPoints ?? this.normalizedPoints,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      stylePresetId: stylePresetId ?? this.stylePresetId,
    );
  }

  List<Offset> pointsInRect(Rect imageRect) {
    return normalizedPoints
        .map((Offset point) => _denormalizePoint(point, imageRect))
        .toList(growable: false);
  }

  double distanceToPointInRect(Offset point, Rect imageRect) {
    final List<Offset> points = pointsInRect(imageRect);
    if (points.isEmpty) {
      return double.infinity;
    }
    if (points.length == 1) {
      return (point - points.first).distance;
    }

    double bestDistance = double.infinity;
    for (int i = 1; i < points.length; i++) {
      final double distance = _distanceToSegment(
        point,
        points[i - 1],
        points[i],
      );
      if (distance < bestDistance) {
        bestDistance = distance;
      }
    }
    return bestDistance;
  }

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

  static double _distanceToSegment(Offset point, Offset start, Offset end) {
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! MultiSegmentMeasurement ||
        other.id != id ||
        other.fontFamily != fontFamily ||
        other.fontSize != fontSize ||
        other.stylePresetId != stylePresetId ||
        other.normalizedPoints.length != normalizedPoints.length) {
      return false;
    }
    for (int i = 0; i < normalizedPoints.length; i++) {
      if (other.normalizedPoints[i] != normalizedPoints[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    Object.hashAll(normalizedPoints),
    fontFamily,
    fontSize,
    stylePresetId,
  );
}
