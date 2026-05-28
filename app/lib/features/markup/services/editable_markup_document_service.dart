import 'dart:convert';
import 'dart:io';

import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/editable_markup_document.dart';

typedef MarkupFileExists = bool Function(String path);
typedef MarkupDirectoryExists = bool Function(String path);

class EditableMarkupDocumentService {
  const EditableMarkupDocumentService({
    MarkupFileExists? fileExists,
    MarkupDirectoryExists? directoryExists,
  }) : _fileExists = fileExists ?? _defaultFileExists,
       _directoryExists = directoryExists ?? _defaultDirectoryExists;

  final MarkupFileExists _fileExists;
  final MarkupDirectoryExists _directoryExists;

  String buildDefaultMarkupFileName({required String sourcePathOrFileName}) {
    final String sourceName = _fileNameFromPath(sourcePathOrFileName);
    final int extensionIndex = sourceName.lastIndexOf('.');
    final String baseName = extensionIndex > 0
        ? sourceName.substring(0, extensionIndex)
        : sourceName;
    return '$baseName${ExportConstants.defaultFileSuffix}${EditableMarkupConstants.outputFileSuffix}';
  }

  String? resolveDefaultMarkupDirectory({
    String? suggestedEditableMarkupFolder,
    String? suggestedExportFolder,
    String? sourceImagePath,
  }) {
    final String? cleanEditable = _cleanValue(suggestedEditableMarkupFolder);
    if (cleanEditable != null && _directoryExists(cleanEditable)) {
      return cleanEditable;
    }

    final String? cleanExport = _cleanValue(suggestedExportFolder);
    if (cleanExport != null && _directoryExists(cleanExport)) {
      return cleanExport;
    }

    final String? cleanSource = _cleanValue(sourceImagePath);
    if (cleanSource == null) {
      return null;
    }
    final String parent = _parentDirectory(cleanSource);
    if (parent.isEmpty || !_directoryExists(parent)) {
      return null;
    }
    return parent;
  }

  String ensureEditableMarkupExtension(String path) {
    final String lower = path.toLowerCase();
    final String extension = EditableMarkupConstants.outputFileSuffix;
    if (lower.endsWith(extension)) {
      return path;
    }
    if (lower.endsWith('.json')) {
      return '${path.substring(0, path.length - 5)}$extension';
    }
    return '$path$extension';
  }

  String buildSafeEditableMarkupPath(String preferredPath) {
    final String normalized = ensureEditableMarkupExtension(preferredPath);
    if (!_fileExists(normalized)) {
      return normalized;
    }

    final String parent = _parentDirectory(normalized);
    final String fileName = _fileNameFromPath(normalized);
    final String suffix = EditableMarkupConstants.outputFileSuffix;
    final String lowerName = fileName.toLowerCase();
    final String baseName = lowerName.endsWith(suffix)
        ? fileName.substring(0, fileName.length - suffix.length)
        : fileName;

    int sequence = EditableMarkupConstants.duplicateNameStartIndex;
    while (true) {
      final String candidateName =
          '$baseName${EditableMarkupConstants.duplicateNameSeparator}$sequence$suffix';
      final String candidatePath = parent.isEmpty
          ? candidateName
          : '$parent${Platform.pathSeparator}$candidateName';
      if (!_fileExists(candidatePath)) {
        return candidatePath;
      }
      sequence += 1;
    }
  }

  Future<void> saveDocument({
    required EditableMarkupDocument document,
    required String outputPath,
  }) async {
    final String normalized = ensureEditableMarkupExtension(outputPath);
    final File outputFile = File(normalized);
    await outputFile.parent.create(recursive: true);
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    await outputFile.writeAsString(encoder.convert(document.toJson()));
  }

  Future<EditableMarkupDocument> readDocument(String filePath) async {
    final String text = await File(filePath).readAsString();
    final dynamic decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Editable markup file is not a JSON object.');
    }
    return EditableMarkupDocument.fromJson(decoded);
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
