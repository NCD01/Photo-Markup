import 'dart:convert';
import 'dart:io';

import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/settings/models/app_settings.dart';

/// Reads and writes [AppSettings] to a JSON file beside the user's profile.
///
/// Deliberately built on `dart:io` rather than adding a preferences package.
/// The app has no network dependency and this keeps it that way.
///
/// Every failure path returns defaults rather than throwing. A settings file
/// that cannot be read is never a reason to stop someone marking up a photo.
class SettingsService {
  SettingsService({String? overrideDirectory, Map<String, String>? environment})
    : _overrideDirectory = overrideDirectory,
      _environment = environment ?? Platform.environment;

  final String? _overrideDirectory;
  final Map<String, String> _environment;

  /// Where the settings file lives.
  ///
  /// Windows puts it under APPDATA. Anything else falls back through the XDG
  /// config directory, then the home directory, then the system temp directory,
  /// so there is always somewhere to write.
  String resolveDirectory() {
    final String? override = _overrideDirectory;
    if (override != null && override.trim().isNotEmpty) {
      return override;
    }
    for (final String key in SettingsConstants.directoryEnvironmentKeys) {
      final String? value = _environment[key];
      if (value != null && value.trim().isNotEmpty) {
        return '${value.trim()}${Platform.pathSeparator}'
            '${SettingsConstants.directoryName}';
      }
    }
    return '${Directory.systemTemp.path}${Platform.pathSeparator}'
        '${SettingsConstants.directoryName}';
  }

  String resolveFilePath() =>
      '${resolveDirectory()}${Platform.pathSeparator}'
      '${SettingsConstants.fileName}';

  Future<AppSettings> load() async {
    try {
      final File file = File(resolveFilePath());
      if (!await file.exists()) {
        return AppSettings.defaults;
      }
      final String raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return AppSettings.defaults;
      }
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return AppSettings.defaults;
      }
      return AppSettings.fromJson(decoded);
    } catch (_) {
      // Corrupt or unreadable settings fall back to defaults rather than
      // taking the app down on launch.
      return AppSettings.defaults;
    }
  }

  /// Writes settings, returning whether the write landed.
  ///
  /// Writes to a temporary file and renames it into place, so an interrupted
  /// write leaves the previous good settings rather than a half-written file.
  Future<bool> save(AppSettings settings) async {
    try {
      final Directory directory = Directory(resolveDirectory());
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final String target = resolveFilePath();
      final File temporary = File(
        '$target${SettingsConstants.partialSuffix}',
      );
      await temporary.writeAsString(
        const JsonEncoder.withIndent('  ').convert(settings.toJson()),
        flush: true,
      );
      if (await File(target).exists()) {
        await File(target).delete();
      }
      await temporary.rename(target);
      return true;
    } catch (_) {
      return false;
    }
  }
}
