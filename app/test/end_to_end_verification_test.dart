// The sweep: open a photo, use every tool, edit what was drawn, zoom, undo,
// redo, save the markup file, reopen it, and export. Run against the real
// widget tree with real files on disk.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/widgets/dimension_lines_overlay.dart';
import 'package:ncd_photo_markup/features/session/services/session_state_service.dart';
import 'package:ncd_photo_markup/main.dart';

Future<void> pumpFrames(WidgetTester tester, {int frames = 10}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Offset canvasPoint(WidgetTester tester, Offset local) {
  return tester.getTopLeft(find.byType(DimensionLinesOverlay)) + local;
}

Future<void> drag(
  WidgetTester tester,
  Offset from,
  Offset to, {
  int steps = 8,
}) async {
  final TestGesture gesture = await tester.startGesture(
    canvasPoint(tester, from),
  );
  await pumpFrames(tester, frames: 2);
  for (int i = 1; i <= steps; i++) {
    await gesture.moveTo(
      canvasPoint(tester, Offset.lerp(from, to, i / steps)!),
    );
    await pumpFrames(tester, frames: 1);
  }
  await gesture.up();
  await pumpFrames(tester, frames: 10);
}

Future<String> writePhoto(
  WidgetTester tester,
  String path,
  int width,
  int height,
) async {
  await tester.runAsync(() async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = const Color(0xFF8A99A6),
    );
    // Corner markers, so orientation problems would show up as a wrong colour.
    final double marker = width * 0.05;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, marker, marker),
      Paint()..color = const Color(0xFFFF0000),
    );
    canvas.drawRect(
      Rect.fromLTWH(width - marker, height - marker, marker, marker),
      Paint()..color = const Color(0xFFFFFF00),
    );
    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(width, height);
    final ByteData? encoded = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    await File(path).writeAsBytes(encoded!.buffer.asUint8List());
    image.dispose();
    picture.dispose();
  });
  return path;
}

