import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

class FreehandMarkup {
  FreehandMarkup({
    required this.id,
    required List<Offset> normalizedPoints,
    this.stylePresetId = MarkupStylePresets.defaultPresetId,
    this.strokeWidthScale = MarkupStrokeConstants.defaultScale,
    this.isHighlighter = false,
  }) : normalizedPoints = List<Offset>.unmodifiable(normalizedPoints);

  final int id;
  final List<Offset> normalizedPoints;
  final MarkupStylePresetId stylePresetId;
  final double strokeWidthScale;

  /// True draws the stroke as a wide translucent highlighter pass instead of
  /// an opaque pen line.
  final bool isHighlighter;

  factory FreehandMarkup.fromCanvasPoints({
    required int id,
    required List<Offset> points,
    required Rect imageRect,
    MarkupStylePresetId stylePresetId = MarkupStylePresets.defaultPresetId,
    double strokeWidthScale = MarkupStrokeConstants.defaultScale,
    bool isHighlighter = false,
  }) {
    final List<Offset> normalized = <Offset>[];
    for (final Offset point in points) {
      final Offset clamped = _clampPoint(point, imageRect);
      normalized.add(_normalizePoint(clamped, imageRect));
    }
    return FreehandMarkup(
      id: id,
      normalizedPoints: normalized,
      stylePresetId: stylePresetId,
      strokeWidthScale: MarkupStrokeConstants.normalizeScale(strokeWidthScale),
      isHighlighter: isHighlighter,
    );
  }

  FreehandMarkup copyWith({
    int? id,
    List<Offset>? normalizedPoints,
    MarkupStylePresetId? stylePresetId,
    double? strokeWidthScale,
    bool? isHighlighter,
  }) {
    return FreehandMarkup(
      id: id ?? this.id,
      normalizedPoints: normalizedPoints ?? this.normalizedPoints,
      stylePresetId: stylePresetId ?? this.stylePresetId,
      strokeWidthScale: strokeWidthScale ?? this.strokeWidthScale,
      isHighlighter: isHighlighter ?? this.isHighlighter,
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
      final Offset start = points[i - 1];
      final Offset end = points[i];
      final double distance = _distanceToSegment(point, start, end);
      if (distance < bestDistance) {
        bestDistance = distance;
      }
    }
    return bestDistance;
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
    if (other is! FreehandMarkup) {
      return false;
    }
    if (other.id != id ||
        other.normalizedPoints.length != normalizedPoints.length ||
        other.stylePresetId != stylePresetId ||
        other.strokeWidthScale != strokeWidthScale ||
        other.isHighlighter != isHighlighter) {
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
    stylePresetId,
    strokeWidthScale,
    isHighlighter,
  );
}
