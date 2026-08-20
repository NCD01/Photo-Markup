import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/settings/models/annotation_preset.dart';

/// How a measured length is written out.
///
/// [tape] is what a person reads off a tape measure: feet and inches, or metric
/// stepped by magnitude. [decimal] is the raw calibrated number, which is what
/// the app did before v0.35 and what you want if the value is being copied into
/// a quote or a spreadsheet.
enum MeasurementDisplayMode { tape, decimal }

/// Which system measured lengths are reported in.
///
/// [auto] reports in whatever the photo was calibrated in, which is what the
/// app did before this setting existed. [imperial] and [metric] convert for
/// display, whatever the calibration was.
///
/// Conversion is display only. The stored geometry keeps the value that was
/// actually measured, in the unit it was measured in, and changing this
/// setting rewrites every label without touching a single stored number.
enum MeasurementUnitSystem { auto, imperial, metric }

/// Everything the app remembers between runs.
///
/// Settings never touch stored geometry. Changing anything here changes how new
/// marks are created or how existing ones are displayed, never the measured
/// numbers already on a photo.
class AppSettings {
  const AppSettings({
    this.measurementDisplayMode = SettingsConstants.defaultMeasurementDisplayMode,
    this.measurementUnitSystem = SettingsConstants.defaultMeasurementUnitSystem,
    this.autoLabelDimensions = SettingsConstants.defaultAutoLabelDimensions,
    this.autosaveIntervalSeconds = RecoveryConstants.defaultIntervalSeconds,
    this.defaultStylePresetId = SettingsConstants.defaultStylePresetId,
    this.defaultFontSize = MarkupTypographyConstants.defaultFontSize,
    this.exportFileSuffix = ExportConstants.defaultFileSuffix,
    this.defaultExportDirectory,
    List<AnnotationPreset>? annotationPresets,
  }) : _annotationPresets = annotationPresets;

  final MeasurementDisplayMode measurementDisplayMode;
  final MeasurementUnitSystem measurementUnitSystem;
  final bool autoLabelDimensions;
  final int autosaveIntervalSeconds;
  final MarkupStylePresetId defaultStylePresetId;
  final double defaultFontSize;
  final String exportFileSuffix;
  final String? defaultExportDirectory;

  final List<AnnotationPreset>? _annotationPresets;

  /// The saved presets, falling back to the built-in set for a settings file
  /// written before presets existed. An empty list is kept as an empty list,
  /// because deleting every preset is a decision, not an absence.
  List<AnnotationPreset> get annotationPresets =>
      _annotationPresets ?? AnnotationPresetConstants.builtIns;

  static const AppSettings defaults = AppSettings();

  AppSettings copyWith({
    MeasurementDisplayMode? measurementDisplayMode,
    MeasurementUnitSystem? measurementUnitSystem,
    bool? autoLabelDimensions,
    int? autosaveIntervalSeconds,
    MarkupStylePresetId? defaultStylePresetId,
    double? defaultFontSize,
    String? exportFileSuffix,
    String? defaultExportDirectory,
    List<AnnotationPreset>? annotationPresets,
    bool clearDefaultExportDirectory = false,
  }) {
    return AppSettings(
      measurementDisplayMode:
          measurementDisplayMode ?? this.measurementDisplayMode,
      measurementUnitSystem:
          measurementUnitSystem ?? this.measurementUnitSystem,
      autoLabelDimensions: autoLabelDimensions ?? this.autoLabelDimensions,
      autosaveIntervalSeconds:
          autosaveIntervalSeconds ?? this.autosaveIntervalSeconds,
      defaultStylePresetId: defaultStylePresetId ?? this.defaultStylePresetId,
      defaultFontSize: defaultFontSize ?? this.defaultFontSize,
      exportFileSuffix: exportFileSuffix ?? this.exportFileSuffix,
      defaultExportDirectory: clearDefaultExportDirectory
          ? null
          : (defaultExportDirectory ?? this.defaultExportDirectory),
      annotationPresets: annotationPresets ?? _annotationPresets,
    );
  }

  /// Restores only the measurement group, leaving everything else alone.
  AppSettings resetMeasurementGroup() {
    return copyWith(
      measurementDisplayMode: defaults.measurementDisplayMode,
      measurementUnitSystem: defaults.measurementUnitSystem,
      autoLabelDimensions: defaults.autoLabelDimensions,
      autosaveIntervalSeconds: defaults.autosaveIntervalSeconds,
    );
  }

  /// Restores only the new-mark defaults group, presets included.
  AppSettings resetDefaultsGroup() {
    return copyWith(
      defaultStylePresetId: defaults.defaultStylePresetId,
      defaultFontSize: defaults.defaultFontSize,
      annotationPresets: AnnotationPresetConstants.builtIns,
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
      'measurementUnitSystem': measurementUnitSystem.name,
      'autoLabelDimensions': autoLabelDimensions,
      'autosaveIntervalSeconds': autosaveIntervalSeconds,
      'defaultStylePresetId': defaultStylePresetId.name,
      'defaultFontSize': defaultFontSize,
      'exportFileSuffix': exportFileSuffix,
      if (defaultExportDirectory != null)
        'defaultExportDirectory': defaultExportDirectory,
      'annotationPresets': annotationPresets
          .map((AnnotationPreset preset) => preset.toJson())
          .toList(growable: false),
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
      measurementUnitSystem: _unitSystemFrom(json['measurementUnitSystem']),
      autoLabelDimensions:
          _boolFrom(json['autoLabelDimensions']) ??
          defaults.autoLabelDimensions,
      autosaveIntervalSeconds:
          _autosaveIntervalFrom(json['autosaveIntervalSeconds']) ??
          defaults.autosaveIntervalSeconds,
      defaultStylePresetId: _presetFrom(json['defaultStylePresetId']),
      defaultFontSize:
          _fontSizeFrom(json['defaultFontSize']) ?? defaults.defaultFontSize,
      exportFileSuffix:
          _suffixFrom(json['exportFileSuffix']) ?? defaults.exportFileSuffix,
      defaultExportDirectory: _directoryFrom(json['defaultExportDirectory']),
      annotationPresets: json.containsKey('annotationPresets')
          ? AnnotationPreset.listFromJson(json['annotationPresets'])
          : null,
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

  static MeasurementUnitSystem _unitSystemFrom(Object? raw) {
    for (final MeasurementUnitSystem system in MeasurementUnitSystem.values) {
      if (system.name == raw) {
        return system;
      }
    }
    return defaults.measurementUnitSystem;
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

  /// Out-of-range values fall back to the default rather than being clamped,
  /// because a number outside the range never came from the app's own control
  /// and is more likely a hand-edited mistake than an intention.
  static int? _autosaveIntervalFrom(Object? raw) {
    final int? value = raw is num ? raw.round() : null;
    if (value == null ||
        value < RecoveryConstants.minimumIntervalSeconds ||
        value > RecoveryConstants.maximumIntervalSeconds) {
      return null;
    }
    return value;
  }

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
