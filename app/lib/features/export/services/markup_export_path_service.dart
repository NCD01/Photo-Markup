import 'dart:io';

import 'package:ncd_photo_markup/core/constants/app_constants.dart';

typedef ExportFileExists = bool Function(String path);
typedef ExportDirectoryExists = bool Function(String path);

class MarkupExportPathService {
  const MarkupExportPathService({
    ExportFileExists? fileExists,
    ExportDirectoryExists? directoryExists,
  }) : _fileExists = fileExists ?? _defaultFileExists,
       _directoryExists = directoryExists ?? _defaultDirectoryExists;

  final ExportFileExists _fileExists;
  final ExportDirectoryExists _directoryExists;

  String buildDefaultMarkupExportName({
    required String sourcePathOrFileName,
    String? suffixOverride,
  }) {
    final String sourceName = _fileNameFromPath(sourcePathOrFileName);
    final int extensionIndex = sourceName.lastIndexOf('.');
    final String baseName = extensionIndex > 0
        ? sourceName.substring(0, extensionIndex)
        : sourceName;
    // An empty suffix would collide with the source photo, so it is refused.
    final String suffix =
        (suffixOverride != null && suffixOverride.trim().isNotEmpty)
        ? suffixOverride
        : ExportConstants.defaultFileSuffix;
    return '$baseName$suffix.${ExportConstants.outputExtension}';
  }

  String ensurePngExtension(String path) {
    final String extension = '.${ExportConstants.outputExtension}';
    if (path.toLowerCase().endsWith(extension)) {
      return path;
    }
    return '$path$extension';
  }

  String? resolveDefaultExportDirectory({
    String? suggestedExportFolder,
    String? sourceImagePath,
  }) {
    final String? cleanSuggested = _cleanValue(suggestedExportFolder);
    if (cleanSuggested != null && _directoryExists(cleanSuggested)) {
      return cleanSuggested;
    }

    final String? cleanSourcePath = _cleanValue(sourceImagePath);
    if (cleanSourcePath == null) {
      return null;
    }
    final String sourceParent = _parentDirectory(cleanSourcePath);
    if (sourceParent.isEmpty || !_directoryExists(sourceParent)) {
      return null;
    }
    return sourceParent;
  }

  String buildSafeMarkupExportPath(String preferredPath) {
    final String normalizedPath = ensurePngExtension(preferredPath);
    if (!_fileExists(normalizedPath)) {
      return normalizedPath;
    }

    final String parent = _parentDirectory(normalizedPath);
    final String fileName = _fileNameFromPath(normalizedPath);
    final int extensionIndex = fileName.lastIndexOf('.');
    final String baseName = extensionIndex > 0
        ? fileName.substring(0, extensionIndex)
        : fileName;
    final String extension = extensionIndex > 0
        ? fileName.substring(extensionIndex)
        : '.${ExportConstants.outputExtension}';

    int sequence = ExportConstants.duplicateNameStartIndex;
    while (true) {
      final String candidateName =
          '$baseName${ExportConstants.duplicateNameSeparator}$sequence$extension';
      final String candidatePath = parent.isEmpty
          ? candidateName
          : '$parent${Platform.pathSeparator}$candidateName';
      if (!_fileExists(candidatePath)) {
        return candidatePath;
      }
      sequence += 1;
    }
  }

  static bool _defaultFileExists(String path) => File(path).existsSync();

  static bool _defaultDirectoryExists(String path) =>
      Directory(path).existsSync();

  static String _fileNameFromPath(String path) {
    final String normalized = path.replaceAll('\\', '/');
    final List<String> segments = normalized.split('/');
    return segments.isEmpty ? path : segments.last;
  }

  static String _parentDirectory(String path) {
    final int windowsIndex = path.lastIndexOf('\\');
    final int unixIndex = path.lastIndexOf('/');
    final int separatorIndex = windowsIndex > unixIndex
        ? windowsIndex
        : unixIndex;
    if (separatorIndex <= 0) {
      return '';
    }
    return path.substring(0, separatorIndex);
  }

  static String? _cleanValue(String? value) {
    if (value == null) {
      return null;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
