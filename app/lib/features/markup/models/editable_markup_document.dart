import 'dart:ui';

import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/blur_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/callout_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';

class EditableMarkupDocument {
  const EditableMarkupDocument({
    required this.schemaVersion,
    required this.appVersion,
    required this.savedAtUtc,
    required this.sourceImagePath,
    required this.sourceImageFileName,
    required this.imagePixelSize,
    required this.activeStylePresetId,
    required this.activeFontFamily,
    required this.activeFontSize,
    required this.nextMarkupId,
    required this.dimensionLines,
    required this.arrows,
    required this.rectangles,
    required this.ovals,
    required this.freehands,
    required this.textNotes,
    this.callouts = const <CalloutMarkup>[],
    this.blurs = const <BlurMarkup>[],
  });

  final String schemaVersion;
  final String appVersion;
  final String savedAtUtc;
  final String sourceImagePath;
  final String sourceImageFileName;
  final Size? imagePixelSize;
  final MarkupStylePresetId activeStylePresetId;
  final String activeFontFamily;
  final double activeFontSize;
  final int nextMarkupId;
  final List<DimensionLine> dimensionLines;
  final List<ArrowMarkup> arrows;
  final List<RectangleMarkup> rectangles;
  final List<OvalMarkup> ovals;
  final List<FreehandMarkup> freehands;
  final List<TextNoteMarkup> textNotes;
  final List<CalloutMarkup> callouts;
  final List<BlurMarkup> blurs;

