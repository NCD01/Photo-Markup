import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

class OvalMarkup {
  const OvalMarkup({
    required this.id,
    required this.startNormalized,
    required this.endNormalized,
    this.stylePresetId = MarkupStylePresets.defaultPresetId,
  });

  final int id;
  final Offset startNormalized;
  final Offset endNormalized;
  final MarkupStylePresetId stylePresetId;

  factory OvalMarkup.fromCanvasPoints({
    required int id,
    required Offset startPoint,
    required Offset endPoint,
    required Rect imageRect,
    MarkupStylePresetId stylePresetId = MarkupStylePresets.defaultPresetId,
  }) {
    return OvalMarkup(
      id: id,
      startNormalized: _normalizePoint(
        _clampPoint(startPoint, imageRect),
        imageRect,
      ),
      endNormalized: _normalizePoint(
        _clampPoint(endPoint, imageRect),
        imageRect,
      ),
      stylePresetId: stylePresetId,
    );
  }

  OvalMarkup copyWith({
    int? id,
    Offset? startNormalized,
    Offset? endNormalized,
    MarkupStylePresetId? stylePresetId,
  }) {
    return OvalMarkup(
      id: id ?? this.id,
      startNormalized: startNormalized ?? this.startNormalized,
      endNormalized: endNormalized ?? this.endNormalized,
      stylePresetId: stylePresetId ?? this.stylePresetId,
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
    if (rect.width <= 0 || rect.height <= 0) {
      return double.infinity;
    }

    final Offset center = rect.center;
    final double radiusX = rect.width / 2;
    final double radiusY = rect.height / 2;
    final double dx = point.dx - center.dx;
    final double dy = point.dy - center.dy;
    final double normalizedDistanceSquared =
        ((dx * dx) / (radiusX * radiusX)) + ((dy * dy) / (radiusY * radiusY));

    if (normalizedDistanceSquared <= 1.0) {
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
    return other is OvalMarkup &&
        other.id == id &&
        other.startNormalized == startNormalized &&
        other.endNormalized == endNormalized &&
        other.stylePresetId == stylePresetId;
  }

  @override
  int get hashCode =>
      Object.hash(id, startNormalized, endNormalized, stylePresetId);
}
