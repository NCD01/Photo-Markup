import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/editable_markup_document.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
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
        nextMarkupId: 99,
        dimensionLines: const <DimensionLine>[
          DimensionLine(
            id: 1,
            startNormalized: Offset(0.1, 0.2),
            endNormalized: Offset(0.4, 0.5),
            label: '72"',
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
      expect(reopened.nextMarkupId, 99);
      expect(reopened.sourceImagePath, r'C:\photos\Kitchen Before.HEIC');
      expect(reopened.imagePixelSize, const Size(3024, 4032));
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