  factory EditableMarkupDocument.fromJson(Map<String, dynamic> json) {
    final String schemaVersion = (json['schemaVersion'] ?? '')
        .toString()
        .trim();
    if (schemaVersion != EditableMarkupConstants.schemaVersion) {
      throw const FormatException(
        'Unsupported editable markup schema version.',
      );
    }

    final Map<String, dynamic> imageMeta =
        _asMap(json['image']) ?? <String, dynamic>{};
    final double? pixelWidth = _asDouble(imageMeta['pixelWidth']);
    final double? pixelHeight = _asDouble(imageMeta['pixelHeight']);

    return EditableMarkupDocument(
      schemaVersion: schemaVersion,
      appVersion: (json['appVersion'] ?? '').toString(),
      savedAtUtc: (json['savedAtUtc'] ?? '').toString(),
      sourceImagePath: (json['sourceImagePath'] ?? '').toString(),
      sourceImageFileName: (json['sourceImageFileName'] ?? '').toString(),
      imagePixelSize: pixelWidth != null && pixelHeight != null
          ? Size(pixelWidth, pixelHeight)
          : null,
      activeStylePresetId: _stylePresetFromValue(json['activeStylePresetId']),
      activeFontFamily: _fontFamilyFromValue(json['activeFontFamily']),
      activeFontSize: _fontSizeFromValue(json['activeFontSize']),
      nextMarkupId: _asInt(json['nextMarkupId']) ?? 1,
      dimensionLines: _readDimensionLines(json['dimensionLines']),
      arrows: _readArrows(json['arrows']),
      rectangles: _readRectangles(json['rectangles']),
      ovals: _readOvals(json['ovals']),
      freehands: _readFreehands(json['freehands']),
      textNotes: _readTextNotes(json['textNotes']),
      callouts: _readCallouts(json['callouts']),
      blurs: _readBlurs(json['blurs']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'appVersion': appVersion,
      'savedAtUtc': savedAtUtc,
      'sourceImagePath': sourceImagePath,
      'sourceImageFileName': sourceImageFileName,
      'image': <String, dynamic>{
        if (imagePixelSize != null) 'pixelWidth': imagePixelSize!.width,
        if (imagePixelSize != null) 'pixelHeight': imagePixelSize!.height,
      },
      'activeStylePresetId': activeStylePresetId.name,
      'activeFontFamily': activeFontFamily,
      'activeFontSize': activeFontSize,
      'nextMarkupId': nextMarkupId,
      'dimensionLines': dimensionLines
          .map(
            (DimensionLine line) => <String, dynamic>{
              'id': line.id,
              'startNormalized': _offsetToJson(line.startNormalized),
              'endNormalized': _offsetToJson(line.endNormalized),
              'label': line.label,
              if (line.labelOffsetNormalized != null)
                'labelOffsetNormalized': _offsetToJson(
                  line.labelOffsetNormalized!,
                ),
              'fontFamily': line.fontFamily,
              'fontSize': line.fontSize,
              'stylePresetId': line.stylePresetId.name,
              'strokeWidthScale': line.strokeWidthScale,
            },
          )
          .toList(growable: false),
      'arrows': arrows
          .map(
            (ArrowMarkup arrow) => <String, dynamic>{
              'id': arrow.id,
              'startNormalized': _offsetToJson(arrow.startNormalized),
              'endNormalized': _offsetToJson(arrow.endNormalized),
              'stylePresetId': arrow.stylePresetId.name,
              'strokeWidthScale': arrow.strokeWidthScale,
              'hasHead': arrow.hasHead,
            },
          )
          .toList(growable: false),
      'rectangles': rectangles
          .map(
            (RectangleMarkup rectangle) => <String, dynamic>{
              'id': rectangle.id,
              'startNormalized': _offsetToJson(rectangle.startNormalized),
              'endNormalized': _offsetToJson(rectangle.endNormalized),
              'stylePresetId': rectangle.stylePresetId.name,
              'strokeWidthScale': rectangle.strokeWidthScale,
              'filled': rectangle.filled,
            },
          )
          .toList(growable: false),
      'ovals': ovals
          .map(
            (OvalMarkup oval) => <String, dynamic>{
              'id': oval.id,
              'startNormalized': _offsetToJson(oval.startNormalized),
              'endNormalized': _offsetToJson(oval.endNormalized),
              'stylePresetId': oval.stylePresetId.name,
              'strokeWidthScale': oval.strokeWidthScale,
              'filled': oval.filled,
            },
          )
          .toList(growable: false),
      'freehands': freehands
          .map(
            (FreehandMarkup freehand) => <String, dynamic>{
              'id': freehand.id,
              'normalizedPoints': freehand.normalizedPoints
                  .map(_offsetToJson)
                  .toList(growable: false),
              'stylePresetId': freehand.stylePresetId.name,
              'strokeWidthScale': freehand.strokeWidthScale,
              'isHighlighter': freehand.isHighlighter,
            },
          )
          .toList(growable: false),
      'textNotes': textNotes
          .map(
            (TextNoteMarkup note) => <String, dynamic>{
              'id': note.id,
              'anchorNormalized': _offsetToJson(note.anchorNormalized),
              'text': note.text,
              'fontFamily': note.fontFamily,
              'fontSize': note.fontSize,
              'stylePresetId': note.stylePresetId.name,
            },
          )
          .toList(growable: false),
      'callouts': callouts
          .map(
            (CalloutMarkup callout) => <String, dynamic>{
              'id': callout.id,
              'anchorNormalized': _offsetToJson(callout.anchorNormalized),
              'sequence': callout.sequence,
              'labelStyle': callout.labelStyle.name,
              'stylePresetId': callout.stylePresetId.name,
              'sizeScale': callout.sizeScale,
            },
          )
          .toList(growable: false),
      'blurs': blurs
          .map(
            (BlurMarkup blur) => <String, dynamic>{
              'id': blur.id,
              'startNormalized': _offsetToJson(blur.startNormalized),
              'endNormalized': _offsetToJson(blur.endNormalized),
              'strengthScale': blur.strengthScale,
            },
          )
          .toList(growable: false),
    };
  }

  static List<CalloutMarkup> _readCallouts(dynamic raw) {
    if (raw is! List) {
      return const <CalloutMarkup>[];
    }
    final List<CalloutMarkup> callouts = <CalloutMarkup>[];
    for (final dynamic item in raw) {
      final Map<String, dynamic>? map = _asMap(item);
      if (map == null) {
        continue;
      }
      final int? id = _asInt(map['id']);
      final Offset? anchor = _offsetFromJson(map['anchorNormalized']);
      if (id == null || anchor == null) {
        continue;
      }
      callouts.add(
        CalloutMarkup(
          id: id,
          anchorNormalized: anchor,
          sequence: _asInt(map['sequence']) ?? 1,
          labelStyle: CalloutMarkup.labelStyleFromName(
            map['labelStyle']?.toString(),
          ),
          stylePresetId: _stylePresetFromValue(map['stylePresetId']),
          sizeScale: _strokeScaleFromValue(map['sizeScale']),
        ),
      );
    }
    return List<CalloutMarkup>.unmodifiable(callouts);
  }

  static List<BlurMarkup> _readBlurs(dynamic raw) {
    if (raw is! List) {
      return const <BlurMarkup>[];
    }
    final List<BlurMarkup> blurs = <BlurMarkup>[];
    for (final dynamic item in raw) {
      final Map<String, dynamic>? map = _asMap(item);
      if (map == null) {
        continue;
      }
      final int? id = _asInt(map['id']);
      final Offset? start = _offsetFromJson(map['startNormalized']);
      final Offset? end = _offsetFromJson(map['endNormalized']);
      if (id == null || start == null || end == null) {
        continue;
      }
      blurs.add(
        BlurMarkup(
          id: id,
          startNormalized: start,
          endNormalized: end,
          strengthScale: _strokeScaleFromValue(map['strengthScale']),
        ),
      );
    }
    return List<BlurMarkup>.unmodifiable(blurs);
  }

  static List<DimensionLine> _readDimensionLines(dynamic raw) {
    if (raw is! List) {
      return const <DimensionLine>[];
    }
    final List<DimensionLine> lines = <DimensionLine>[];
    for (final dynamic item in raw) {
      final Map<String, dynamic>? map = _asMap(item);
      if (map == null) {
        continue;
      }
      final int? id = _asInt(map['id']);
      final Offset? start = _offsetFromJson(map['startNormalized']);
      final Offset? end = _offsetFromJson(map['endNormalized']);
      if (id == null || start == null || end == null) {
        continue;
      }
      lines.add(
        DimensionLine(
          id: id,
          startNormalized: start,
          endNormalized: end,
          label: map['label']?.toString(),
          labelOffsetNormalized: _offsetFromJson(map['labelOffsetNormalized']),
          fontFamily: _fontFamilyFromValue(map['fontFamily']),
          fontSize: _fontSizeFromValue(map['fontSize']),
          stylePresetId: _stylePresetFromValue(map['stylePresetId']),
          strokeWidthScale: _strokeScaleFromValue(map['strokeWidthScale']),
        ),
      );
    }
    return List<DimensionLine>.unmodifiable(lines);
  }

  static List<ArrowMarkup> _readArrows(dynamic raw) {
    if (raw is! List) {
      return const <ArrowMarkup>[];
    }
    final List<ArrowMarkup> arrows = <ArrowMarkup>[];
    for (final dynamic item in raw) {
      final Map<String, dynamic>? map = _asMap(item);
      if (map == null) {
        continue;
      }
      final int? id = _asInt(map['id']);
      final Offset? start = _offsetFromJson(map['startNormalized']);
      final Offset? end = _offsetFromJson(map['endNormalized']);
      if (id == null || start == null || end == null) {
        continue;
      }
      arrows.add(
        ArrowMarkup(
          id: id,
          startNormalized: start,
          endNormalized: end,
          stylePresetId: _stylePresetFromValue(map['stylePresetId']),
          strokeWidthScale: _strokeScaleFromValue(map['strokeWidthScale']),
          hasHead: _boolFromValue(map['hasHead'], fallback: true),
        ),
      );
    }
    return List<ArrowMarkup>.unmodifiable(arrows);
  }

  static List<RectangleMarkup> _readRectangles(dynamic raw) {
    if (raw is! List) {
      return const <RectangleMarkup>[];
    }
    final List<RectangleMarkup> rectangles = <RectangleMarkup>[];
    for (final dynamic item in raw) {
      final Map<String, dynamic>? map = _asMap(item);
      if (map == null) {
        continue;
      }
      final int? id = _asInt(map['id']);
      final Offset? start = _offsetFromJson(map['startNormalized']);
      final Offset? end = _offsetFromJson(map['endNormalized']);
      if (id == null || start == null || end == null) {
        continue;
      }
      rectangles.add(
        RectangleMarkup(
          id: id,
          startNormalized: start,
          endNormalized: end,
          stylePresetId: _stylePresetFromValue(map['stylePresetId']),
          strokeWidthScale: _strokeScaleFromValue(map['strokeWidthScale']),
          filled: _boolFromValue(map['filled'], fallback: false),
        ),
      );
    }
    return List<RectangleMarkup>.unmodifiable(rectangles);
  }

  static List<OvalMarkup> _readOvals(dynamic raw) {
    if (raw is! List) {
      return const <OvalMarkup>[];
    }
    final List<OvalMarkup> ovals = <OvalMarkup>[];
    for (final dynamic item in raw) {
      final Map<String, dynamic>? map = _asMap(item);
      if (map == null) {
        continue;
      }
      final int? id = _asInt(map['id']);
      final Offset? start = _offsetFromJson(map['startNormalized']);
      final Offset? end = _offsetFromJson(map['endNormalized']);
      if (id == null || start == null || end == null) {
        continue;
      }
      ovals.add(
        OvalMarkup(
          id: id,
          startNormalized: start,
          endNormalized: end,
          stylePresetId: _stylePresetFromValue(map['stylePresetId']),
          strokeWidthScale: _strokeScaleFromValue(map['strokeWidthScale']),
          filled: _boolFromValue(map['filled'], fallback: false),
        ),
      );
    }
    return List<OvalMarkup>.unmodifiable(ovals);
  }

  static List<FreehandMarkup> _readFreehands(dynamic raw) {
    if (raw is! List) {
      return const <FreehandMarkup>[];
    }
    final List<FreehandMarkup> freehands = <FreehandMarkup>[];
    for (final dynamic item in raw) {
      final Map<String, dynamic>? map = _asMap(item);
      if (map == null) {
        continue;
      }
      final int? id = _asInt(map['id']);
      if (id == null) {
        continue;
      }
      final List<Offset> points = <Offset>[];
      final dynamic rawPoints = map['normalizedPoints'];
      if (rawPoints is List) {
        for (final dynamic rawPoint in rawPoints) {
          final Offset? point = _offsetFromJson(rawPoint);
          if (point != null) {
            points.add(point);
          }
        }
      }
      freehands.add(
        FreehandMarkup(
          id: id,
          normalizedPoints: points,
          stylePresetId: _stylePresetFromValue(map['stylePresetId']),
          strokeWidthScale: _strokeScaleFromValue(map['strokeWidthScale']),
          isHighlighter: _boolFromValue(map['isHighlighter'], fallback: false),
        ),
      );
    }
    return List<FreehandMarkup>.unmodifiable(freehands);
  }

  static List<TextNoteMarkup> _readTextNotes(dynamic raw) {
    if (raw is! List) {
      return const <TextNoteMarkup>[];
    }
    final List<TextNoteMarkup> notes = <TextNoteMarkup>[];
    for (final dynamic item in raw) {
      final Map<String, dynamic>? map = _asMap(item);
      if (map == null) {
        continue;
      }
      final int? id = _asInt(map['id']);
      final Offset? anchor = _offsetFromJson(map['anchorNormalized']);
      if (id == null || anchor == null) {
        continue;
      }
      notes.add(
        TextNoteMarkup(
          id: id,
          anchorNormalized: anchor,
          text: (map['text'] ?? '').toString(),
          fontFamily: _fontFamilyFromValue(map['fontFamily']),
          fontSize: _fontSizeFromValue(map['fontSize']),
          stylePresetId: _stylePresetFromValue(map['stylePresetId']),
        ),
      );
    }
    return List<TextNoteMarkup>.unmodifiable(notes);
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic mapValue) =>
            MapEntry<String, dynamic>(key.toString(), mapValue),
      );
    }
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static Offset? _offsetFromJson(dynamic value) {
    final Map<String, dynamic>? map = _asMap(value);
    if (map == null) {
      return null;
    }
    final double? x = _asDouble(map['x']);
    final double? y = _asDouble(map['y']);
    if (x == null || y == null) {
      return null;
    }
    return Offset(x, y);
  }

  static Map<String, dynamic> _offsetToJson(Offset offset) {
    return <String, dynamic>{'x': offset.dx, 'y': offset.dy};
  }

  /// Fields added after schema 1.0 shipped are all optional on read, so a
  /// markup file written by an older build still opens with sane defaults.
  static double _strokeScaleFromValue(dynamic value) {
    return MarkupStrokeConstants.normalizeScale(_asDouble(value));
  }

  static bool _boolFromValue(dynamic value, {required bool fallback}) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }
    return fallback;
  }

  static MarkupStylePresetId _stylePresetFromValue(dynamic value) {
    final String normalized = (value ?? '').toString().trim();
    for (final MarkupStylePresetId id in MarkupStylePresetId.values) {
      if (id.name == normalized) {
        return id;
      }
    }
    return MarkupStylePresets.defaultPresetId;
  }

  static String _fontFamilyFromValue(dynamic value) {
    final String normalized = (value ?? '').toString().trim();
    for (final String allowed
        in MarkupTypographyConstants.allowedFontFamilies) {
      if (allowed == normalized) {
        return allowed;
      }
    }
    return MarkupTypographyConstants.defaultFontFamily;
  }

  static double _fontSizeFromValue(dynamic value) {
    final double raw =
        _asDouble(value) ?? MarkupTypographyConstants.defaultFontSize;
    return raw.clamp(
      MarkupTypographyConstants.minFontSize,
      MarkupTypographyConstants.maxFontSize,
    );
  }
}
