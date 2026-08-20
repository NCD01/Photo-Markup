// End-to-end drive of the markup shell: create with every tool, select, move,
// undo, redo, clear. Runs against the real widget tree and the real painter.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/widgets/dimension_lines_overlay.dart';
import 'package:ncd_photo_markup/features/session/services/session_state_service.dart';
import 'package:flutter/services.dart';
import 'package:ncd_photo_markup/main.dart';
import 'test_temp_dir.dart';

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

  await tester.pumpWidget(
    NcdPhotoMarkupApp(
      showStartupSplash: false,
      sessionStateService: isolatedSessionState(),
    ),
  );
  await pumpFrames(tester, frames: 20);
  final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
  state.debugSeedLoadedImageState(path: 'seed.png', pixelSize: pixelSize);
  await pumpFrames(tester, frames: 20);
  return state;
}

/// A session store pointed at a throwaway folder, so a test never reads or
/// writes the real user settings.
SessionStateService isolatedSessionState() {
  final Directory dir = Directory.systemTemp.createTempSync('ncd_flow_state');
  addTearDown(() {
    deleteTempDirBestEffort(dir);
  });
  return SessionStateService.inMemoryFolder(dir.path);
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
      deleteTempDirBestEffort(workDir);
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

  testWidgets('one tap exports beside the photo with no dialog', (
    WidgetTester tester,
  ) async {
    final Directory workDir = Directory.systemTemp.createTempSync('ncd_quick');
    addTearDown(() {
      deleteTempDirBestEffort(workDir);
    });
    final String sourcePath = '${workDir.path}/site_photo.png';
    await tester.runAsync(() async {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 1600, 1200),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(1600, 1200);
      final ByteData? encoded = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      await File(sourcePath).writeAsBytes(encoded!.buffer.asUint8List());
      image.dispose();
      picture.dispose();
    });

    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      NcdPhotoMarkupApp(
        showStartupSplash: false,
        sessionStateService: isolatedSessionState(),
        saveLocationOverride:
            ({
              String? initialDirectory,
              String? suggestedName,
              String? confirmButtonText,
              List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
            }) async {
              fail('Quick export must not open a save dialog');
            },
      ),
    );
    await pumpFrames(tester, frames: 20);

    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    state.debugSeedLoadedImageState(
      path: sourcePath,
      pixelSize: const Size(1600, 1200),
    );
    await pumpFrames(tester, frames: 20);

    final Rect imageRect = state.debugCurrentImageRect() as Rect;
    await tapRailAction(tester, ToolbarConstants.arrow);
    await dragOnCanvas(
      tester,
      imageRect.topLeft + const Offset(60, 60),
      imageRect.topLeft + const Offset(220, 200),
    );

    late final bool exported;
    await tester.runAsync(() async {
      exported = await state.debugQuickExport() as bool;
    });
    expect(exported, isTrue);

    // Landed next to the photo, named after it, without asking anything.
    final File expected = File('${workDir.path}/site_photo - Markup.png');
    expect(expected.existsSync(), isTrue);

    // A second quick export does not overwrite the first.
    await tester.runAsync(() async {
      await state.debugQuickExport();
    });
    expect(
      File('${workDir.path}/site_photo - Markup 2.png').existsSync(),
      isTrue,
    );
  });

  testWidgets('single keys pick tools without touching the toolbar', (
    WidgetTester tester,
  ) async {
    final dynamic state = await loadedShell(tester);

    Future<void> press(LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await pumpFrames(tester);
    }

    await press(LogicalKeyboardKey.keyA);
    expect(state.debugSelectedTool, MarkupTool.arrow);
    await press(LogicalKeyboardKey.keyF);
    expect(state.debugSelectedTool, MarkupTool.freehand);
    await press(LogicalKeyboardKey.keyH);
    expect(state.debugSelectedTool, MarkupTool.highlighter);
    await press(LogicalKeyboardKey.keyR);
    expect(state.debugSelectedTool, MarkupTool.rectangle);
    await press(LogicalKeyboardKey.keyB);
    expect(state.debugSelectedTool, MarkupTool.blur);
    await press(LogicalKeyboardKey.keyV);
    expect(state.debugSelectedTool, MarkupTool.none);
  });

  testWidgets('escape leaves the current tool', (WidgetTester tester) async {
    final dynamic state = await loadedShell(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await pumpFrames(tester);
    expect(state.debugSelectedTool, MarkupTool.rectangle);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await pumpFrames(tester);
    expect(state.debugSelectedTool, MarkupTool.none);
  });

  testWidgets('bracket keys rotate the photo', (WidgetTester tester) async {
    final dynamic state = await loadedShell(tester);
    final Rect before = state.debugCurrentImageRect() as Rect;

    await tester.sendKeyEvent(LogicalKeyboardKey.bracketRight);
    await pumpFrames(tester, frames: 20);
    final Rect after = state.debugCurrentImageRect() as Rect;

    // A landscape photo turned a quarter turn becomes taller than it is wide.
    expect(before.width > before.height, isTrue);
    expect(after.height > after.width, isTrue);
  });

  testWidgets('ctrl+z and ctrl+shift+z drive undo and redo', (
    WidgetTester tester,
  ) async {
    final dynamic state = await loadedShell(tester);
    final Rect imageRect = state.debugCurrentImageRect() as Rect;

    await tapRailAction(tester, ToolbarConstants.rectangle);
    await dragOnCanvas(
      tester,
      imageRect.topLeft + const Offset(120, 120),
      imageRect.topLeft + const Offset(300, 260),
    );
    expect(state.debugMarkupCount, 1);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 0);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await pumpFrames(tester);
    expect(state.debugMarkupCount, 1);
  });

  testWidgets('an accidental double tap does not stack two pins', (
    WidgetTester tester,
  ) async {
    final dynamic state = await loadedShell(tester);
    final Rect imageRect = state.debugCurrentImageRect() as Rect;

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await pumpFrames(tester);
    expect(state.debugSelectedTool, MarkupTool.callout);
    final Offset target = canvasPoint(
      tester,
      imageRect.topLeft + const Offset(200, 160),
    );

    await tester.tapAt(target);
    await pumpFrames(tester, frames: 6);
    // Same spot again straight away: a slip, not a second pin.
    await tester.tapAt(target);
    await pumpFrames(tester, frames: 6);
    expect(state.debugMarkupCount, 1);

    // A deliberate second pin somewhere else still lands.
    await tester.tapAt(
      canvasPoint(tester, imageRect.topLeft + const Offset(400, 320)),
    );
    await pumpFrames(tester, frames: 6);
    expect(state.debugMarkupCount, 2);
  });

  testWidgets('a two-finger gesture pans instead of drawing', (
    WidgetTester tester,
  ) async {
    final dynamic state = await loadedShell(tester);
    final Rect imageRect = state.debugCurrentImageRect() as Rect;

    await tapRailAction(tester, ToolbarConstants.freehand);

    final Offset a = canvasPoint(
      tester,
      imageRect.topLeft + const Offset(150, 150),
    );
    final Offset b = canvasPoint(
      tester,
      imageRect.topLeft + const Offset(300, 150),
    );
    final TestGesture first = await tester.startGesture(a, pointer: 1);
    await pumpFrames(tester, frames: 2);
    final TestGesture second = await tester.startGesture(b, pointer: 2);
    await pumpFrames(tester, frames: 2);
    for (int i = 1; i <= 6; i++) {
      await first.moveBy(const Offset(10, 6));
      await second.moveBy(const Offset(10, 6));
      await pumpFrames(tester, frames: 1);
    }
    await first.up();
    await second.up();
    await pumpFrames(tester, frames: 10);

    expect(state.debugMarkupCount, 0);
  });

  testWidgets('the tool, colour and width in use are remembered', (
    WidgetTester tester,
  ) async {
    final Directory dir = Directory.systemTemp.createTempSync('ncd_prefs_flow');
    addTearDown(() {
      deleteTempDirBestEffort(dir);
    });
    final SessionStateService store = SessionStateService.inMemoryFolder(
      dir.path,
    );

    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      NcdPhotoMarkupApp(showStartupSplash: false, sessionStateService: store),
    );
    await pumpFrames(tester, frames: 20);

    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    await pumpFrames(tester);
    expect(state.debugSelectedTool, MarkupTool.highlighter);

    await tester.tap(find.byKey(const ValueKey<String>('status-color-orange')));
    await pumpFrames(tester, frames: 8);
    await tester.tap(
      find.byKey(
        ValueKey<String>(
          'status-width-${MarkupStrokeConstants.allScaleLabels.last}',
        ),
      ),
    );
    await pumpFrames(tester, frames: 20);

    // Real file IO only runs outside the fake clock.
    late final dynamic reloaded;
    await tester.runAsync(() async {
      await state.debugSavePreferences();
      reloaded = await store.loadPreferences();
    });
    expect(reloaded.tool, MarkupTool.highlighter);
    expect(reloaded.stylePresetId, MarkupStylePresetId.orange);
    expect(reloaded.strokeWidthScale, MarkupStrokeConstants.allScales.last);
  });

  testWidgets('work in progress is autosaved and can be recovered', (
    WidgetTester tester,
  ) async {
    final Directory stateDir = Directory.systemTemp.createTempSync('ncd_auto');
    final Directory photoDir = Directory.systemTemp.createTempSync('ncd_photo');
    addTearDown(() {
      for (final Directory dir in <Directory>[stateDir, photoDir]) {
        deleteTempDirBestEffort(dir);
      }
    });
    final SessionStateService store = SessionStateService.inMemoryFolder(
      stateDir.path,
    );
    final String photoPath = '${photoDir.path}/wall.png';
    await tester.runAsync(() async {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 900, 700),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(900, 700);
      final ByteData? encoded = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      await File(photoPath).writeAsBytes(encoded!.buffer.asUint8List());
      image.dispose();
      picture.dispose();
    });

    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      NcdPhotoMarkupApp(showStartupSplash: false, sessionStateService: store),
    );
    await pumpFrames(tester, frames: 20);

    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    state.debugSeedLoadedImageState(
      path: photoPath,
      pixelSize: const Size(900, 700),
    );
    await pumpFrames(tester, frames: 20);

    final Rect imageRect = state.debugCurrentImageRect() as Rect;
    await tapRailAction(tester, ToolbarConstants.rectangle);
    await dragOnCanvas(
      tester,
      imageRect.topLeft + const Offset(80, 80),
      imageRect.topLeft + const Offset(240, 200),
    );
    expect(state.debugMarkupCount, 1);

    late final RecoverableDraft? draft;
    await tester.runAsync(() async {
      await state.debugWriteAutosave();
      draft = await store.loadDraft();
    });

    expect(draft, isNotNull);
    expect(draft!.sourceImagePath, photoPath);
    expect(draft!.document.rectangles.length, 1);
  });

  testWidgets('a saved markup file clears the autosave draft', (
    WidgetTester tester,
  ) async {
    final Directory stateDir = Directory.systemTemp.createTempSync('ncd_auto2');
    final Directory photoDir = Directory.systemTemp.createTempSync('ncd_pho2');
    addTearDown(() {
      for (final Directory dir in <Directory>[stateDir, photoDir]) {
        deleteTempDirBestEffort(dir);
      }
    });
    final SessionStateService store = SessionStateService.inMemoryFolder(
      stateDir.path,
    );
    final String photoPath = '${photoDir.path}/wall.png';
    await tester.runAsync(() async {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 600, 400),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(600, 400);
      final ByteData? encoded = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      await File(photoPath).writeAsBytes(encoded!.buffer.asUint8List());
      image.dispose();
      picture.dispose();
    });

    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      NcdPhotoMarkupApp(showStartupSplash: false, sessionStateService: store),
    );
    await pumpFrames(tester, frames: 20);
    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    state.debugSeedLoadedImageState(
      path: photoPath,
      pixelSize: const Size(600, 400),
    );
    await pumpFrames(tester, frames: 20);

    final Rect imageRect = state.debugCurrentImageRect() as Rect;
    await tapRailAction(tester, ToolbarConstants.arrow);
    await dragOnCanvas(
      tester,
      imageRect.topLeft + const Offset(50, 50),
      imageRect.topLeft + const Offset(180, 160),
    );

    await tester.runAsync(() async {
      await state.debugWriteAutosave();
      expect(await store.loadDraft(), isNotNull);
    });

    // Exporting counts as the work being safe, so the draft goes away.
    await tester.runAsync(() async {
      await state.debugQuickExport();
      expect(await store.loadDraft(), isNull);
    });
  });
}
