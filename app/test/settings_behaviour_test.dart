import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/settings/models/app_settings.dart';
import 'package:ncd_photo_markup/features/settings/services/settings_service.dart';
import 'package:ncd_photo_markup/main.dart';

/// Every setting has to change something. A control that is read but never
/// applied is worse than no control, so each test here changes one setting and
/// then observes the app behaving differently.

Future<void> _pumpFrames(WidgetTester tester, {int frames = 12}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _expandSidebarIfCollapsed(WidgetTester tester) async {
  final Finder drawerToggle = find.byKey(
    const ValueKey<String>('sidebar-drawer-toggle'),
  );
  if (drawerToggle.evaluate().isNotEmpty) {
    return;
  }
  final Finder expandButton = find.byKey(
    const ValueKey<String>('sidebar-rail-toggle'),
  );
  if (expandButton.evaluate().isNotEmpty) {
    await tester.tap(expandButton);
    await _pumpFrames(tester, frames: 20);
  }
}

Future<void> _tapSidebarAction(WidgetTester tester, String label) async {
  await _expandSidebarIfCollapsed(tester);
  final Finder sidebarScrollable = find.descendant(
    of: find.byKey(const ValueKey<String>('sidebar-drawer-scroll')),
    matching: find.byType(Scrollable),
  );
  final Finder actionLabel = find.byKey(ValueKey<String>('sidebar-drawer-$label'));
  await tester.scrollUntilVisible(actionLabel, 220, scrollable: sidebarScrollable);
  await tester.ensureVisible(actionLabel);
  await _pumpFrames(tester, frames: 8);
  await tester.tap(actionLabel, warnIfMissed: false);
  await _pumpFrames(tester, frames: 8);
}

/// Calibrates the open photo so measured labels are live.
Future<void> _calibrate(WidgetTester tester, dynamic state) async {
  await _tapSidebarAction(tester, ToolbarConstants.scaleCalibration);
  final Rect imageRect = state.debugCurrentImageRect() as Rect;
  final Offset start =
      imageRect.topLeft + Offset(imageRect.width * 0.20, imageRect.height * 0.20);
  unawaited(
    state.debugCanvasDrag(
      start: start,
      end: start + Offset(imageRect.width * 0.50, 0),
    ),
  );
  await _pumpFrames(tester, frames: 12);
  final Finder fields = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextField),
  );
  await tester.enterText(fields.first, '10');
  await tester.enterText(fields.at(1), 'ft');
  await _pumpFrames(tester, frames: 4);
  await tester.tap(find.text(UiCopyConstants.scaleCalibrationSaveButton));
  await _pumpFrames(tester, frames: 12);
}

/// Draws a dimension a quarter of the photo wide: 5 ft against the calibration.
Future<void> _drawDimension(WidgetTester tester) async {
  await _tapSidebarAction(tester, ToolbarConstants.dimension);
  final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
  final Rect rect = state.debugCurrentImageRect() as Rect;
  final Offset start = rect.topLeft + Offset(rect.width * 0.20, rect.height * 0.60);
  unawaited(
    state.debugCanvasDrag(start: start, end: start + Offset(rect.width * 0.25, 0)),
  );
  await _pumpFrames(tester, frames: 12);
}

late Directory _scratch;

Widget _app() => NcdPhotoMarkupApp(
  showStartupSplash: false,
  settingsServiceOverride: SettingsService(overrideDirectory: _scratch.path),
);