Future<(int, int)> pngSize(WidgetTester tester, String path) async {
  late int width;
  late int height;
  await tester.runAsync(() async {
    final ui.Codec codec = await ui.instantiateImageCodec(
      await File(path).readAsBytes(),
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    width = frame.image.width;
    height = frame.image.height;
    frame.image.dispose();
    codec.dispose();
  });
  return (width, height);
}

void main() {
  late Directory workDir;
  late SessionStateService store;

  setUp(() {
    workDir = Directory.systemTemp.createTempSync('ncd_e2e');
    store = SessionStateService.inMemoryFolder(workDir.path);
  });

  tearDown(() {
    if (workDir.existsSync()) {
      workDir.deleteSync(recursive: true);
    }
  });

  Future<dynamic> openShell(
    WidgetTester tester, {
    required String photoPath,
    required Size pixelSize,
    String? exportPath,
    Size viewSize = const Size(1600, 1100),
  }) async {
    tester.view.physicalSize = viewSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      NcdPhotoMarkupApp(
        showStartupSplash: false,
        sessionStateService: store,
        saveLocationOverride: exportPath == null
            ? null
            : ({
                String? initialDirectory,
                String? suggestedName,
                String? confirmButtonText,
                List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
              }) async => FileSaveLocation(exportPath),
      ),
    );
    await pumpFrames(tester, frames: 20);
    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    state.debugSeedLoadedImageState(path: photoPath, pixelSize: pixelSize);
    await pumpFrames(tester, frames: 20);
    return state;
  }

  testWidgets('every tool draws, and every mark survives a save and reopen', (
    WidgetTester tester,
  ) async {
    final String photoPath = await writePhoto(
      tester,
      '${workDir.path}/site.png',
      2000,
      1500,
    );
    final dynamic state = await openShell(
      tester,
      photoPath: photoPath,
      pixelSize: const Size(2000, 1500),
    );
    final Rect rect = state.debugCurrentImageRect() as Rect;
    Offset at(double fx, double fy) =>
        rect.topLeft + Offset(rect.width * fx, rect.height * fy);

    int expected = 0;

    // Drag tools.
    for (final (LogicalKeyboardKey key, MarkupTool tool) entry
        in <(LogicalKeyboardKey, MarkupTool)>[
          (LogicalKeyboardKey.keyA, MarkupTool.arrow),
          (LogicalKeyboardKey.keyL, MarkupTool.line),
          (LogicalKeyboardKey.keyR, MarkupTool.rectangle),
          (LogicalKeyboardKey.keyC, MarkupTool.oval),
          (LogicalKeyboardKey.keyF, MarkupTool.freehand),
          (LogicalKeyboardKey.keyH, MarkupTool.highlighter),
          (LogicalKeyboardKey.keyB, MarkupTool.blur),
        ]) {
      await tester.sendKeyEvent(entry.$1);
      await pumpFrames(tester);
      expect(state.debugSelectedTool, entry.$2, reason: '${entry.$2}');
      await drag(
        tester,
        at(0.08 + (expected * 0.02), 0.10 + (expected * 0.07)),
        at(0.30 + (expected * 0.02), 0.24 + (expected * 0.07)),
        steps: 10,
      );
      expected += 1;
      expect(state.debugMarkupCount, expected, reason: '${entry.$2}');
    }

    // Dimension opens a label dialog on release.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await pumpFrames(tester);
    await drag(tester, at(0.10, 0.86), at(0.60, 0.86));
    await pumpFrames(tester, frames: 20);
    expect(
      find.text(UiCopyConstants.dimensionLabelDialogTitle),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), '48');
    await tester.tap(find.text(UiCopyConstants.dimensionLabelSaveButton));
    await pumpFrames(tester, frames: 20);
    expected += 1;
    expect(state.debugMarkupCount, expected);

    // Text note: tap, type, save.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
    await pumpFrames(tester);
    await tester.tapAt(canvasPoint(tester, at(0.70, 0.20)));
    await pumpFrames(tester, frames: 20);
    // The status bar also reads "Text Note", so scope the check to the dialog.
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(UiCopyConstants.textNoteDialogTitle),
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'Replace drywall here');
    await tester.tap(find.text(UiCopyConstants.textNoteSaveButton));
    await pumpFrames(tester, frames: 20);
    expected += 1;
    expect(state.debugMarkupCount, expected);

    // Callout pins.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await pumpFrames(tester);
    await tester.tapAt(canvasPoint(tester, at(0.80, 0.40)));
    await pumpFrames(tester, frames: 10);
    await tester.tapAt(canvasPoint(tester, at(0.86, 0.55)));
    await pumpFrames(tester, frames: 10);
    expected += 2;
    expect(state.debugMarkupCount, expected);

    final Object fullSet = state.debugMarkupFingerprint as Object;

    // Save the editable markup file, then reopen it into a fresh shell.
    final String markupPath = '${workDir.path}/site - Markup.ncdmarkup.json';
    await tester.runAsync(() async {
      await state.debugSaveMarkupDocumentTo(markupPath);
    });
    expect(File(markupPath).existsSync(), isTrue);

    await tester.runAsync(() async {
      await state.debugOpenMarkupDocumentFrom(markupPath);
    });
    await pumpFrames(tester, frames: 20);
    expect(state.debugMarkupCount, expected);
    expect(state.debugMarkupFingerprint, equals(fullSet));
  });

  testWidgets('select, move and delete a mark after it was drawn', (
    WidgetTester tester,
  ) async {
    final String photoPath = await writePhoto(
      tester,
      '${workDir.path}/edit.png',
      1600,
      1200,
    );
    final dynamic state = await openShell(
      tester,
      photoPath: photoPath,
      pixelSize: const Size(1600, 1200),
    );
    final Rect rect = state.debugCurrentImageRect() as Rect;
    Offset at(double fx, double fy) =>
        rect.topLeft + Offset(rect.width * fx, rect.height * fy);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await pumpFrames(tester);
    await drag(tester, at(0.20, 0.25), at(0.45, 0.55));
    expect(state.debugMarkupCount, 1);
    final Object drawn = state.debugMarkupFingerprint as Object;

    // Select mode, then drag the shape.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await pumpFrames(tester);
    await drag(tester, at(0.32, 0.40), at(0.55, 0.62));
    final Object moved = state.debugMarkupFingerprint as Object;
    expect(moved, isNot(equals(drawn)));

    // Resize from a corner.
    await drag(tester, at(0.55, 0.62), at(0.70, 0.78));
    expect(state.debugMarkupFingerprint, isNot(equals(moved)));

    // Delete it.
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 0);

    // And bring it back.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 1);
  });

  testWidgets('marks stay on the same part of the photo while zoomed', (
    WidgetTester tester,
  ) async {
    final String photoPath = await writePhoto(
      tester,
      '${workDir.path}/zoom.png',
      1600,
      1200,
    );
    final dynamic state = await openShell(
      tester,
      photoPath: photoPath,
      pixelSize: const Size(1600, 1200),
    );
    final Rect rect = state.debugCurrentImageRect() as Rect;

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await pumpFrames(tester);
    await drag(
      tester,
      rect.topLeft + Offset(rect.width * 0.2, rect.height * 0.2),
      rect.topLeft + Offset(rect.width * 0.5, rect.height * 0.5),
    );
    final Object before = state.debugMarkupFingerprint as Object;

    // Zoom in, then back out to fit.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    for (int i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      await pumpFrames(tester);
    }
    expect(state.debugZoomPercent, greaterThan(100));
    await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await pumpFrames(tester, frames: 20);

    // Coordinates are stored against the photo, so zooming cannot move a mark.
    expect(state.debugMarkupFingerprint, equals(before));
  });

  testWidgets('an enormous photo exports at its own resolution', (
    WidgetTester tester,
  ) async {
    final String photoPath = await writePhoto(
      tester,
      '${workDir.path}/huge.png',
      6000,
      4000,
    );
    final String exportPath = '${workDir.path}/huge-export.png';
    final dynamic state = await openShell(
      tester,
      photoPath: photoPath,
      pixelSize: const Size(6000, 4000),
      exportPath: exportPath,
    );
    final Rect rect = state.debugCurrentImageRect() as Rect;
    expect(rect.width, lessThan(2000));

    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await pumpFrames(tester);
    await drag(
      tester,
      rect.topLeft + Offset(rect.width * 0.2, rect.height * 0.2),
      rect.topLeft + Offset(rect.width * 0.6, rect.height * 0.6),
    );

    late final bool exported;
    await tester.runAsync(() async {
      exported = await state.debugExportMarkedUpImage() as bool;
    });
    expect(exported, isTrue);

    final (int width, int height) = await pngSize(tester, exportPath);
    expect(width, 6000);
    expect(height, 4000);
  });

  testWidgets('a portrait photo exports portrait at its own resolution', (
    WidgetTester tester,
  ) async {
    final String photoPath = await writePhoto(
      tester,
      '${workDir.path}/portrait.png',
      1500,
      2400,
    );
    final String exportPath = '${workDir.path}/portrait-export.png';
    final dynamic state = await openShell(
      tester,
      photoPath: photoPath,
      pixelSize: const Size(1500, 2400),
      exportPath: exportPath,
    );
    final Rect rect = state.debugCurrentImageRect() as Rect;
    expect(rect.height, greaterThan(rect.width));

    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await pumpFrames(tester);
    await drag(
      tester,
      rect.topLeft + Offset(rect.width * 0.2, rect.height * 0.2),
      rect.topLeft + Offset(rect.width * 0.7, rect.height * 0.5),
    );

    late final bool exported;
    await tester.runAsync(() async {
      exported = await state.debugExportMarkedUpImage() as bool;
    });
    expect(exported, isTrue);

    final (int width, int height) = await pngSize(tester, exportPath);
    expect(width, 1500);
    expect(height, 2400);
  });

  testWidgets('a rotated photo exports rotated at full resolution', (
    WidgetTester tester,
  ) async {
    final String photoPath = await writePhoto(
      tester,
      '${workDir.path}/rot.png',
      2400,
      1600,
    );
    final String exportPath = '${workDir.path}/rot-export.png';
    final dynamic state = await openShell(
      tester,
      photoPath: photoPath,
      pixelSize: const Size(2400, 1600),
      exportPath: exportPath,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.bracketRight);
    await pumpFrames(tester, frames: 20);

    late final bool exported;
    await tester.runAsync(() async {
      exported = await state.debugExportMarkedUpImage() as bool;
    });
    expect(exported, isTrue);

    final (int width, int height) = await pngSize(tester, exportPath);
    expect(width, 1600);
    expect(height, 2400);
  });
}
