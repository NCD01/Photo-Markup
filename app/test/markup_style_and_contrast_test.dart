import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/rendering/markup_scene_renderer.dart';

void main() {
  test('every preset paints every tool the same colour', () {
    for (final MarkupStylePreset preset in MarkupStylePresets.all) {
      expect(preset.dimensionLineColor, preset.strokeColor);
      expect(preset.arrowLineColor, preset.strokeColor);
      expect(preset.rectangleOutlineColor, preset.strokeColor);
      expect(preset.ovalOutlineColor, preset.strokeColor);
      expect(preset.freehandStrokeColor, preset.strokeColor);
      expect(preset.textNoteBorderColor, preset.strokeColor);
    }
  });

  test('text on a preset chip has real contrast against its background', () {
    for (final MarkupStylePreset preset in MarkupStylePresets.all) {
      final double textLuminance = preset.textColor.computeLuminance();
      final double chipLuminance = preset.textBackgroundColor
          .computeLuminance();
      final double lighter = textLuminance > chipLuminance
          ? textLuminance
          : chipLuminance;
      final double darker = textLuminance > chipLuminance
          ? chipLuminance
          : textLuminance;
      final double ratio = (lighter + 0.05) / (darker + 0.05);
      expect(
        ratio,
        greaterThan(7.0),
        reason: '${preset.label} chip text should clear AAA body contrast',
      );
    }
  });

  test('a light stroke gets a dark halo and a dark stroke a light one', () {
    final Paint lightStrokeHalo = MarkupSceneRenderer.haloPaintFor(
      strokeColor: const Color(0xFFFFFFFF),
      strokeWidth: 4,
      scale: 1,
    );
    final Paint darkStrokeHalo = MarkupSceneRenderer.haloPaintFor(
      strokeColor: const Color(0xFF101010),
      strokeWidth: 4,
      scale: 1,
    );

    expect(
      lightStrokeHalo.color.toARGB32(),
      MarkupStrokeConstants.darkHalo.toARGB32(),
    );
    expect(
      darkStrokeHalo.color.toARGB32(),
      MarkupStrokeConstants.lightHalo.toARGB32(),
    );
  });

  test('every preset stroke colour resolves a halo that contrasts with it', () {
    for (final MarkupStylePreset preset in MarkupStylePresets.all) {
      final Paint halo = MarkupSceneRenderer.haloPaintFor(
        strokeColor: preset.strokeColor,
        strokeWidth: 3,
        scale: 1,
      );
      final double strokeLuminance = preset.strokeColor.computeLuminance();
      final double haloLuminance = halo.color.computeLuminance();
      expect(
        (strokeLuminance - haloLuminance).abs(),
        greaterThan(0.25),
        reason: '${preset.label} halo should separate from its own stroke',
      );
    }
  });

  test('the halo is always wider than the stroke it sits behind', () {
    for (final double strokeWidth in <double>[1, 3, 8, 40]) {
      final Paint halo = MarkupSceneRenderer.haloPaintFor(
        strokeColor: const Color(0xFFFF6A00),
        strokeWidth: strokeWidth,
        scale: 1,
      );
      expect(halo.strokeWidth, greaterThan(strokeWidth));
    }
  });

  test('stroke width scales with the chosen weight and the export scale', () {
    final double fine = MarkupSceneRenderer.resolveStrokeWidth(
      baseWidth: 3,
      strokeWidthScale: MarkupStrokeConstants.fine,
      scale: 1,
      isSelected: false,
      selectedMultiplier: 1.4,
    );
    final double heavy = MarkupSceneRenderer.resolveStrokeWidth(
      baseWidth: 3,
      strokeWidthScale: MarkupStrokeConstants.heavy,
      scale: 1,
      isSelected: false,
      selectedMultiplier: 1.4,
    );
    final double heavyAtExport = MarkupSceneRenderer.resolveStrokeWidth(
      baseWidth: 3,
      strokeWidthScale: MarkupStrokeConstants.heavy,
      scale: 8,
      isSelected: false,
      selectedMultiplier: 1.4,
    );

    expect(heavy, greaterThan(fine));
    expect(heavyAtExport, closeTo(heavy * 8, 0.0001));
  });

  test('an out-of-range stored width is clamped, not trusted', () {
    expect(
      MarkupStrokeConstants.normalizeScale(999),
      MarkupStrokeConstants.maxScale,
    );
    expect(
      MarkupStrokeConstants.normalizeScale(-4),
      MarkupStrokeConstants.minScale,
    );
    expect(
      MarkupStrokeConstants.normalizeScale(double.nan),
      MarkupStrokeConstants.defaultScale,
    );
    expect(
      MarkupStrokeConstants.normalizeScale(null),
      MarkupStrokeConstants.defaultScale,
    );
  });
}
