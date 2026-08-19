import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

/// How a callout pin is labelled.
enum CalloutLabelStyle { numbers, letters }

/// A numbered or lettered pin, for punch lists.
///
/// The pin carries a [sequence] rather than a rendered string so renumbering
/// after a delete is a matter of changing one integer.
class CalloutMarkup {
  const CalloutMarkup({
    required this.id,
    required this.anchorNormalized,
    required this.sequence,
    this.labelStyle = CalloutLabelStyle.numbers,
    this.stylePresetId = MarkupStylePresets.defaultPresetId,
    this.sizeScale = MarkupStrokeConstants.defaultScale,
  });

  final int id;
  final Offset anchorNormalized;
  final int sequence;
  final CalloutLabelStyle labelStyle;
  final MarkupStylePresetId stylePresetId;
  final double sizeScale;

  factory CalloutMarkup.fromCanvasPoint({
    required int id,
    required Offset anchorPoint,
    required int sequence,
    required Rect imageRect,
    CalloutLabelStyle labelStyle = CalloutLabelStyle.numbers,
    MarkupStylePresetId stylePresetId = MarkupStylePresets.defaultPresetId,
    double sizeScale = MarkupStrokeConstants.defaultScale,
  }) {
    return CalloutMarkup(
      id: id,
      anchorNormalized: _normalizePoint(
        _clampPoint(anchorPoint, imageRect),
        imageRect,
      ),
      sequence: sequence,
      labelStyle: labelStyle,
      stylePresetId: stylePresetId,
      sizeScale: MarkupStrokeConstants.normalizeScale(sizeScale),
    );
  }

  CalloutMarkup copyWith({
    int? id,
    Offset? anchorNormalized,
    int? sequence,
    CalloutLabelStyle? labelStyle,
    MarkupStylePresetId? stylePresetId,
    double? sizeScale,
  }) {
    return CalloutMarkup(
      id: id ?? this.id,
      anchorNormalized: anchorNormalized ?? this.anchorNormalized,
      sequence: sequence ?? this.sequence,
      labelStyle: labelStyle ?? this.labelStyle,
      stylePresetId: stylePresetId ?? this.stylePresetId,
      sizeScale: sizeScale ?? this.sizeScale,
    );
  }

  Offset centerInRect(Rect imageRect) =>
      _denormalizePoint(anchorNormalized, imageRect);

  double radiusForScale(double scale) =>
      CalloutMarkupConstants.baseRadius *
      MarkupStrokeConstants.normalizeScale(sizeScale) *
      scale;

  String get label => labelForSequence(sequence, labelStyle);

  /// 1 -> "1"; with letters, 1 -> "A", 26 -> "Z", 27 -> "AA".
  static String labelForSequence(int sequence, CalloutLabelStyle style) {
    final int safeSequence = sequence < 1 ? 1 : sequence;
    if (style == CalloutLabelStyle.numbers) {
      return '$safeSequence';
    }
    int remaining = safeSequence;
    final StringBuffer buffer = StringBuffer();
    while (remaining > 0) {
      final int index = (remaining - 1) % 26;
      buffer.write(String.fromCharCode(65 + index));
      remaining = (remaining - 1) ~/ 26;
    }
    return String.fromCharCodes(buffer.toString().codeUnits.reversed);
  }

  /// The number the next pin should get: one past the highest in use, so a
  /// deleted last pin gives its number back.
  static int nextSequence(Iterable<CalloutMarkup> existing) {
    int highest = 0;
    for (final CalloutMarkup callout in existing) {
      if (callout.sequence > highest) {
        highest = callout.sequence;
      }
    }
    return highest + 1;
  }

  double distanceToPointInRect(Offset point, Rect imageRect, double scale) {
    final double distance = (point - centerInRect(imageRect)).distance;
    final double radius = radiusForScale(scale);
    return distance <= radius ? 0 : distance - radius;
  }

  static CalloutLabelStyle labelStyleFromName(String? name) {
    for (final CalloutLabelStyle style in CalloutLabelStyle.values) {
      if (style.name == name) {
        return style;
      }
    }
    return CalloutLabelStyle.numbers;
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
    return other is CalloutMarkup &&
        other.id == id &&
        other.anchorNormalized == anchorNormalized &&
        other.sequence == sequence &&
        other.labelStyle == labelStyle &&
        other.stylePresetId == stylePresetId &&
        other.sizeScale == sizeScale;
  }

  @override
  int get hashCode => Object.hash(
    id,
    anchorNormalized,
    sequence,
    labelStyle,
    stylePresetId,
    sizeScale,
  );
}
