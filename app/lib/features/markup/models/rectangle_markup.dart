import 'package:flutter/material.dart';

class RectangleMarkup {
  const RectangleMarkup({
    required this.id,
    required this.startNormalized,
    required this.endNormalized,
  });

  final int id;
  final Offset startNormalized;
  final Offset endNormalized;

  factory RectangleMarkup.fromCanvasPoints({
    required int id,
    required Offset startPoint,
    required Offset endPoint,
    required Rect imageRect,
  }) {
    return RectangleMarkup(
      id: id,
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

  Rect rectInRect(Rect imageRect) {
    final Offset start = _denormalizePoint(startNormalized, imageRect);
    final Offset end = _denormalizePoint(endNormalized, imageRect);
    return Rect.fromPoints(start, end);
  }

  double widthInRect(Rect imageRect) => rectInRect(imageRect).width;

  double heightInRect(Rect imageRect) => rectInRect(imageRect).height;

  double distanceToPointInRect(Offset point, Rect imageRect) {
    final Rect rect = rectInRect(imageRect);
    if (rect.contains(point)) {
      return 0;
    }
    final Offset nearest = Offset(
      point.dx.clamp(rect.left, rect.right),
      point.dy.clamp(rect.top, rect.bottom),
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
    return other is RectangleMarkup &&
        other.id == id &&
        other.startNormalized == startNormalized &&
        other.endNormalized == endNormalized;
  }

  @override
  int get hashCode => Object.hash(id, startNormalized, endNormalized);
}
