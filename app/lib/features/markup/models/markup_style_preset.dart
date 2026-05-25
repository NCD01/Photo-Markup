import 'package:flutter/material.dart';

enum MarkupStylePresetId { ncdBlue, red, yellow, white, black }

class MarkupStylePreset {
  const MarkupStylePreset({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.dimensionLineColor,
    required this.dimensionSelectedLineColor,
    required this.arrowLineColor,
    required this.arrowSelectedLineColor,
    required this.rectangleOutlineColor,
    required this.rectangleSelectedOutlineColor,
    required this.rectangleFillColor,
    required this.ovalOutlineColor,
    required this.ovalSelectedOutlineColor,
    required this.ovalFillColor,
    required this.freehandStrokeColor,
    required this.freehandSelectedStrokeColor,
    required this.textNoteTextColor,
    required this.textNoteBackgroundColor,
    required this.textNoteBorderColor,
    required this.textNoteSelectedBorderColor,
  });

  final MarkupStylePresetId id;
  final String label;
  final String shortLabel;
  final Color dimensionLineColor;
  final Color dimensionSelectedLineColor;
  final Color arrowLineColor;
  final Color arrowSelectedLineColor;
  final Color rectangleOutlineColor;
  final Color rectangleSelectedOutlineColor;
  final Color rectangleFillColor;
  final Color ovalOutlineColor;
  final Color ovalSelectedOutlineColor;
  final Color ovalFillColor;
  final Color freehandStrokeColor;
  final Color freehandSelectedStrokeColor;
  final Color textNoteTextColor;
  final Color textNoteBackgroundColor;
  final Color textNoteBorderColor;
  final Color textNoteSelectedBorderColor;
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
      dimensionLineColor: Color(0xFF005C85),
      dimensionSelectedLineColor: Color(0xFF009ADA),
      arrowLineColor: Color(0xFF006B3F),
      arrowSelectedLineColor: Color(0xFF009A5F),
      rectangleOutlineColor: Color(0xFF7A4B00),
      rectangleSelectedOutlineColor: Color(0xFFA46600),
      rectangleFillColor: Color(0x1FBD8A2A),
      ovalOutlineColor: Color(0xFF8B1E00),
      ovalSelectedOutlineColor: Color(0xFFC02A00),
      ovalFillColor: Color(0x1FD4572A),
      freehandStrokeColor: Color(0xFF5A2099),
      freehandSelectedStrokeColor: Color(0xFF7B2FD6),
      textNoteTextColor: Colors.black87,
      textNoteBackgroundColor: Color(0xD9FFFDE7),
      textNoteBorderColor: Color(0xFF5A4A00),
      textNoteSelectedBorderColor: Color(0xFF009ADA),
    ),
    MarkupStylePreset(
      id: MarkupStylePresetId.red,
      label: 'Red',
      shortLabel: 'Red',
      dimensionLineColor: Color(0xFFB00020),
      dimensionSelectedLineColor: Color(0xFFE53935),
      arrowLineColor: Color(0xFFB00020),
      arrowSelectedLineColor: Color(0xFFE53935),
      rectangleOutlineColor: Color(0xFFB00020),
      rectangleSelectedOutlineColor: Color(0xFFE53935),
      rectangleFillColor: Color(0x29E53935),
      ovalOutlineColor: Color(0xFFB00020),
      ovalSelectedOutlineColor: Color(0xFFE53935),
      ovalFillColor: Color(0x29E53935),
      freehandStrokeColor: Color(0xFFB00020),
      freehandSelectedStrokeColor: Color(0xFFE53935),
      textNoteTextColor: Colors.black87,
      textNoteBackgroundColor: Color(0xD9FFEBEE),
      textNoteBorderColor: Color(0xFFB00020),
      textNoteSelectedBorderColor: Color(0xFFE53935),
    ),
    MarkupStylePreset(
      id: MarkupStylePresetId.yellow,
      label: 'Yellow',
      shortLabel: 'Yellow',
      dimensionLineColor: Color(0xFFE0A800),
      dimensionSelectedLineColor: Color(0xFFFFC107),
      arrowLineColor: Color(0xFFE0A800),
      arrowSelectedLineColor: Color(0xFFFFC107),
      rectangleOutlineColor: Color(0xFFE0A800),
      rectangleSelectedOutlineColor: Color(0xFFFFC107),
      rectangleFillColor: Color(0x29FFC107),
      ovalOutlineColor: Color(0xFFE0A800),
      ovalSelectedOutlineColor: Color(0xFFFFC107),
      ovalFillColor: Color(0x29FFC107),
      freehandStrokeColor: Color(0xFFE0A800),
      freehandSelectedStrokeColor: Color(0xFFFFC107),
      textNoteTextColor: Colors.black87,
      textNoteBackgroundColor: Color(0xD9FFFDE7),
      textNoteBorderColor: Color(0xFFE0A800),
      textNoteSelectedBorderColor: Color(0xFFFFC107),
    ),
    MarkupStylePreset(
      id: MarkupStylePresetId.white,
      label: 'White',
      shortLabel: 'White',
      dimensionLineColor: Color(0xFFF5F5F5),
      dimensionSelectedLineColor: Color(0xFFFFFFFF),
      arrowLineColor: Color(0xFFF5F5F5),
      arrowSelectedLineColor: Color(0xFFFFFFFF),
      rectangleOutlineColor: Color(0xFFF5F5F5),
      rectangleSelectedOutlineColor: Color(0xFFFFFFFF),
      rectangleFillColor: Color(0x26FFFFFF),
      ovalOutlineColor: Color(0xFFF5F5F5),
      ovalSelectedOutlineColor: Color(0xFFFFFFFF),
      ovalFillColor: Color(0x26FFFFFF),
      freehandStrokeColor: Color(0xFFF5F5F5),
      freehandSelectedStrokeColor: Color(0xFFFFFFFF),
      textNoteTextColor: Colors.black87,
      textNoteBackgroundColor: Color(0xE6FFFFFF),
      textNoteBorderColor: Color(0xFFE0E0E0),
      textNoteSelectedBorderColor: Color(0xFFFFFFFF),
    ),
    MarkupStylePreset(
      id: MarkupStylePresetId.black,
      label: 'Black',
      shortLabel: 'Black',
      dimensionLineColor: Color(0xFF111111),
      dimensionSelectedLineColor: Color(0xFF000000),
      arrowLineColor: Color(0xFF111111),
      arrowSelectedLineColor: Color(0xFF000000),
      rectangleOutlineColor: Color(0xFF111111),
      rectangleSelectedOutlineColor: Color(0xFF000000),
      rectangleFillColor: Color(0x29000000),
      ovalOutlineColor: Color(0xFF111111),
      ovalSelectedOutlineColor: Color(0xFF000000),
      ovalFillColor: Color(0x29000000),
      freehandStrokeColor: Color(0xFF111111),
      freehandSelectedStrokeColor: Color(0xFF000000),
      textNoteTextColor: Colors.white,
      textNoteBackgroundColor: Color(0xD9333333),
      textNoteBorderColor: Color(0xFF111111),
      textNoteSelectedBorderColor: Color(0xFF000000),
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
