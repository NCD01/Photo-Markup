import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';

void main() {
  group('TextNoteMarkup', () {
    const Rect imageRect = Rect.fromLTWH(10, 20, 200, 100);

    test('clamps anchor point to image bounds', () {
      final TextNoteMarkup note = TextNoteMarkup.fromCanvasPoint(
        id: 1,
        anchorPoint: const Offset(400, -40),
        text: 'Note',
        imageRect: imageRect,
      );

      final Offset anchor = note.anchorInRect(imageRect);
      expect(anchor.dx, imageRect.right);
      expect(anchor.dy, imageRect.top);
    });

    test('copyWith updates text and preserves other fields by default', () {
      const TextNoteMarkup original = TextNoteMarkup(
        id: 2,
        anchorNormalized: Offset(0.2, 0.3),
        text: 'Old',
      );
      final TextNoteMarkup updated = original.copyWith(text: 'New');

      expect(updated.id, original.id);
      expect(updated.anchorNormalized, original.anchorNormalized);
      expect(updated.text, 'New');
      expect(updated.fontFamily, MarkupTypographyConstants.defaultFontFamily);
      expect(updated.fontSize, MarkupTypographyConstants.defaultFontSize);
      expect(updated.stylePresetId, MarkupStylePresets.defaultPresetId);
    });

    test('copyWith can update style preset id', () {
      const TextNoteMarkup original = TextNoteMarkup(
        id: 3,
        anchorNormalized: Offset(0.3, 0.4),
        text: 'Style',
      );
      final TextNoteMarkup updated = original.copyWith(
        stylePresetId: MarkupStylePresetId.red,
      );

      expect(updated.stylePresetId, MarkupStylePresetId.red);
    });

    test('copyWith can update typography fields', () {
      const TextNoteMarkup original = TextNoteMarkup(
        id: 4,
        anchorNormalized: Offset(0.1, 0.2),
        text: 'Typography',
      );
      final TextNoteMarkup updated = original.copyWith(
        fontFamily: 'Calibri',
        fontSize: 22,
      );

      expect(updated.fontFamily, 'Calibri');
      expect(updated.fontSize, 22);
      expect(updated.text, original.text);
    });
  });
}
