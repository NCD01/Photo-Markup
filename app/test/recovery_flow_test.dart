import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/recovery/services/recovery_service.dart';
import 'package:ncd_photo_markup/features/settings/models/app_settings.dart';
import 'package:ncd_photo_markup/features/settings/services/settings_service.dart';
import 'package:ncd_photo_markup/main.dart';

/// The shell half of crash recovery: does drawing actually produce an autosave,
/// and does the next launch offer it back.
///
/// The service half is in recovery_service_test.dart. This one drives the real
/// widget tree, because the wiring is the part that breaks.

Future<void> _pumpFrames(WidgetTester tester, {int frames = 12}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Pumps while also letting real time pass.
///
/// The recovery flow reads real files, so it needs the real event loop to turn
/// as well as the test clock to advance. Inside runAsync a bare pump gives it
/// neither.
Future<void> _settle(WidgetTester tester, {int rounds = 20}) async {
  for (int i = 0; i < rounds; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await tester.pump();
  }
}

late Directory _scratch;
late Directory _stateDir;
late String _photoPath;

RecoveryService _recovery() =>
    RecoveryService(overrideDirectory: _stateDir.path);

Widget _app({String? initialImagePath}) => NcdPhotoMarkupApp(
  showStartupSplash: false,
  initialImagePath: initialImagePath,
  settingsServiceOverride: SettingsService(overrideDirectory: _scratch.path),
  recoveryServiceOverride: _recovery(),
);

/// Puts one real mark on the photo, which is what makes an autosave worth
/// offering. An empty document is deliberately never offered back.
void _drawOneMark(dynamic state) {
  state.debugSetDimensionLines(<DimensionLine>[
    const DimensionLine(
      id: 1,
      startNormalized: Offset(0.1, 0.1),
      endNormalized: Offset(0.6, 0.4),
      label: '5 ft',
    ),
  ]);
  state.debugSetUnsavedMarkupChanges(true);
}

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
  setUp(() {
    _scratch = Directory.systemTemp.createTempSync('ncd_recovery_flow');
    _stateDir = Directory('${_scratch.path}${Platform.pathSeparator}state')
      ..createSync(recursive: true);
    _photoPath = '${_scratch.path}${Platform.pathSeparator}site.jpg';
    File(_photoPath).writeAsBytesSync(<int>[1, 2, 3]);
  });

  tearDown(() => _deleteBestEffort(_scratch));

  testWidgets('drawing produces an autosave, and it names the photo', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await _pumpFrames(tester);
      final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
      state.debugSeedLoadedImageState(path: _photoPath);
      await _pumpFrames(tester);

      // Nothing drawn yet, so nothing to recover.
      expect(File(_recovery().recoveryFilePath).existsSync(), isFalse);

      _drawOneMark(state);
      await _pumpFrames(tester);
      await (state.debugWriteAutosave() as Future<void>);

      expect(File(_recovery().recoveryFilePath).existsSync(), isTrue);
      final RecoverableDraft? draft = await _recovery().loadDraft();
      expect(draft, isNotNull);
      expect(draft!.sourceImageFileName, isNotEmpty);
    });
  });

  testWidgets('saving the work removes the autosave, because it is not at risk',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await _pumpFrames(tester);
      final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
      state.debugSeedLoadedImageState(path: _photoPath);
      await _pumpFrames(tester);

      _drawOneMark(state);
      await _pumpFrames(tester);
      await (state.debugWriteAutosave() as Future<void>);
      expect(File(_recovery().recoveryFilePath).existsSync(), isTrue);

      state.debugSetUnsavedMarkupChanges(false);
      await _pumpFrames(tester);
      await (state.debugWriteAutosave() as Future<void>);
      expect(File(_recovery().recoveryFilePath).existsSync(), isFalse);
    });
  });

  testWidgets('the next launch offers the autosave back by name', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      // First run: draw, then die without saving.
      await tester.pumpWidget(_app());
      await _pumpFrames(tester);
      final dynamic first = tester.state(find.byType(PhotoMarkupShellScreen));
      first.debugSeedLoadedImageState(path: _photoPath);
      await _pumpFrames(tester);
      _drawOneMark(first);
      await _pumpFrames(tester);
      await (first.debugWriteAutosave() as Future<void>);
      expect(File(_recovery().recoveryFilePath).existsSync(), isTrue);

      // Second run, opened on its own with no photo handed in.
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpFrames(tester);
      await tester.pumpWidget(_app());
      await _settle(tester);

      expect(find.text(RecoveryConstants.dialogTitle), findsOneWidget);
      expect(find.text(RecoveryConstants.restoreButton), findsOneWidget);
      expect(find.text(RecoveryConstants.discardButton), findsOneWidget);
    });
  });

  testWidgets('declining deletes the autosave rather than asking again', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await _pumpFrames(tester);
      final dynamic first = tester.state(find.byType(PhotoMarkupShellScreen));
      first.debugSeedLoadedImageState(path: _photoPath);
      await _pumpFrames(tester);
      _drawOneMark(first);
      await _pumpFrames(tester);
      await (first.debugWriteAutosave() as Future<void>);

      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpFrames(tester);
      await tester.pumpWidget(_app());
      await _settle(tester);

      await tester.tap(find.text(RecoveryConstants.discardButton));
      await _settle(tester);

      expect(File(_recovery().recoveryFilePath).existsSync(), isFalse);
      expect(find.text(RecoveryConstants.dialogTitle), findsNothing);
    });
  });

  testWidgets('a photo handed in by Control Center is never ambushed', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await _pumpFrames(tester);
      final dynamic first = tester.state(find.byType(PhotoMarkupShellScreen));
      first.debugSeedLoadedImageState(path: _photoPath);
      await _pumpFrames(tester);
      _drawOneMark(first);
      await _pumpFrames(tester);
      await (first.debugWriteAutosave() as Future<void>);

      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpFrames(tester);
      // Launched with a specific photo: that is the job in hand.
      await tester.pumpWidget(_app(initialImagePath: _photoPath));
      await _settle(tester);

      expect(find.text(RecoveryConstants.dialogTitle), findsNothing);
      // And the autosave is still there for a later launch.
      expect(File(_recovery().recoveryFilePath).existsSync(), isTrue);
    });
  });

  testWidgets('the autosave interval setting is what the timer uses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _pumpFrames(tester);
    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));

    expect(
      state.debugSettings.autosaveIntervalSeconds,
      RecoveryConstants.defaultIntervalSeconds,
    );

    state.debugApplySettings(
      AppSettings.defaults.copyWith(autosaveIntervalSeconds: 30),
    );
    await _pumpFrames(tester);
    expect(state.debugSettings.autosaveIntervalSeconds, 30);

    // Out of range values are refused on read rather than clamped silently.
    final AppSettings restored = AppSettings.fromJson(<String, dynamic>{
      'autosaveIntervalSeconds': 9999,
    });
    expect(
      restored.autosaveIntervalSeconds,
      RecoveryConstants.defaultIntervalSeconds,
    );
  });
}
