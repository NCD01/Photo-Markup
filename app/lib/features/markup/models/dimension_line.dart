import 'package:flutter/material.dart';

class DimensionLine {
  const DimensionLine({
    required this.startNormalized,
    required this.endNormalized,
    this.label,
  });

  final Offset startNormalized;
  final Offset endNormalized;
  final String? label;

  factory DimensionLine.fromCanvasPoints({
    required Offset startPoint,
    required Offset endPoint,
    required Rect imageRect,
  }) {
    return DimensionLine(
      startNormalized: _normalizePoint(
        _clampPoint(startPoint, imageRect),
        imageRect,
      ),
      endNormalized: _normalizePoint(
        _clampPoint(endPoint, imageRect),
        imageRect,
      ),
    );
  }

  DimensionLine copyWith({
    Offset? startNormalized,
    Offset? endNormalized,
    String? label,
    bool clearLabel = false,
  }) {
    return DimensionLine(
      startNormalized: startNormalized ?? this.startNormalized,
      endNormalized: endNormalized ?? this.endNormalized,
      label: clearLabel ? null : (label ?? this.label),
    );
  }

  Offset startInRect(Rect imageRect) {
    return _denormalizePoint(startNormalized, imageRect);
  }

  Offset endInRect(Rect imageRect) {
    return _denormalizePoint(endNormalized, imageRect);
  }

  double lengthInRect(Rect imageRect) {
    return (endInRect(imageRect) - startInRect(imageRect)).distance;
  }

  Offset midpointInRect(Rect imageRect) {
    final Offset start = startInRect(imageRect);
    final Offset end = endInRect(imageRect);
    return Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
  }

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

  static Offset clampToRect(Offset point, Rect rect) {
    return _clampPoint(point, rect);
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
}
