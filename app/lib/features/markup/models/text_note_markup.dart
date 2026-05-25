import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

class TextNoteMarkup {
  const TextNoteMarkup({
    required this.id,
    required this.anchorNormalized,
    required this.text,
    this.stylePresetId = MarkupStylePresets.defaultPresetId,
  });

  final int id;
  final Offset anchorNormalized;
  final String text;
  final MarkupStylePresetId stylePresetId;

  factory TextNoteMarkup.fromCanvasPoint({
    required int id,
    required Offset anchorPoint,
    required String text,
    required Rect imageRect,
    MarkupStylePresetId stylePresetId = MarkupStylePresets.defaultPresetId,
  }) {
    final Offset clamped = _clampPoint(anchorPoint, imageRect);
    return TextNoteMarkup(
      id: id,
      anchorNormalized: _normalizePoint(clamped, imageRect),
      text: text,
      stylePresetId: stylePresetId,
    );
  }

  Offset anchorInRect(Rect imageRect) {
    return _denormalizePoint(anchorNormalized, imageRect);
  }

  TextNoteMarkup copyWith({
    int? id,
    Offset? anchorNormalized,
    String? text,
    MarkupStylePresetId? stylePresetId,
  }) {
    return TextNoteMarkup(
      id: id ?? this.id,
      anchorNormalized: anchorNormalized ?? this.anchorNormalized,
      text: text ?? this.text,
      stylePresetId: stylePresetId ?? this.stylePresetId,
    );
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
    return other is TextNoteMarkup &&
        other.id == id &&
        other.anchorNormalized == anchorNormalized &&
        other.text == text &&
        other.stylePresetId == stylePresetId;
  }

  @override
  int get hashCode => Object.hash(id, anchorNormalized, text, stylePresetId);
}
