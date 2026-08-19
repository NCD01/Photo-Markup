// End-to-end drive of the markup shell: create with every tool, select, move,
// undo, redo, clear. Runs against the real widget tree and the real painter.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/widgets/dimension_lines_overlay.dart';
import 'package:ncd_photo_markup/main.dart';

Future<void> pumpFrames(WidgetTester tester, {int frames = 10}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> tapRailAction(WidgetTester tester, String label) async {
  final Finder button = find.byKey(ValueKey<String>('sidebar-rail-$label'));
  await tester.scrollUntilVisible(
    button,
    120,
    scrollable: find.descendant(
      of: find.byKey(const ValueKey<String>('sidebar-rail-scroll')),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.tap(button, warnIfMissed: false);
  await pumpFrames(tester);
}

/// Seeds a loaded photo without touching the disk so the shell renders its
/// canvas, then returns the shell state for driving.
Future<dynamic> loadedShell(
  WidgetTester tester, {
  Size pixelSize = const Size(1600, 1200),
  Size viewSize = const Size(1400, 1000),
}) async {
  tester.view.physicalSize = viewSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
  await pumpFrames(tester, frames: 20);
  final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
  state.debugSeedLoadedImageState(path: 'seed.png', pixelSize: pixelSize);
  await pumpFrames(tester, frames: 20);
  return state;
}

/// Local canvas coordinates (the space [debugCurrentImageRect] is measured in)
/// converted to the global coordinates a test gesture needs.
Offset canvasPoint(WidgetTester tester, Offset local) {
  return tester.getTopLeft(find.byType(DimensionLinesOverlay)) + local;
}

Future<void> dragOnCanvas(
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

void main() {
  testWidgets('undo and redo walk multiple markups back and forward', (
    WidgetTester tester,
  ) async {
    final dynamic state = await loadedShell(tester);
    final Rect imageRect = state.debugCurrentImageRect() as Rect;
    expect(imageRect.width, greaterThan(0));

    await tapRailAction(tester, ToolbarConstants.arrow);
    expect(state.debugSelectedTool, MarkupTool.arrow);

    for (int i = 0; i < 3; i++) {
      await dragOnCanvas(
        tester,
        imageRect.topLeft + Offset(60.0 + i * 70, 60),
        imageRect.topLeft + Offset(120.0 + i * 70, 200),
      );
    }
    expect(state.debugMarkupCount, 3);

    state.debugInvokeToolbarAction(ToolbarConstants.undo);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 2);

    state.debugInvokeToolbarAction(ToolbarConstants.undo);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 1);

    state.debugInvokeToolbarAction(ToolbarConstants.redo);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 2);

    state.debugInvokeToolbarAction(ToolbarConstants.redo);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 3);

    state.debugInvokeToolbarAction(ToolbarConstants.redo);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 3);
    expect(find.text(UiCopyConstants.redoNothingMessage), findsOneWidget);
  });

  testWidgets('undo restores a moved markup to where it was', (
    WidgetTester tester,
  ) async {
    final dynamic state = await loadedShell(tester);
    final Rect imageRect = state.debugCurrentImageRect() as Rect;

    await tapRailAction(tester, ToolbarConstants.rectangle);
    await dragOnCanvas(
      tester,
      imageRect.topLeft + const Offset(120, 120),
      imageRect.topLeft + const Offset(280, 260),
    );
    expect(state.debugMarkupCount, 1);
    final Object before = state.debugMarkupFingerprint as Object;

    // Back to select mode, then drag the shape somewhere else.
    await tapRailAction(tester, ToolbarConstants.rectangle);
    expect(state.debugSelectedTool, MarkupTool.none);
    await dragOnCanvas(
      tester,
      imageRect.topLeft + const Offset(200, 190),
      imageRect.topLeft + const Offset(360, 330),
    );
    final Object moved = state.debugMarkupFingerprint as Object;
    expect(moved, isNot(equals(before)));

    state.debugInvokeToolbarAction(ToolbarConstants.undo);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 1);
    expect(state.debugMarkupFingerprint, equals(before));
  });

  testWidgets('undo brings back an erased markup', (WidgetTester tester) async {
    final dynamic state = await loadedShell(tester);
    final Rect imageRect = state.debugCurrentImageRect() as Rect;

    await tapRailAction(tester, ToolbarConstants.circle);
    await dragOnCanvas(
      tester,
      imageRect.topLeft + const Offset(140, 140),
      imageRect.topLeft + const Offset(300, 280),
    );
    expect(state.debugMarkupCount, 1);
    final Object before = state.debugMarkupFingerprint as Object;

    state.debugInvokeToolbarAction(ToolbarConstants.erase);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 0);

    state.debugInvokeToolbarAction(ToolbarConstants.undo);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 1);
    expect(state.debugMarkupFingerprint, equals(before));
  });

  testWidgets('clear all asks first, then a single undo brings it all back', (
    WidgetTester tester,
  ) async {
    final dynamic state = await loadedShell(tester);
    final Rect imageRect = state.debugCurrentImageRect() as Rect;

    await tapRailAction(tester, ToolbarConstants.freehand);
    for (int i = 0; i < 2; i++) {
      await dragOnCanvas(
        tester,
        imageRect.topLeft + Offset(80.0 + i * 120, 80),
        imageRect.topLeft + Offset(200.0 + i * 120, 240),
        steps: 12,
      );
    }
    expect(state.debugMarkupCount, 2);
    final Object before = state.debugMarkupFingerprint as Object;

    state.debugInvokeToolbarAction(ToolbarConstants.clearAll);
    await pumpFrames(tester, frames: 20);
    expect(find.text(UiCopyConstants.clearAllDialogTitle), findsOneWidget);

    await tester.tap(find.text(UiCopyConstants.clearAllCancelButton));
    await pumpFrames(tester, frames: 20);
    expect(state.debugMarkupCount, 2);

    state.debugInvokeToolbarAction(ToolbarConstants.clearAll);
    await pumpFrames(tester, frames: 20);
    await tester.tap(find.text(UiCopyConstants.clearAllConfirmButton));
    await pumpFrames(tester, frames: 20);
    expect(state.debugMarkupCount, 0);

    state.debugInvokeToolbarAction(ToolbarConstants.undo);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 2);
    expect(state.debugMarkupFingerprint, equals(before));
  });

  testWidgets('undo with an empty history says so instead of doing nothing', (
    WidgetTester tester,
  ) async {
    final dynamic state = await loadedShell(tester);
    state.debugInvokeToolbarAction(ToolbarConstants.undo);
    await pumpFrames(tester);
    expect(find.text(UiCopyConstants.undoNothingMessage), findsOneWidget);
  });

  testWidgets('export from the shell writes the photo at full resolution', (
    WidgetTester tester,
  ) async {
    final Directory workDir = Directory.systemTemp.createTempSync('ncd_shell');
    addTearDown(() {
      if (workDir.existsSync()) {
        workDir.deleteSync(recursive: true);
      }
    });

    // A real 2400x1600 photo on disk for the shell to load and export.
    final String sourcePath = '${workDir.path}/site_photo.png';
    late final Uint8List sourceBytes;
    await tester.runAsync(() async {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 2400, 1600),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(2400, 1600);
      final ByteData? encoded = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      sourceBytes = encoded!.buffer.asUint8List();
      image.dispose();
      picture.dispose();
      await File(sourcePath).writeAsBytes(sourceBytes);
    });

    final String exportPath = '${workDir.path}/exported.png';
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      NcdPhotoMarkupApp(
        showStartupSplash: false,
        saveLocationOverride:
            ({
              String? initialDirectory,
              String? suggestedName,
              String? confirmButtonText,
              List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
            }) async => FileSaveLocation(exportPath),
      ),
    );
    await pumpFrames(tester, frames: 20);

    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    state.debugSeedLoadedImageState(
      path: sourcePath,
      pixelSize: const Size(2400, 1600),
    );
    await pumpFrames(tester, frames: 20);

    final Rect imageRect = state.debugCurrentImageRect() as Rect;
    expect(imageRect.width, lessThan(2400));

    await tapRailAction(tester, ToolbarConstants.arrow);
    await dragOnCanvas(
      tester,
      imageRect.topLeft + const Offset(80, 80),
      imageRect.topLeft + const Offset(260, 220),
    );
    expect(state.debugMarkupCount, 1);

    late final bool exported;
    await tester.runAsync(() async {
      exported = await state.debugExportMarkedUpImage() as bool;
    });
    expect(exported, isTrue);

    late final int width;
    late final int height;
    await tester.runAsync(() async {
      final Uint8List bytes = await File(exportPath).readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      width = frame.image.width;
      height = frame.image.height;
      frame.image.dispose();
      codec.dispose();
    });

    expect(width, 2400);
    expect(height, 1600);
  });
}
