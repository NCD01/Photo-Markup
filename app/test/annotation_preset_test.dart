import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/settings/models/annotation_preset.dart';
import 'package:ncd_photo_markup/features/settings/models/app_settings.dart';
import 'package:ncd_photo_markup/features/settings/services/settings_service.dart';
import 'package:ncd_photo_markup/main.dart';

Future<void> _pumpFrames(WidgetTester tester, {int frames = 12}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

late Directory _scratch;

Widget _app() => NcdPhotoMarkupApp(
  showStartupSplash: false,
  settingsServiceOverride: SettingsService(overrideDirectory: _scratch.path),
);

const AnnotationPreset _yellowNote = AnnotationPreset(
  name: 'Yellow note',
  tool: MarkupTool.textNote,
  stylePresetId: MarkupStylePresetId.yellow,
  fontFamily: MarkupTypographyConstants.defaultFontFamily,
  fontSize: 22,
);

void main() {
  setUp(() {
    _scratch = Directory.systemTemp.createTempSync('ncd_presets');
  });

  tearDown(() {
    if (_scratch.existsSync()) {
      _scratch.deleteSync(recursive: true);
    }
  });

  group('the built-in set', () {
    test('is small enough to read at a glance', () {
      expect(AnnotationPresetConstants.builtIns, hasLength(4));
      expect(
        AnnotationPresetConstants.builtIns.length,
        lessThan(AnnotationPresetConstants.maximum),
      );
    });

    test('is what a fresh install has', () {
      expect(
        AppSettings.defaults.annotationPresets,
        AnnotationPresetConstants.builtIns,
      );
    });

    test('every one names a real tool and a real colour', () {
      for (final AnnotationPreset preset
          in AnnotationPresetConstants.builtIns) {
        expect(preset.name.trim(), isNotEmpty);
        expect(MarkupTool.values, contains(preset.tool));
        expect(MarkupStylePresetId.values, contains(preset.stylePresetId));
        expect(preset.tool, isNot(MarkupTool.none));
      }
    });
  });

  group('persistence', () {
    test('a preset round-trips through JSON', () {
      final AnnotationPreset? restored = AnnotationPreset.fromJson(
        _yellowNote.toJson(),
      );
      expect(restored, _yellowNote);
    });

    test('presets round-trip through the settings file', () {
      final AppSettings settings = AppSettings.defaults.copyWith(
        annotationPresets: <AnnotationPreset>[_yellowNote],
      );
      final AppSettings restored = AppSettings.fromJson(settings.toJson());
      expect(restored.annotationPresets, <AnnotationPreset>[_yellowNote]);
    });

    test('a settings file written before presets existed gets the built-ins',
        () {
      final AppSettings restored = AppSettings.fromJson(<String, dynamic>{
        'schemaVersion': '1.0',
      });
      expect(restored.annotationPresets, AnnotationPresetConstants.builtIns);
    });

    test('deleting every preset is remembered as a decision, not an absence',
        () {
      final AppSettings settings = AppSettings.defaults.copyWith(
        annotationPresets: const <AnnotationPreset>[],
      );
      final AppSettings restored = AppSettings.fromJson(settings.toJson());
      expect(restored.annotationPresets, isEmpty);
    });

    test('a preset naming a tool this build does not have is dropped', () {
      expect(
        AnnotationPreset.fromJson(<String, dynamic>{
          'name': 'Ghost',
          'tool': 'teleport',
          'stylePresetId': 'red',
        }),
        isNull,
      );
    });

    test('a preset with no name is dropped rather than shown blank', () {
      expect(
        AnnotationPreset.fromJson(<String, dynamic>{
          'name': '   ',
          'tool': 'arrow',
          'stylePresetId': 'red',
        }),
        isNull,
      );
    });

    test('a preset with an unusable font size is dropped', () {
      expect(
        AnnotationPreset.fromJson(<String, dynamic>{
          'name': 'Huge',
          'tool': 'textNote',
          'stylePresetId': 'red',
          'fontSize': 9999,
        }),
        isNull,
      );
    });

    test('a broken preset does not take the good ones with it', () {
      final List<AnnotationPreset> presets = AnnotationPreset.listFromJson(
        <Object?>[
          _yellowNote.toJson(),
          <String, dynamic>{'name': 'Ghost', 'tool': 'teleport'},
          'not even a map',
        ],
      );
      expect(presets, <AnnotationPreset>[_yellowNote]);
    });
  });

  group('applying one', () {
    testWidgets('sets the tool, the colour and the label size in one tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app());
      await _pumpFrames(tester);
      final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));

      state.debugApplyAnnotationPreset(_yellowNote);
      await _pumpFrames(tester);

      expect(state.debugSelectedStylePresetId, MarkupStylePresetId.yellow);
      expect(state.debugSelectedFontSize, 22.0);
    });

    testWidgets('save-current captures what is selected right now', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app());
      await _pumpFrames(tester);
      final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));

      state.debugApplyAnnotationPreset(_yellowNote);
      await _pumpFrames(tester);

      final AnnotationPreset captured =
          state.debugCurrentAsPreset('My way') as AnnotationPreset;
      expect(captured.name, 'My way');
      expect(captured.tool, MarkupTool.textNote);
      expect(captured.stylePresetId, MarkupStylePresetId.yellow);
      expect(captured.fontSize, 22.0);
    });

    testWidgets('the presets section is on screen with the built-ins in it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app());
      await _pumpFrames(tester);

      final Finder expandButton = find.byKey(
        const ValueKey<String>('sidebar-rail-toggle'),
      );
      if (expandButton.evaluate().isNotEmpty) {
        await tester.tap(expandButton);
        await _pumpFrames(tester, frames: 20);
      }

      final Finder scrollable = find.descendant(
        of: find.byKey(const ValueKey<String>('sidebar-drawer-scroll')),
        matching: find.byType(Scrollable),
      );
      final Finder saveAction = find.byKey(
        const ValueKey<String>('sidebar-drawer-preset-save-current'),
      );
      await tester.scrollUntilVisible(saveAction, 220, scrollable: scrollable);
      await _pumpFrames(tester, frames: 8);

      expect(saveAction, findsOneWidget);
      expect(
        find.byKey(
          const ValueKey<String>('sidebar-drawer-preset-Blue dimension'),
        ),
        findsOneWidget,
      );
    });
  });

  group('resetting', () {
    test('the new-mark defaults reset puts the built-ins back', () {
      final AppSettings settings = AppSettings.defaults.copyWith(
        annotationPresets: const <AnnotationPreset>[],
      );
      expect(
        settings.resetDefaultsGroup().annotationPresets,
        AnnotationPresetConstants.builtIns,
      );
    });
  });
}
