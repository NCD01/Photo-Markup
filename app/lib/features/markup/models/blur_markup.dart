import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';

/// A rectangle of the photo that gets blurred out: a face, a plate, a house
/// number, a name on a delivery ticket.
///
/// The blur is applied to the photo underneath, never to the annotations, and
/// it is baked into the export at full resolution.
class BlurMarkup {
  const BlurMarkup({
    required this.id,
    required this.startNormalized,
    required this.endNormalized,
    this.strengthScale = MarkupStrokeConstants.defaultScale,
  });

  final int id;
  final Offset startNormalized;
  final Offset endNormalized;

  /// Reuses the stroke-width control so one setting drives blur strength too.
  final double strengthScale;

  factory BlurMarkup.fromCanvasPoints({
    required int id,
    required Offset startPoint,
    required Offset endPoint,
    required Rect imageRect,
    double strengthScale = MarkupStrokeConstants.defaultScale,
  }) {
    return BlurMarkup(
      id: id,
      startNormalized: _normalizePoint(
        _clampPoint(startPoint, imageRect),
        imageRect,
      ),
      endNormalized: _normalizePoint(
        _clampPoint(endPoint, imageRect),
        imageRect,
      ),
      strengthScale: MarkupStrokeConstants.normalizeScale(strengthScale),
    );
  }

  BlurMarkup copyWith({
    int? id,
    Offset? startNormalized,
    Offset? endNormalized,
    double? strengthScale,
  }) {
    return BlurMarkup(
      id: id ?? this.id,
      startNormalized: startNormalized ?? this.startNormalized,
      endNormalized: endNormalized ?? this.endNormalized,
      strengthScale: strengthScale ?? this.strengthScale,
    );
  }

  Rect rectInRect(Rect imageRect) {
    return Rect.fromPoints(
      _denormalizePoint(startNormalized, imageRect),
      _denormalizePoint(endNormalized, imageRect),
    );
  }

  double widthInRect(Rect imageRect) => rectInRect(imageRect).width;

  double heightInRect(Rect imageRect) => rectInRect(imageRect).height;

  /// Blur radius in pixels for a given render scale.
  ///
  /// It scales with the render so a face obscured on screen is just as
  /// obscured in a 6000px export, and it also scales with the size of the
  /// region so a large area is not blurred with a token amount.
  double sigmaForRect(Rect rect, double scale) {
    final double shortestSide = rect.shortestSide;
    final double proportional =
        shortestSide * BlurMarkupConstants.sigmaShortSideFactor;
    final double base = BlurMarkupConstants.minimumSigma * scale;
    final double sigma =
        (proportional > base ? proportional : base) *
        MarkupStrokeConstants.normalizeScale(strengthScale);
    return sigma.clamp(
      BlurMarkupConstants.minimumSigma,
      BlurMarkupConstants.maximumSigma * scale,
    );
  }

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
    return other is BlurMarkup &&
        other.id == id &&
        other.startNormalized == startNormalized &&
        other.endNormalized == endNormalized &&
        other.strengthScale == strengthScale;
  }

  @override
  int get hashCode =>
      Object.hash(id, startNormalized, endNormalized, strengthScale);
}
