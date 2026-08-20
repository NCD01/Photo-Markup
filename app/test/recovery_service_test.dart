import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/models/area_measurement.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/multi_segment_measurement.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/editable_markup_document.dart';
import 'package:ncd_photo_markup/features/recovery/services/recovery_service.dart';

/// Deletes a scratch folder without letting the cleanup fail the test.
///
/// On Windows a file written moments ago can still be held by the process, and
/// deleteSync throws rather than waiting. The assertions have all run by then.
void _deleteBestEffort(Directory dir) {
  for (int attempt = 0; attempt < 5; attempt++) {
    try {
      if (!dir.existsSync()) {
        return;
      }
      dir.deleteSync(recursive: true);
      return;
    } on FileSystemException {
      sleep(const Duration(milliseconds: 50));
    }
  }
}

void main() {
  late Directory workDir;
  late Directory stateDir;
  late RecoveryService service;
  late String photoPath;

  setUp(() {
    workDir = Directory.systemTemp.createTempSync('ncd_recovery');
    stateDir = Directory('${workDir.path}${Platform.pathSeparator}state')
      ..createSync(recursive: true);
    service = RecoveryService(overrideDirectory: stateDir.path);
    photoPath = '${workDir.path}${Platform.pathSeparator}site.jpg';
    File(photoPath).writeAsBytesSync(<int>[1, 2, 3]);
  });

  tearDown(() => _deleteBestEffort(workDir));

  EditableMarkupDocument documentWith({
    String? sourcePath,
    int marks = 1,
    DateTime? savedAt,
  }) {
    return EditableMarkupDocument(
      schemaVersion: '1.0',
      appVersion: 'test',
      savedAtUtc: (savedAt ?? DateTime.now().toUtc()).toIso8601String(),
      sourceImagePath: sourcePath ?? photoPath,
      sourceImageFileName: 'site.jpg',
      imagePixelSize: const Size(800, 600),
      activeStylePresetId: MarkupStylePresetId.ncdBlue,
      activeFontFamily: 'Default/System',
      activeFontSize: 15,
      nextMarkupId: marks + 1,
      scaleCalibration: null,
      multiSegmentMeasurements: const <MultiSegmentMeasurement>[],
      areaMeasurements: const <AreaMeasurement>[],
      dimensionLines: <DimensionLine>[
        for (int i = 0; i < marks; i++)
          DimensionLine(
            id: i + 1,
            startNormalized: const Offset(0.1, 0.1),
            endNormalized: const Offset(0.6, 0.4),
            label: 'mark $i',
          ),
      ],
      arrows: const <ArrowMarkup>[],
      rectangles: const <RectangleMarkup>[],
      ovals: const <OvalMarkup>[],
      freehands: const <FreehandMarkup>[],
      textNotes: const <TextNoteMarkup>[],
    );
  }

  group('writing', () {
    test('an autosave is written where the settings file lives', () async {
      expect(await service.saveDraft(documentWith()), isTrue);
      expect(File(service.recoveryFilePath).existsSync(), isTrue);
      expect(service.recoveryFilePath, startsWith(stateDir.path));
    });

    test('the source photo is never written to', () async {
      final List<int> before = File(photoPath).readAsBytesSync();
      final DateTime modifiedBefore = File(photoPath).lastModifiedSync();
      await service.saveDraft(documentWith(marks: 3));
      expect(File(photoPath).readAsBytesSync(), before);
      expect(File(photoPath).lastModifiedSync(), modifiedBefore);
    });

    test('a document with no photo is not worth autosaving', () async {
      expect(await service.saveDraft(documentWith(sourcePath: '   ')), isFalse);
      expect(File(service.recoveryFilePath).existsSync(), isFalse);
    });

    test('the previous autosave survives a write that never completes', () async {
      await service.saveDraft(documentWith(marks: 2));
      final String good = File(service.recoveryFilePath).readAsStringSync();
      // A half-written temporary file, as a power cut would leave.
      File('${service.recoveryFilePath}.partial').writeAsStringSync('{"broken"');
      expect(File(service.recoveryFilePath).readAsStringSync(), good);
      final RecoverableDraft? draft = await service.loadDraft();
      expect(draft, isNotNull);
      expect(draft!.markCount, 2);
    });
  });

  group('reading back', () {
    test('a draft comes back with what it needs to be offered', () async {
      await service.saveDraft(documentWith(marks: 4));
      final RecoverableDraft? draft = await service.loadDraft();
      expect(draft, isNotNull);
      expect(draft!.markCount, 4);
      expect(draft.sourceImagePath, photoPath);
      expect(draft.sourceImageFileName, 'site.jpg');
      expect(draft.document.dimensionLines, hasLength(4));
    });

    test('no autosave means nothing to offer', () async {
      expect(await service.loadDraft(), isNull);
    });

    test('an empty markup is not offered', () async {
      await service.saveDraft(documentWith(marks: 0));
      expect(await service.loadDraft(), isNull);
    });
  });

  group('stale and broken autosaves clean themselves up', () {
    test('one that will not parse is deleted rather than offered forever',
        () async {
      Directory(stateDir.path).createSync(recursive: true);
      File(service.recoveryFilePath).writeAsStringSync('not json at all');
      expect(await service.loadDraft(), isNull);
      expect(File(service.recoveryFilePath).existsSync(), isFalse);
    });

    test('one whose photo has been deleted is removed', () async {
      await service.saveDraft(documentWith(marks: 2));
      File(photoPath).deleteSync();
      expect(await service.loadDraft(), isNull);
      expect(File(service.recoveryFilePath).existsSync(), isFalse);
    });

    test('one older than a week is removed', () async {
      await service.saveDraft(
        documentWith(
          marks: 2,
          savedAt: DateTime.now().toUtc().subtract(const Duration(days: 8)),
        ),
      );
      expect(await service.loadDraft(), isNull);
      expect(File(service.recoveryFilePath).existsSync(), isFalse);
    });

    test('one from yesterday is still offered', () async {
      await service.saveDraft(
        documentWith(
          marks: 2,
          savedAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        ),
      );
      expect(await service.loadDraft(), isNotNull);
    });
  });

  group('clearing', () {
    test('clearing removes the autosave and any temporary file', () async {
      await service.saveDraft(documentWith(marks: 2));
      File('${service.recoveryFilePath}.partial').writeAsStringSync('half');
      await service.clearDraft();
      expect(File(service.recoveryFilePath).existsSync(), isFalse);
      expect(File('${service.recoveryFilePath}.partial').existsSync(), isFalse);
    });

    test('clearing when there is nothing to clear does not throw', () async {
      expect(() async => service.clearDraft(), returnsNormally);
    });
  });

  group('the autosave is the same format as a saved markup file', () {
    test('it is valid markup JSON, so recovery is just an open', () async {
      await service.saveDraft(documentWith(marks: 2));
      final Map<String, dynamic> json =
          jsonDecode(File(service.recoveryFilePath).readAsStringSync())
              as Map<String, dynamic>;
      final EditableMarkupDocument reopened =
          EditableMarkupDocument.fromJson(json);
      expect(reopened.dimensionLines, hasLength(2));
      expect(reopened.sourceImagePath, photoPath);
    });
  });
}
