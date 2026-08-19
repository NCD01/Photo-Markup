import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/callout_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/editable_markup_document.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/session/models/session_preferences.dart';
import 'package:ncd_photo_markup/features/session/services/app_data_directory.dart';
import 'package:ncd_photo_markup/features/session/services/session_state_service.dart';

EditableMarkupDocument documentFor(
  String sourcePath, {
  List<ArrowMarkup> arrows = const <ArrowMarkup>[],
}) {
  return EditableMarkupDocument(
    schemaVersion: EditableMarkupConstants.schemaVersion,
    appVersion: AppConstants.appVersion,
    savedAtUtc: DateTime.utc(2026, 1, 2, 3, 4, 5).toIso8601String(),
    sourceImagePath: sourcePath,
    sourceImageFileName: sourcePath.split(Platform.pathSeparator).last,
    imagePixelSize: null,
    activeStylePresetId: MarkupStylePresets.defaultPresetId,
    activeFontFamily: MarkupTypographyConstants.defaultFontFamily,
    activeFontSize: MarkupTypographyConstants.defaultFontSize,
    nextMarkupId: 2,
    dimensionLines: const <DimensionLine>[],
    arrows: arrows,
    rectangles: const <RectangleMarkup>[],
    ovals: const <OvalMarkup>[],
    freehands: const <FreehandMarkup>[],
    textNotes: const <TextNoteMarkup>[],
  );
}

