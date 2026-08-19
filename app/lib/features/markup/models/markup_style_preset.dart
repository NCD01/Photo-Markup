import 'package:flutter/material.dart';

enum MarkupStylePresetId { ncdBlue, red, yellow, white, black, orange, green }

/// One colour for every tool.
///
/// Before this, each preset carried a different hue per tool, so "Blue" drew
/// blue dimensions, green arrows, orange rectangles, red ellipses and purple
/// freehand. Picking a colour now actually picks the colour.
class MarkupStylePreset {
  const MarkupStylePreset({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.strokeColor,
    required this.selectedStrokeColor,
    required this.fillColor,
    required this.textColor,
    required this.textBackgroundColor,
  });

  final MarkupStylePresetId id;
  final String label;
  final String shortLabel;

  /// The colour every tool draws with when this preset is active.
  final Color strokeColor;

  /// A brighter version used while the markup is selected.
  final Color selectedStrokeColor;

  /// Translucent interior for filled rectangles and ellipses.
  final Color fillColor;

  /// Text colour for labels and notes drawn in this preset.
  final Color textColor;

  /// Chip background behind label and note text.
  final Color textBackgroundColor;

  /// True when the stroke colour is light enough that a dark halo reads best
  /// behind it. Drives the auto-contrast outline in the renderer.
  bool get prefersDarkHalo => strokeColor.computeLuminance() > 0.42;

  // The renderer and the toolbar still speak in per-tool terms in places.
  // These keep that call-site vocabulary without reintroducing per-tool hues.
  Color get dimensionLineColor => strokeColor;
  Color get dimensionSelectedLineColor => selectedStrokeColor;
  Color get arrowLineColor => strokeColor;
  Color get arrowSelectedLineColor => selectedStrokeColor;
  Color get rectangleOutlineColor => strokeColor;
  Color get rectangleSelectedOutlineColor => selectedStrokeColor;
  Color get rectangleFillColor => fillColor;
  Color get ovalOutlineColor => strokeColor;
  Color get ovalSelectedOutlineColor => selectedStrokeColor;
  Color get ovalFillColor => fillColor;
  Color get freehandStrokeColor => strokeColor;
  Color get freehandSelectedStrokeColor => selectedStrokeColor;
  Color get textNoteTextColor => textColor;
  Color get textNoteBackgroundColor => textBackgroundColor;
  Color get textNoteBorderColor => strokeColor;
  Color get textNoteSelectedBorderColor => selectedStrokeColor;
}

class MarkupStylePresets {
  const MarkupStylePresets._();

  static const MarkupStylePresetId defaultPresetId =
      MarkupStylePresetId.ncdBlue;

  static const List<MarkupStylePreset> all = <MarkupStylePreset>[
    MarkupStylePreset(
      id: MarkupStylePresetId.ncdBlue,
      label: 'NCD Blue',
      shortLabel: 'Blue',
      strokeColor: Color(0xFF00A8F0),
      selectedStrokeColor: Color(0xFF5FD2FF),
      fillColor: Color(0x3300A8F0),
      textColor: Color(0xFF06212D),
      textBackgroundColor: Color(0xF2E8F8FF),
    ),
    MarkupStylePreset(
      id: MarkupStylePresetId.orange,
      label: 'Orange',
      shortLabel: 'Orange',
      strokeColor: Color(0xFFFF6A00),
      selectedStrokeColor: Color(0xFFFF9440),
      fillColor: Color(0x33FF6A00),
      textColor: Color(0xFF2B1200),
      textBackgroundColor: Color(0xF2FFF0E4),
    ),
    MarkupStylePreset(
      id: MarkupStylePresetId.red,
      label: 'Red',
      shortLabel: 'Red',
      strokeColor: Color(0xFFFF2038),
      selectedStrokeColor: Color(0xFFFF6070),
      fillColor: Color(0x33FF2038),
      textColor: Color(0xFF2B0007),
      textBackgroundColor: Color(0xF2FFE9EC),
    ),
    MarkupStylePreset(
      id: MarkupStylePresetId.yellow,
      label: 'Yellow',
      shortLabel: 'Yellow',
      strokeColor: Color(0xFFFFD400),
      selectedStrokeColor: Color(0xFFFFE761),
      fillColor: Color(0x33FFD400),
      textColor: Color(0xFF2B2300),
      textBackgroundColor: Color(0xF2FFF8DA),
    ),
    MarkupStylePreset(
      id: MarkupStylePresetId.green,
      label: 'Green',
      shortLabel: 'Green',
      strokeColor: Color(0xFF2BE86A),
      selectedStrokeColor: Color(0xFF77F49E),
      fillColor: Color(0x332BE86A),
      textColor: Color(0xFF042B12),
      textBackgroundColor: Color(0xF2E6FFEF),
    ),
    MarkupStylePreset(
      id: MarkupStylePresetId.white,
      label: 'White',
      shortLabel: 'White',
      strokeColor: Color(0xFFFFFFFF),
      selectedStrokeColor: Color(0xFFEAF6FF),
      fillColor: Color(0x33FFFFFF),
      textColor: Color(0xFF141414),
      textBackgroundColor: Color(0xF2FFFFFF),
    ),
    MarkupStylePreset(
      id: MarkupStylePresetId.black,
      label: 'Black',
      shortLabel: 'Black',
      strokeColor: Color(0xFF101010),
      selectedStrokeColor: Color(0xFF3C3C3C),
      fillColor: Color(0x33101010),
      textColor: Color(0xFFFFFFFF),
      textBackgroundColor: Color(0xF2151515),
    ),
  ];

  static MarkupStylePreset byId(MarkupStylePresetId id) {
    for (final MarkupStylePreset preset in all) {
      if (preset.id == id) {
        return preset;
      }
    }
    return all.first;
  }
}
