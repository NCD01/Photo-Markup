import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/settings/models/app_settings.dart';
import 'package:ncd_photo_markup/features/settings/services/settings_service.dart';

void main() {
  late Directory workDir;
  late SettingsService service;

  setUp(() {
    workDir = Directory.systemTemp.createTempSync('ncd_settings_test');
    service = SettingsService(overrideDirectory: workDir.path);
  });

  tearDown(() {
    if (workDir.existsSync()) {
      workDir.deleteSync(recursive: true);
    }
  });

  group('SettingsService', () {
    test('a first run with no file returns defaults rather than failing', () async {
      final AppSettings loaded = await service.load();
      expect(loaded.measurementDisplayMode, MeasurementDisplayMode.tape);
      expect(loaded.autoLabelDimensions, isTrue);
      expect(loaded.defaultStylePresetId, MarkupStylePresetId.ncdBlue);
      expect(loaded.defaultExportDirectory, isNull);
    });

    test('every setting survives a save and reload', () async {
      const AppSettings changed = AppSettings(
        measurementDisplayMode: MeasurementDisplayMode.decimal,
        autoLabelDimensions: false,
        defaultStylePresetId: MarkupStylePresetId.red,
        defaultFontSize: 28,
        exportFileSuffix: ' - Marked',
        defaultExportDirectory: r'C:\jobs\1042',
      );

      expect(await service.save(changed), isTrue);
      final AppSettings loaded = await service.load();

      expect(loaded.measurementDisplayMode, MeasurementDisplayMode.decimal);
      expect(loaded.autoLabelDimensions, isFalse);
      expect(loaded.defaultStylePresetId, MarkupStylePresetId.red);
      expect(loaded.defaultFontSize, 28);
      expect(loaded.exportFileSuffix, ' - Marked');
      expect(loaded.defaultExportDirectory, r'C:\jobs\1042');
    });

    test('settings written by an older build still load', () async {
      // Only two fields, as an earlier version might have written. Everything
      // missing must fall back to its default, not wipe the lot.
      final File file = File(service.resolveFilePath());
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        jsonEncode(<String, dynamic>{
          'schemaVersion': '0.9',
          'autoLabelDimensions': false,
        }),
      );

      final AppSettings loaded = await service.load();
      expect(loaded.autoLabelDimensions, isFalse);
      expect(loaded.measurementDisplayMode, MeasurementDisplayMode.tape);
      expect(loaded.defaultStylePresetId, MarkupStylePresetId.ncdBlue);
    });

    test('a corrupt settings file falls back to defaults instead of throwing',
        () async {
      final File file = File(service.resolveFilePath());
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('{ this is not json');

      final AppSettings loaded = await service.load();
      expect(loaded.autoLabelDimensions, AppSettings.defaults.autoLabelDimensions);
    });

    test('a nonsense value is rejected rather than stored', () async {
      final File file = File(service.resolveFilePath());
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        jsonEncode(<String, dynamic>{
          'defaultFontSize': 9999,
          'exportFileSuffix': '   ',
          'measurementDisplayMode': 'nonsense',
        }),
      );

      final AppSettings loaded = await service.load();
      expect(loaded.defaultFontSize, MarkupTypographyConstants.defaultFontSize);
      expect(loaded.exportFileSuffix, ExportConstants.defaultFileSuffix);
      expect(loaded.measurementDisplayMode, MeasurementDisplayMode.tape);
    });

    test('an interrupted write leaves no stray partial file behind', () async {
      await service.save(AppSettings.defaults);
      final Iterable<String> names = Directory(service.resolveDirectory())
          .listSync()
          .map((FileSystemEntity e) => e.path.split(Platform.pathSeparator).last);
      expect(names, contains(SettingsConstants.fileName));
      expect(
        names.where((String n) => n.endsWith(SettingsConstants.partialSuffix)),
        isEmpty,
      );
    });

    test('APPDATA decides the folder on Windows', () {
      final SettingsService envService = SettingsService(
        environment: <String, String>{'APPDATA': r'C:\Users\test\AppData\Roaming'},
      );
      expect(envService.resolveDirectory(), contains('AppData'));
      expect(
        envService.resolveDirectory(),
        contains(SettingsConstants.directoryName),
      );
    });
  });

  group('AppSettings per-section reset', () {
    const AppSettings changed = AppSettings(
      measurementDisplayMode: MeasurementDisplayMode.decimal,
      autoLabelDimensions: false,
      defaultStylePresetId: MarkupStylePresetId.red,
      defaultFontSize: 30,
      exportFileSuffix: ' - Marked',
      defaultExportDirectory: r'C:\jobs',
    );

    test('resetting measurement leaves the other sections alone', () {
      final AppSettings result = changed.resetMeasurementGroup();
      expect(result.measurementDisplayMode, MeasurementDisplayMode.tape);
      expect(result.autoLabelDimensions, isTrue);
      // Untouched.
      expect(result.defaultStylePresetId, MarkupStylePresetId.red);
      expect(result.exportFileSuffix, ' - Marked');
    });

    test('resetting defaults leaves the other sections alone', () {
      final AppSettings result = changed.resetDefaultsGroup();
      expect(result.defaultStylePresetId, MarkupStylePresetId.ncdBlue);
      expect(result.defaultFontSize, MarkupTypographyConstants.defaultFontSize);
      // Untouched.
      expect(result.measurementDisplayMode, MeasurementDisplayMode.decimal);
      expect(result.exportFileSuffix, ' - Marked');
    });

    test('resetting export clears the folder and restores the suffix', () {
      final AppSettings result = changed.resetExportGroup();
      expect(result.exportFileSuffix, ExportConstants.defaultFileSuffix);
      expect(result.defaultExportDirectory, isNull);
      // Untouched.
      expect(result.defaultStylePresetId, MarkupStylePresetId.red);
      expect(result.autoLabelDimensions, isFalse);
    });
  });
}
