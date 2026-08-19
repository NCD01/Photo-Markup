import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

class ArrowMarkup {
  const ArrowMarkup({
    required this.id,
    required this.startNormalized,
    required this.endNormalized,
    this.stylePresetId = MarkupStylePresets.defaultPresetId,
    this.strokeWidthScale = MarkupStrokeConstants.defaultScale,
    this.hasHead = true,
  });

  final int id;
  final Offset startNormalized;
  final Offset endNormalized;
  final MarkupStylePresetId stylePresetId;
  final double strokeWidthScale;

  /// False turns the arrow into a plain straight line.
  final bool hasHead;

  factory ArrowMarkup.fromCanvasPoints({
    required int id,
    required Offset startPoint,
    required Offset endPoint,
    required Rect imageRect,
    MarkupStylePresetId stylePresetId = MarkupStylePresets.defaultPresetId,
    double strokeWidthScale = MarkupStrokeConstants.defaultScale,
    bool hasHead = true,
  }) {
    return ArrowMarkup(
      id: id,
      strokeWidthScale: MarkupStrokeConstants.normalizeScale(strokeWidthScale),
      hasHead: hasHead,
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

  ArrowMarkup copyWith({
    int? id,
    Offset? startNormalized,
    Offset? endNormalized,
    MarkupStylePresetId? stylePresetId,
    double? strokeWidthScale,
    bool? hasHead,
  }) {
    return ArrowMarkup(
      id: id ?? this.id,
      startNormalized: startNormalized ?? this.startNormalized,
      endNormalized: endNormalized ?? this.endNormalized,
      stylePresetId: stylePresetId ?? this.stylePresetId,
      strokeWidthScale: strokeWidthScale ?? this.strokeWidthScale,
      hasHead: hasHead ?? this.hasHead,
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
    return other is ArrowMarkup &&
        other.id == id &&
        other.startNormalized == startNormalized &&
        other.endNormalized == endNormalized &&
        other.stylePresetId == stylePresetId &&
        other.strokeWidthScale == strokeWidthScale &&
        other.hasHead == hasHead;
  }

  @override
  int get hashCode => Object.hash(
    id,
    startNormalized,
    endNormalized,
    stylePresetId,
    strokeWidthScale,
    hasHead,
  );
}
