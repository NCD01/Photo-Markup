import 'dart:io';

import 'package:ncd_photo_markup/core/constants/app_constants.dart';

/// Where the app keeps its own small files: the remembered tool settings and
/// the crash-recovery draft.
///
/// Resolved from platform environment variables rather than by adding a
/// path-provider dependency, because all that is needed is one writable folder
/// that survives a restart.
class AppDataDirectory {
  const AppDataDirectory({
    Map<String, String>? environment,
    String? fallbackPath,
  }) : _environmentOverride = environment,
       _fallbackOverride = fallbackPath;

  final Map<String, String>? _environmentOverride;
  final String? _fallbackOverride;

  Map<String, String> get _environment =>
      _environmentOverride ?? Platform.environment;

  String get _fallback => _fallbackOverride ?? Directory.systemTemp.path;

  /// The folder path, without creating anything.
  String resolvePath() {
    final String base = _resolveBase();
    return '$base${Platform.pathSeparator}${SessionStateConstants.folderName}';
  }

  String _resolveBase() {
    for (final String key in SessionStateConstants.baseDirectoryEnvKeys) {
      final String? value = _environment[key];
      if (value != null && value.trim().isNotEmpty) {
        if (key == SessionStateConstants.homeEnvKey) {
          // On Unix-like systems the convention is a dotted config folder
          // rather than dropping a folder straight into the home directory.
          return '${value.trim()}${Platform.pathSeparator}'
              '${SessionStateConstants.unixConfigFolderName}';
        }
        return value.trim();
      }
    }
    return _fallback;
  }

  /// The folder, created if it is not there yet. Returns null when the folder
  /// cannot be created, so callers degrade to not remembering rather than
  /// failing.
  Future<Directory?> ensure() async {
    try {
      final Directory directory = Directory(resolvePath());
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    } catch (_) {
      return null;
    }
  }
}
