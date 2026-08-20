import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

/// How a measured length is written out.
///
/// [tape] is what a person reads off a tape measure: feet and inches, or metric
/// stepped by magnitude. [decimal] is the raw calibrated number, which is what
/// the app did before v0.35 and what you want if the value is being copied into
/// a quote or a spreadsheet.
enum MeasurementDisplayMode { tape, decimal }

/// Everything the app remembers between runs.
///
/// Settings never touch stored geometry. Changing anything here changes how new
/// marks are created or how existing ones are displayed, never the measured
/// numbers already on a photo.
class AppSettings {
  const AppSettings({
    this.measurementDisplayMode = SettingsConstants.defaultMeasurementDisplayMode,
    this.autoLabelDimensions = SettingsConstants.defaultAutoLabelDimensions,
    this.defaultStylePresetId = SettingsConstants.defaultStylePresetId,
    this.defaultFontSize = MarkupTypographyConstants.defaultFontSize,
    this.exportFileSuffix = ExportConstants.defaultFileSuffix,
    this.defaultExportDirectory,
  });

  final MeasurementDisplayMode measurementDisplayMode;
  final bool autoLabelDimensions;
  final MarkupStylePresetId defaultStylePresetId;
  final double defaultFontSize;
  final String exportFileSuffix;
  final String? defaultExportDirectory;

  static const AppSettings defaults = AppSettings();

  AppSettings copyWith({
    MeasurementDisplayMode? measurementDisplayMode,
    bool? autoLabelDimensions,
    MarkupStylePresetId? defaultStylePresetId,
    double? defaultFontSize,
    String? exportFileSuffix,
    String? defaultExportDirectory,
    bool clearDefaultExportDirectory = false,
  }) {
    return AppSettings(
      measurementDisplayMode:
          measurementDisplayMode ?? this.measurementDisplayMode,
      autoLabelDimensions: autoLabelDimensions ?? this.autoLabelDimensions,
      defaultStylePresetId: defaultStylePresetId ?? this.defaultStylePresetId,
      defaultFontSize: defaultFontSize ?? this.defaultFontSize,
      exportFileSuffix: exportFileSuffix ?? this.exportFileSuffix,
      defaultExportDirectory: clearDefaultExportDirectory
          ? null
          : (defaultExportDirectory ?? this.defaultExportDirectory),
    );
  }

  /// Restores only the measurement group, leaving everything else alone.
  AppSettings resetMeasurementGroup() {
    return copyWith(
      measurementDisplayMode: defaults.measurementDisplayMode,
      autoLabelDimensions: defaults.autoLabelDimensions,
    );
  }

  /// Restores only the new-mark defaults group.
  AppSettings resetDefaultsGroup() {
    return copyWith(
      defaultStylePresetId: defaults.defaultStylePresetId,
      defaultFontSize: defaults.defaultFontSize,
    );
  }

  /// Restores only the export group.
  AppSettings resetExportGroup() {
    return copyWith(
      exportFileSuffix: defaults.exportFileSuffix,
      clearDefaultExportDirectory: true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schemaVersion': SettingsConstants.schemaVersion,
      'measurementDisplayMode': measurementDisplayMode.name,
      'autoLabelDimensions': autoLabelDimensions,
      'defaultStylePresetId': defaultStylePresetId.name,
      'defaultFontSize': defaultFontSize,
      'exportFileSuffix': exportFileSuffix,
      if (defaultExportDirectory != null)
        'defaultExportDirectory': defaultExportDirectory,
    };
  }

  /// Reads settings written by this or an older build.
  ///
  /// Every field is optional on read and falls back to its default, so a
  /// settings file written by an older version keeps working after an update
  /// instead of throwing the user back to defaults wholesale.
  static AppSettings fromJson(Map<String, dynamic> json) {
    return AppSettings(
      measurementDisplayMode: _modeFrom(json['measurementDisplayMode']),
      autoLabelDimensions:
          _boolFrom(json['autoLabelDimensions']) ??
          defaults.autoLabelDimensions,
      defaultStylePresetId: _presetFrom(json['defaultStylePresetId']),
      defaultFontSize:
          _fontSizeFrom(json['defaultFontSize']) ?? defaults.defaultFontSize,
      exportFileSuffix:
          _suffixFrom(json['exportFileSuffix']) ?? defaults.exportFileSuffix,
      defaultExportDirectory: _directoryFrom(json['defaultExportDirectory']),
    );
  }

  static MeasurementDisplayMode _modeFrom(Object? raw) {
    for (final MeasurementDisplayMode mode in MeasurementDisplayMode.values) {
      if (mode.name == raw) {
        return mode;
      }
    }
    return defaults.measurementDisplayMode;
  }

  static MarkupStylePresetId _presetFrom(Object? raw) {
    for (final MarkupStylePresetId id in MarkupStylePresetId.values) {
      if (id.name == raw) {
        return id;
      }
    }
    return defaults.defaultStylePresetId;
  }

  static bool? _boolFrom(Object? raw) => raw is bool ? raw : null;

  static double? _fontSizeFrom(Object? raw) {
    final double? value = raw is num ? raw.toDouble() : null;
    if (value == null ||
        value < MarkupTypographyConstants.minFontSize ||
        value > MarkupTypographyConstants.maxFontSize) {
      return null;
    }
    return value;
  }

  static String? _suffixFrom(Object? raw) {
    if (raw is! String) {
      return null;
    }
    // An empty suffix would make the export collide with the source file name.
    return raw.trim().isEmpty ? null : raw;
  }

  static String? _directoryFrom(Object? raw) {
    if (raw is! String) {
      return null;
    }
    final String trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
