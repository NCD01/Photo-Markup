import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

class DimensionLine {
  const DimensionLine({
    required this.id,
    required this.startNormalized,
    required this.endNormalized,
    this.label,
    this.labelOffsetNormalized,
    this.fontFamily = MarkupTypographyConstants.defaultFontFamily,
    this.fontSize = MarkupTypographyConstants.defaultFontSize,
    this.stylePresetId = MarkupStylePresets.defaultPresetId,
    this.strokeWidthScale = MarkupStrokeConstants.defaultScale,
  });

  final int id;
  final Offset startNormalized;
  final Offset endNormalized;
  final String? label;
  final Offset? labelOffsetNormalized;
  final String fontFamily;
  final double fontSize;
  final MarkupStylePresetId stylePresetId;
  final double strokeWidthScale;

  factory DimensionLine.fromCanvasPoints({
    required int id,
    required Offset startPoint,
    required Offset endPoint,
    required Rect imageRect,
    MarkupStylePresetId stylePresetId = MarkupStylePresets.defaultPresetId,
    double strokeWidthScale = MarkupStrokeConstants.defaultScale,
  }) {
    return DimensionLine(
      id: id,
      strokeWidthScale: MarkupStrokeConstants.normalizeScale(strokeWidthScale),
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

  DimensionLine copyWith({
    int? id,
    Offset? startNormalized,
    Offset? endNormalized,
    String? label,
    Offset? labelOffsetNormalized,
    String? fontFamily,
    double? fontSize,
    MarkupStylePresetId? stylePresetId,
    double? strokeWidthScale,
    bool clearLabel = false,
    bool clearLabelOffset = false,
  }) {
    return DimensionLine(
      id: id ?? this.id,
      startNormalized: startNormalized ?? this.startNormalized,
      endNormalized: endNormalized ?? this.endNormalized,
      label: clearLabel ? null : (label ?? this.label),
      labelOffsetNormalized: clearLabelOffset
          ? null
          : (labelOffsetNormalized ?? this.labelOffsetNormalized),
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      stylePresetId: stylePresetId ?? this.stylePresetId,
      strokeWidthScale: strokeWidthScale ?? this.strokeWidthScale,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DimensionLine &&
        other.id == id &&
        other.startNormalized == startNormalized &&
        other.endNormalized == endNormalized &&
        other.label == label &&
        other.labelOffsetNormalized == labelOffsetNormalized &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize &&
        other.stylePresetId == stylePresetId &&
        other.strokeWidthScale == strokeWidthScale;
  }

  @override
  int get hashCode => Object.hash(
    id,
    startNormalized,
    endNormalized,
    label,
    labelOffsetNormalized,
    fontFamily,
    fontSize,
    stylePresetId,
    strokeWidthScale,
  );
}