void main() {
  late Directory workDir;
  late SessionStateService service;
  late String photoPath;
  late String stateDir;

  setUp(() {
    workDir = Directory.systemTemp.createTempSync('ncd_session_test');
    service = SessionStateService.inMemoryFolder(workDir.path);
    stateDir = AppDataDirectory(
      environment: const <String, String>{},
      fallbackPath: workDir.path,
    ).resolvePath();
    Directory(stateDir).createSync(recursive: true);
    photoPath = '${workDir.path}${Platform.pathSeparator}photo.jpg';
    File(photoPath).writeAsBytesSync(<int>[1, 2, 3]);
  });

  tearDown(() {
    if (workDir.existsSync()) {
      workDir.deleteSync(recursive: true);
    }
  });

  group('app data directory', () {
    test('prefers APPDATA when it is set', () {
      const AppDataDirectory directory = AppDataDirectory(
        environment: <String, String>{'APPDATA': '/appdata', 'HOME': '/home/x'},
      );
      expect(
        directory.resolvePath(),
        contains(SessionStateConstants.folderName),
      );
      expect(directory.resolvePath(), startsWith('/appdata'));
    });

    test('uses a dotted config folder under HOME', () {
      const AppDataDirectory directory = AppDataDirectory(
        environment: <String, String>{'HOME': '/home/x'},
      );
      expect(directory.resolvePath(), contains('.config'));
      expect(directory.resolvePath(), startsWith('/home/x'));
    });

    test('falls back rather than failing when nothing is set', () {
      const AppDataDirectory directory = AppDataDirectory(
        environment: <String, String>{},
        fallbackPath: '/tmp/fallback',
      );
      expect(directory.resolvePath(), startsWith('/tmp/fallback'));
    });
  });

  group('preferences', () {
    test('a first run gets the defaults', () async {
      final SessionPreferences preferences = await service.loadPreferences();
      expect(preferences.tool, SessionPreferences.defaults.tool);
      expect(preferences.stylePresetId, MarkupStylePresets.defaultPresetId);
    });

    test('tool, colour and width survive a restart', () async {
      const SessionPreferences saved = SessionPreferences(
        tool: MarkupTool.highlighter,
        stylePresetId: MarkupStylePresetId.orange,
        strokeWidthScale: MarkupStrokeConstants.heavy,
        shapesFilled: true,
        calloutLabelStyle: CalloutLabelStyle.letters,
        sidebarExpanded: true,
      );
      expect(await service.savePreferences(saved), isTrue);

      final SessionPreferences loaded = await service.loadPreferences();
      expect(loaded.tool, MarkupTool.highlighter);
      expect(loaded.stylePresetId, MarkupStylePresetId.orange);
      expect(loaded.strokeWidthScale, MarkupStrokeConstants.heavy);
      expect(loaded.shapesFilled, isTrue);
      expect(loaded.calloutLabelStyle, CalloutLabelStyle.letters);
      expect(loaded.sidebarExpanded, isTrue);
    });

    test(
      'a tap-to-create tool is not restored, to avoid a stray mark',
      () async {
        for (final MarkupTool tool in SessionPreferences.notRestorable) {
          await service.savePreferences(SessionPreferences(tool: tool));
          final SessionPreferences loaded = await service.loadPreferences();
          expect(loaded.tool, MarkupTool.none);
        }
      },
    );

    test('a corrupt preferences file does not stop the app', () async {
      final File file = File(
        '$stateDir${Platform.pathSeparator}'
        '${SessionStateConstants.preferencesFileName}',
      );
      await file.writeAsString('{not json at all');
      final SessionPreferences loaded = await service.loadPreferences();
      expect(loaded.tool, SessionPreferences.defaults.tool);
    });

    test('a nonsense stroke width is clamped on read', () async {
      final File file = File(
        '$stateDir${Platform.pathSeparator}'
        '${SessionStateConstants.preferencesFileName}',
      );
      await file.writeAsString(
        jsonEncode(<String, dynamic>{
          'strokeWidthScale': 9999,
          'tool': 'arrow',
        }),
      );
      final SessionPreferences loaded = await service.loadPreferences();
      expect(loaded.strokeWidthScale, MarkupStrokeConstants.maxScale);
    });
  });

  group('autosave and recovery', () {
    test('nothing to recover on a clean first run', () async {
      expect(await service.loadDraft(), isNull);
    });

    test('a draft round-trips and can be restored', () async {
      final EditableMarkupDocument document = documentFor(
        photoPath,
        arrows: const <ArrowMarkup>[
          ArrowMarkup(
            id: 1,
            startNormalized: Offset(0.1, 0.1),
            endNormalized: Offset(0.6, 0.7),
          ),
        ],
      );
      expect(await service.saveDraft(document), isTrue);

      final RecoverableDraft? draft = await service.loadDraft();
      expect(draft, isNotNull);
      expect(draft!.sourceImagePath, photoPath);
      expect(draft.document.arrows.length, 1);
      expect(draft.savedAtUtc, isNotNull);
    });

    test('an empty draft is not worth interrupting the user for', () async {
      await service.saveDraft(documentFor(photoPath));
      expect(await service.loadDraft(), isNull);
    });

    test('a draft whose photo has been moved is dropped', () async {
      await service.saveDraft(
        documentFor(
          photoPath,
          arrows: const <ArrowMarkup>[
            ArrowMarkup(
              id: 1,
              startNormalized: Offset(0, 0),
              endNormalized: Offset(1, 1),
            ),
          ],
        ),
      );
      File(photoPath).deleteSync();
      expect(await service.loadDraft(), isNull);
    });

    test('a draft with no photo path is refused at write time', () async {
      expect(await service.saveDraft(documentFor('   ')), isFalse);
    });

    test('clearing removes the draft and any partial file', () async {
      await service.saveDraft(
        documentFor(
          photoPath,
          arrows: const <ArrowMarkup>[
            ArrowMarkup(
              id: 1,
              startNormalized: Offset(0, 0),
              endNormalized: Offset(1, 1),
            ),
          ],
        ),
      );
      expect(await service.loadDraft(), isNotNull);
      await service.clearDraft();
      expect(await service.loadDraft(), isNull);
      expect(
        File(
          '$stateDir${Platform.pathSeparator}'
          '${SessionStateConstants.draftFileName}'
          '${SessionStateConstants.partialSuffix}',
        ).existsSync(),
        isFalse,
      );
    });

    test('a half-written draft never replaces a good one', () async {
      final EditableMarkupDocument good = documentFor(
        photoPath,
        arrows: const <ArrowMarkup>[
          ArrowMarkup(
            id: 1,
            startNormalized: Offset(0, 0),
            endNormalized: Offset(1, 1),
          ),
        ],
      );
      await service.saveDraft(good);

      // Simulate a process dying mid-write: a partial file is left behind.
      await File(
        '$stateDir${Platform.pathSeparator}'
        '${SessionStateConstants.draftFileName}'
        '${SessionStateConstants.partialSuffix}',
      ).writeAsString('{"schemaVersion":"1.0"');

      final RecoverableDraft? draft = await service.loadDraft();
      expect(draft, isNotNull);
      expect(draft!.document.arrows.length, 1);
    });

    test('a corrupt draft is ignored rather than thrown', () async {
      await File(
        '$stateDir${Platform.pathSeparator}'
        '${SessionStateConstants.draftFileName}',
      ).writeAsString('not json');
      expect(await service.loadDraft(), isNull);
    });
  });
}
