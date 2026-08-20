import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/integration/models/photo_markup_launch_context.dart';
import 'package:ncd_photo_markup/features/jobs/models/job_group.dart';
import 'package:ncd_photo_markup/features/jobs/services/job_index_service.dart';
import 'package:ncd_photo_markup/features/markup/models/area_measurement.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/editable_markup_document.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/multi_segment_measurement.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/recovery/services/recovery_service.dart';

/// Measured, not guessed.
///
/// These are the two paths that run repeatedly while someone is working on a
/// big photo: the autosave, which fires every time the hand stops, and the job
/// index, which is rewritten on every save and every export. Both are timed
/// here against a deliberately heavy document so a regression shows up as a
/// number rather than as a feeling.
///
/// The thresholds are generous on purpose. They exist to catch something
/// getting an order of magnitude worse, not to fail on a busy machine.

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

/// A photo with a lot of work on it: 200 freehand strokes of 120 points each,
/// which is what an hour of marking up a wide elevation shot looks like.
EditableMarkupDocument _heavyDocument({
  required String photoPath,
  int strokes = 200,
  int pointsPerStroke = 120,
}) {
  return EditableMarkupDocument(
    schemaVersion: '1.0',
    appVersion: 'bench',
    savedAtUtc: DateTime.utc(2026, 8, 20).toIso8601String(),
    sourceImagePath: photoPath,
    sourceImageFileName: 'huge.jpg',
    imagePixelSize: const Size(6000, 4000),
    activeStylePresetId: MarkupStylePresetId.ncdBlue,
    activeFontFamily: 'Default/System',
    activeFontSize: 15,
    nextMarkupId: strokes + 1,
    scaleCalibration: null,
    multiSegmentMeasurements: const <MultiSegmentMeasurement>[],
    areaMeasurements: const <AreaMeasurement>[],
    dimensionLines: const <DimensionLine>[],
    arrows: const <ArrowMarkup>[],
    rectangles: const <RectangleMarkup>[],
    ovals: const <OvalMarkup>[],
    freehands: <FreehandMarkup>[
      for (int i = 0; i < strokes; i++)
        FreehandMarkup(
          id: i + 1,
          normalizedPoints: <Offset>[
            for (int p = 0; p < pointsPerStroke; p++)
              Offset(
                (p % 100) / 100,
                ((i * 7 + p * 3) % 100) / 100,
              ),
          ],
        ),
    ],
    textNotes: const <TextNoteMarkup>[],
  );
}

int _medianMillis(List<int> samples) {
  final List<int> sorted = <int>[...samples]..sort();
  return sorted[sorted.length ~/ 2];
}

void main() {
  late Directory workDir;

  setUp(() {
    workDir = Directory.systemTemp.createTempSync('ncd_perf');
  });

  tearDown(() => _deleteBestEffort(workDir));

  test('autosaving a heavy document stays well inside a debounce', () async {
    final String photoPath = '${workDir.path}${Platform.pathSeparator}huge.jpg';
    File(photoPath).writeAsBytesSync(<int>[1, 2, 3]);
    final RecoveryService service = RecoveryService(
      overrideDirectory: workDir.path,
    );
    final EditableMarkupDocument document = _heavyDocument(
      photoPath: photoPath,
    );

    // Warm the file system cache so the first run is not the measurement.
    await service.saveDraft(document);

    final List<int> samples = <int>[];
    for (int run = 0; run < 5; run++) {
      final Stopwatch watch = Stopwatch()..start();
      await service.saveDraft(document);
      watch.stop();
      samples.add(watch.elapsedMilliseconds);
    }

    final int median = _medianMillis(samples);
    final int bytes = File(service.recoveryFilePath).lengthSync();
    // ignore: avoid_print
    print(
      'BENCH autosave 200x120 points: median ${median}ms, '
      'file ${(bytes / 1024).round()} KB, samples $samples',
    );

    // The autosave runs while someone is drawing. Anything approaching the
    // shortest selectable interval, five seconds, would be a defect.
    expect(median, lessThan(1000));
  });

  test('the job index stays quick with a full index', () async {
    final JobIndexService service = JobIndexService(
      overrideDirectory: workDir.path,
    );
    const PhotoMarkupLaunchContext context = PhotoMarkupLaunchContext(
      launchedFromControlCenter: true,
    );

    // A machine that has been in use for a long time: 40 jobs, 50 photos each.
    final String sep = Platform.pathSeparator;
    for (int job = 0; job < 40; job++) {
      for (int photo = 0; photo < 50; photo++) {
        await service.recordPhoto(
          sourceImagePath: 'C:${sep}Jobs${sep}Job$job${sep}p$photo.jpg',
          sourceImageFileName: 'p$photo.jpg',
          openedAtUtc: DateTime.utc(2026, 8, 20, 12),
          launchContext: context,
        );
      }
    }

    final List<JobGroup> jobs = await service.load();
    expect(jobs, hasLength(40));

    final List<int> samples = <int>[];
    for (int run = 0; run < 5; run++) {
      final Stopwatch watch = Stopwatch()..start();
      await service.recordPhoto(
        sourceImagePath: 'C:${sep}Jobs${sep}Job0${sep}new$run.jpg',
        sourceImageFileName: 'new$run.jpg',
        openedAtUtc: DateTime.utc(2026, 8, 20, 13),
        launchContext: context,
      );
      watch.stop();
      samples.add(watch.elapsedMilliseconds);
    }

    final int median = _medianMillis(samples);
    final int bytes = File(service.indexFilePath).lengthSync();
    // ignore: avoid_print
    print(
      'BENCH job index record with 40x50 entries: median ${median}ms, '
      'file ${(bytes / 1024).round()} KB, samples $samples',
    );

    // This runs on every save and every export, so it has to be invisible.
    expect(median, lessThan(500));
  });

  test('encoding a heavy document is the cost, not the disk', () {
    final EditableMarkupDocument document = _heavyDocument(
      photoPath: 'C:/photos/huge.jpg',
    );
    final Map<String, dynamic> json = document.toJson();

    final Stopwatch indented = Stopwatch()..start();
    final int indentedLength = const JsonEncoder.withIndent(
      '  ',
    ).convert(json).length;
    indented.stop();

    final Stopwatch compact = Stopwatch()..start();
    final int compactLength = jsonEncode(json).length;
    compact.stop();

    // ignore: avoid_print
    print(
      'BENCH encode 200x120 points: indented '
      '${indented.elapsedMicroseconds}us / ${(indentedLength / 1024).round()} KB, '
      'compact ${compact.elapsedMicroseconds}us / '
      '${(compactLength / 1024).round()} KB',
    );

    // Both have to be fast enough that the choice is about readability rather
    // than speed. If either one is slow, the document model is the problem.
    expect(indented.elapsedMilliseconds, lessThan(500));
    expect(compact.elapsedMilliseconds, lessThan(500));
  });
}
