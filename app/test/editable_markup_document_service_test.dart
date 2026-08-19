import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/models/area_measurement.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/editable_markup_document.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/multi_segment_measurement.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/scale_calibration.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/services/editable_markup_document_service.dart';

void main() {
  group('EditableMarkupDocumentService', () {
    const EditableMarkupDocumentService service =
        EditableMarkupDocumentService();

    test('builds default sidecar name from source image', () {
      final String name = service.buildDefaultMarkupFileName(
        sourcePathOrFileName: r'C:\photos\IMG_2434.jpeg',
      );
      expect(name, 'IMG_2434 - Markup.ncdmarkup.json');
    });

    test('builds default sidecar name from HEIC path with spaces', () {
      final String name = service.buildDefaultMarkupFileName(
        sourcePathOrFileName: r'C:\photos\Kitchen Before.HEIC',
      );
      expect(name, 'Kitchen Before - Markup.ncdmarkup.json');
    });

    test('builds default sidecar name from DWG path', () {
      final String name = service.buildDefaultMarkupFileName(
        sourcePathOrFileName: r'C:\plans\Drawing1.dwg',
      );
      expect(name, 'Drawing1 - Markup.ncdmarkup.json');
    });

    test('ensures .ncdmarkup.json extension from bare and .json names', () {
      expect(
        service.ensureEditableMarkupExtension(r'C:\tmp\save_here'),
        r'C:\tmp\save_here.ncdmarkup.json',
      );
      expect(
        service.ensureEditableMarkupExtension(r'C:\tmp\save_here.json'),
        r'C:\tmp\save_here.ncdmarkup.json',
      );
    });

    test('round-trips all markup types and style preset ids', () async {
      final Directory dir = await Directory.systemTemp.createTemp(
        'ncd_markup_doc_test_',
      );
      final File output = File('${dir.path}\\sample.ncdmarkup.json');
      addTearDown(() async {
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      });

      final EditableMarkupDocument document = EditableMarkupDocument(
        schemaVersion: EditableMarkupConstants.schemaVersion,
        appVersion: 'v0.21',
        savedAtUtc: '2026-05-27T00:00:00Z',
        sourceImagePath: r'C:\photos\Kitchen Before.HEIC',
        sourceImageFileName: 'Kitchen Before.HEIC',
        imagePixelSize: const Size(3024, 4032),
        activeStylePresetId: MarkupStylePresetId.yellow,
        activeFontFamily: 'Segoe UI',
        activeFontSize: 18,
        nextMarkupId: 99,
        scaleCalibration: const ScaleCalibration(
          id: 7,
          startNormalized: Offset(0.1, 0.1),
          endNormalized: Offset(0.6, 0.1),
          realDistance: 20,
          unitLabel: 'ft',
          fontFamily: 'Calibri',
          fontSize: 20,
          stylePresetId: MarkupStylePresetId.white,
        ),
        multiSegmentMeasurements: <MultiSegmentMeasurement>[
          MultiSegmentMeasurement(
            id: 8,
            normalizedPoints: const <Offset>[
              Offset(0.2, 0.2),
              Offset(0.4, 0.25),
              Offset(0.55, 0.45),
            ],
            fontFamily: 'Segoe UI',
            fontSize: 16,
            stylePresetId: MarkupStylePresetId.black,
          ),
        ],
        areaMeasurements: <AreaMeasurement>[
          AreaMeasurement(
            id: 9,
            normalizedPoints: const <Offset>[
              Offset(0.2, 0.6),
              Offset(0.45, 0.55),
              Offset(0.5, 0.8),
              Offset(0.25, 0.85),
            ],
            fontFamily: 'Arial',
            fontSize: 17,
            stylePresetId: MarkupStylePresetId.yellow,
          ),
        ],
        dimensionLines: const <DimensionLine>[
          DimensionLine(
            id: 1,
            startNormalized: Offset(0.1, 0.2),
            endNormalized: Offset(0.4, 0.5),
            label: '72"',
            labelOffsetNormalized: Offset(0.08, -0.04),
            fontFamily: 'Arial',
            fontSize: 24,
            stylePresetId: MarkupStylePresetId.red,
          ),
        ],
        arrows: const <ArrowMarkup>[
          ArrowMarkup(
            id: 2,
            startNormalized: Offset(0.2, 0.2),
            endNormalized: Offset(0.8, 0.3),
            stylePresetId: MarkupStylePresetId.white,
          ),
        ],
        rectangles: const <RectangleMarkup>[
          RectangleMarkup(
            id: 3,
            startNormalized: Offset(0.3, 0.3),
            endNormalized: Offset(0.6, 0.7),
            stylePresetId: MarkupStylePresetId.black,
          ),
        ],
        ovals: const <OvalMarkup>[
          OvalMarkup(
            id: 4,
            startNormalized: Offset(0.35, 0.35),
            endNormalized: Offset(0.65, 0.75),
            stylePresetId: MarkupStylePresetId.ncdBlue,
          ),
        ],
        freehands: <FreehandMarkup>[
          FreehandMarkup(
            id: 5,
            normalizedPoints: const <Offset>[
              Offset(0.1, 0.1),
              Offset(0.2, 0.2),
              Offset(0.3, 0.3),
            ],
            stylePresetId: MarkupStylePresetId.red,
          ),
        ],
        textNotes: const <TextNoteMarkup>[
          TextNoteMarkup(
            id: 6,
            anchorNormalized: Offset(0.4, 0.4),
            text: 'Replace drywall here',
            fontFamily: 'Calibri',
            fontSize: 22,
            stylePresetId: MarkupStylePresetId.yellow,
          ),
        ],
      );

      await service.saveDocument(document: document, outputPath: output.path);
      final EditableMarkupDocument reopened = await service.readDocument(
        output.path,
      );

      expect(reopened.schemaVersion, EditableMarkupConstants.schemaVersion);
      expect(reopened.activeStylePresetId, MarkupStylePresetId.yellow);
      expect(reopened.activeFontFamily, 'Segoe UI');
      expect(reopened.activeFontSize, 18);
      expect(reopened.scaleCalibration, isNotNull);
      expect(reopened.scaleCalibration!.realDistance, 20);
      expect(reopened.scaleCalibration!.unitLabel, 'ft');
      expect(reopened.scaleCalibration!.fontFamily, 'Calibri');
      expect(reopened.scaleCalibration!.fontSize, 20);
      expect(
        reopened.scaleCalibration!.stylePresetId,
        MarkupStylePresetId.white,
      );
      expect(reopened.multiSegmentMeasurements, hasLength(1));
      expect(
        reopened.multiSegmentMeasurements.single.stylePresetId,
        MarkupStylePresetId.black,
      );
      expect(
        reopened.multiSegmentMeasurements.single.normalizedPoints,
        const <Offset>[Offset(0.2, 0.2), Offset(0.4, 0.25), Offset(0.55, 0.45)],
      );
      expect(reopened.areaMeasurements, hasLength(1));
      expect(
        reopened.areaMeasurements.single.stylePresetId,
        MarkupStylePresetId.yellow,
      );
      expect(reopened.areaMeasurements.single.normalizedPoints, const <Offset>[
        Offset(0.2, 0.6),
        Offset(0.45, 0.55),
        Offset(0.5, 0.8),
        Offset(0.25, 0.85),
      ]);
      expect(
        reopened.dimensionLines.single.stylePresetId,
        MarkupStylePresetId.red,
      );
      expect(reopened.arrows.single.stylePresetId, MarkupStylePresetId.white);
      expect(
        reopened.rectangles.single.stylePresetId,
        MarkupStylePresetId.black,
      );
      expect(reopened.ovals.single.stylePresetId, MarkupStylePresetId.ncdBlue);
      expect(reopened.freehands.single.stylePresetId, MarkupStylePresetId.red);
      expect(
        reopened.textNotes.single.stylePresetId,
        MarkupStylePresetId.yellow,
      );
      expect(reopened.dimensionLines.single.label, '72"');
      expect(
        reopened.dimensionLines.single.labelOffsetNormalized,
        const Offset(0.08, -0.04),
      );
      expect(reopened.dimensionLines.single.fontFamily, 'Arial');
      expect(reopened.dimensionLines.single.fontSize, 24);
      expect(reopened.textNotes.single.fontFamily, 'Calibri');
      expect(reopened.textNotes.single.fontSize, 22);
      expect(reopened.nextMarkupId, 99);
      expect(reopened.sourceImagePath, r'C:\photos\Kitchen Before.HEIC');
      expect(reopened.imagePixelSize, const Size(3024, 4032));
    });

    test('reads legacy markup files with default typography values', () async {
      final Directory dir = await Directory.systemTemp.createTemp(
        'ncd_markup_doc_legacy_',
      );
      final File legacyFile = File('${dir.path}\\legacy.ncdmarkup.json');
      addTearDown(() async {
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      });

      await legacyFile.writeAsString('''
{
  "schemaVersion": "1.0",
  "appVersion": "v0.20",
  "savedAtUtc": "2026-05-27T00:00:00Z",
  "sourceImagePath": "C:\\\\photos\\\\legacy.jpg",
  "sourceImageFileName": "legacy.jpg",
  "image": {
    "pixelWidth": 1200,
    "pixelHeight": 800
  },
  "activeStylePresetId": "ncdBlue",
  "nextMarkupId": 2,
  "dimensionLines": [
    {
      "id": 1,
      "startNormalized": {"x": 0.1, "y": 0.2},
      "endNormalized": {"x": 0.6, "y": 0.2},
      "label": "48\\"",
      "stylePresetId": "red"
    }
  ],
  "textNotes": [
    {
      "id": 2,
      "anchorNormalized": {"x": 0.3, "y": 0.4},
      "text": "Legacy note",
      "stylePresetId": "yellow"
    }
  ]
}
''');

      final EditableMarkupDocument reopened = await service.readDocument(
        legacyFile.path,
      );

      expect(
        reopened.activeFontFamily,
        MarkupTypographyConstants.defaultFontFamily,
      );
      expect(
        reopened.activeFontSize,
        MarkupTypographyConstants.defaultFontSize,
      );
      expect(
        reopened.dimensionLines.single.fontFamily,
        MarkupTypographyConstants.defaultFontFamily,
      );
      expect(
        reopened.dimensionLines.single.fontSize,
        MarkupTypographyConstants.defaultFontSize,
      );
      expect(reopened.dimensionLines.single.labelOffsetNormalized, isNull);
      expect(
        reopened.textNotes.single.fontFamily,
        MarkupTypographyConstants.defaultFontFamily,
      );
      expect(
        reopened.textNotes.single.fontSize,
        MarkupTypographyConstants.defaultFontSize,
      );
    });

    test('throws on corrupt json and unsupported schema', () async {
      final Directory dir = await Directory.systemTemp.createTemp(
        'ncd_markup_doc_error_',
      );
      final File badJson = File('${dir.path}\\bad.ncdmarkup.json');
      final File badSchema = File('${dir.path}\\bad_schema.ncdmarkup.json');
      addTearDown(() async {
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      });

      await badJson.writeAsString('not json');
      await badSchema.writeAsString('{"schemaVersion":"9.9"}');

      expect(
        () => service.readDocument(badJson.path),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => service.readDocument(badSchema.path),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