void main() {
  setUp(() {
    _scratch = Directory.systemTemp.createTempSync('ncd_settings_behaviour');
  });

  tearDown(() {
    if (_scratch.existsSync()) {
      _scratch.deleteSync(recursive: true);
    }
  });

  testWidgets('the auto-label setting turned off brings the dialog back', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _pumpFrames(tester, frames: 12);
    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    state.debugSeedLoadedImageState();
    await _pumpFrames(tester, frames: 12);
    await _calibrate(tester, state);

    // Off: the dialog must return even though a scale is set.
    final dynamic calibrated = tester.state(
      find.byType(PhotoMarkupShellScreen),
    );
    calibrated.debugApplySettings(
      AppSettings.defaults.copyWith(autoLabelDimensions: false),
    );
    await _pumpFrames(tester, frames: 8);

    await _drawDimension(tester);
    expect(find.text(UiCopyConstants.dimensionLabelDialogTitle), findsOneWidget);
    await tester.tap(find.text(UiCopyConstants.dimensionLabelSkipButton));
    await _pumpFrames(tester, frames: 12);
  });

  testWidgets('the measured value format setting changes what is written on '
      'the photo', (WidgetTester tester) async {
    await tester.pumpWidget(_app());
    await _pumpFrames(tester, frames: 12);
    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    state.debugSeedLoadedImageState();
    await _pumpFrames(tester, frames: 12);
    await _calibrate(tester, state);

    // Tape is the default.
    await _drawDimension(tester);
    final dynamic tapeState = tester.state(find.byType(PhotoMarkupShellScreen));
    expect(tapeState.debugDimensionLinesSnapshot.last.label, '5 ft');

    // Switch to decimal and draw another.
    tapeState.debugApplySettings(
      AppSettings.defaults.copyWith(
        measurementDisplayMode: MeasurementDisplayMode.decimal,
      ),
    );
    await _pumpFrames(tester, frames: 8);
    await _drawDimension(tester);

    final dynamic decimalState =
        tester.state(find.byType(PhotoMarkupShellScreen));
    final String label = decimalState.debugDimensionLinesSnapshot.last.label as String;
    // Decimal shows the raw calibrated number, not a tape reading.
    expect(label, isNot(contains(' in')));
    expect(label, contains('ft'));
  });

  testWidgets('the default colour setting seeds the next mark', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _pumpFrames(tester, frames: 12);
    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));

    expect(state.debugSelectedStylePresetId, MarkupStylePresetId.ncdBlue);
    state.debugApplySettings(
      AppSettings.defaults.copyWith(
        defaultStylePresetId: MarkupStylePresetId.red,
      ),
    );
    await _pumpFrames(tester, frames: 8);
    expect(state.debugSelectedStylePresetId, MarkupStylePresetId.red);
  });

  testWidgets('the text size setting seeds the next mark', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _pumpFrames(tester, frames: 12);
    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));

    state.debugApplySettings(
      AppSettings.defaults.copyWith(defaultFontSize: 34),
    );
    await _pumpFrames(tester, frames: 8);
    expect(state.debugSelectedFontSize, 34);
  });

  testWidgets('the export name ending setting changes the suggested file name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _pumpFrames(tester, frames: 12);
    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    state.debugSeedLoadedImageState(path: 'front-elevation.jpg');
    await _pumpFrames(tester, frames: 8);

    expect(
      state.debugSuggestedExportName(),
      'front-elevation${ExportConstants.defaultFileSuffix}.png',
    );

    state.debugApplySettings(
      AppSettings.defaults.copyWith(exportFileSuffix: ' - Marked Up'),
    );
    await _pumpFrames(tester, frames: 8);
    expect(state.debugSuggestedExportName(), 'front-elevation - Marked Up.png');
  });

  testWidgets('the settings dialog opens from the sidebar and shows every '
      'section', (WidgetTester tester) async {
    await tester.pumpWidget(_app());
    await _pumpFrames(tester, frames: 12);

    await _tapSidebarAction(tester, ToolbarConstants.settings);

    expect(find.text(SettingsConstants.dialogTitle), findsWidgets);
    expect(find.text(SettingsConstants.measurementSectionTitle), findsOneWidget);
    expect(find.text(SettingsConstants.defaultsSectionTitle), findsOneWidget);
    expect(find.text(SettingsConstants.exportSectionTitle), findsOneWidget);
    expect(find.text(SettingsConstants.aboutSectionTitle), findsOneWidget);
    // About shows the real version, not a placeholder. The header shows it too,
    // so scope the check to the dialog.
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(AppConstants.appVersion),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a per-section reset leaves the other sections alone', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _pumpFrames(tester, frames: 12);
    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));

    state.debugApplySettings(
      AppSettings.defaults.copyWith(
        defaultStylePresetId: MarkupStylePresetId.red,
        exportFileSuffix: ' - Marked',
      ),
    );
    await _pumpFrames(tester, frames: 8);

    await _tapSidebarAction(tester, ToolbarConstants.settings);
    final Finder resetButton = find.byKey(
      ValueKey<String>(
        'settings-reset-${SettingsConstants.defaultsSectionTitle}',
      ),
    );
    await tester.ensureVisible(resetButton);
    await _pumpFrames(tester, frames: 8);
    await tester.tap(resetButton, warnIfMissed: false);
    await _pumpFrames(tester, frames: 12);

    final dynamic after = tester.state(find.byType(PhotoMarkupShellScreen));
    // Defaults section reset...
    expect(after.debugSettings.defaultStylePresetId, MarkupStylePresetId.ncdBlue);
    // ...export section untouched.
    expect(after.debugSettings.exportFileSuffix, ' - Marked');
  });
}
