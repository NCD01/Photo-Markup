import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:heic_to_png_jpg/heic_to_png_jpg.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';

typedef HeicFileConverter =
    Future<bool> Function({
      required String sourcePath,
      required String outputPath,
      required int maxPreviewDimension,
    });
typedef ExternalHeicConverter =
    Future<bool> Function({
      required String sourcePath,
      required String outputPath,
    });

class ImageImportResult {
  const ImageImportResult({
    required this.sourcePath,
    required this.displayPath,
    required this.usedTemporaryConvertedCopy,
  });

  final String sourcePath;
  final String displayPath;
  final bool usedTemporaryConvertedCopy;
}

class ImageImportService {
  ImageImportService({
    HeicFileConverter? heicFileConverter,
    ExternalHeicConverter? externalHeicConverter,
    String? tempDirectoryPath,
  }) : _heicFileConverter = heicFileConverter ?? _defaultHeicFileConverter,
       _externalHeicConverter =
           externalHeicConverter ?? _defaultExternalHeicConverter,
       _tempDirectoryPath = tempDirectoryPath ?? Directory.systemTemp.path;

  final HeicFileConverter _heicFileConverter;
  final ExternalHeicConverter _externalHeicConverter;
  final String _tempDirectoryPath;

  Future<ImageImportResult> prepareDisplayableImage({
    required String sourcePath,
  }) async {
    final String extension = _fileExtension(sourcePath);
    if (!ImageImportConstants.heicExtensionsSet.contains(extension)) {
      return ImageImportResult(
        sourcePath: sourcePath,
        displayPath: sourcePath,
        usedTemporaryConvertedCopy: false,
      );
    }

    final String tempPath = _buildTempPath(sourcePath);
    await _cleanupStaleTemporaryConvertedFiles();

    final Stopwatch totalStopwatch = Stopwatch()..start();
    await _convertHeicToDisplayableImage(
      sourcePath: sourcePath,
      outputPath: tempPath,
    );
    totalStopwatch.stop();
    _logDebug(
      'prepareDisplayableImage complete in ${totalStopwatch.elapsedMilliseconds}ms',
    );

    return ImageImportResult(
      sourcePath: sourcePath,
      displayPath: tempPath,
      usedTemporaryConvertedCopy: true,
    );
  }

  Future<void> deleteTemporaryDisplayPath(String? displayPath) async {
    if (displayPath == null || displayPath.isEmpty) {
      return;
    }
    try {
      final File file = File(displayPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort temp cleanup only.
    }
  }

  String _buildTempPath(String sourcePath) {
    final String normalized = sourcePath.replaceAll('\\', '/');
    final String rawName = normalized.split('/').last;
    final int dotIndex = rawName.lastIndexOf('.');
    final String baseName = dotIndex > 0
        ? rawName.substring(0, dotIndex)
        : rawName;
    final String safeBaseName = baseName.replaceAll(
      RegExp(r'[^A-Za-z0-9_-]'),
      '_',
    );
    final String timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    return '$_tempDirectoryPath${Platform.pathSeparator}$safeBaseName${ImageImportConstants.heicTempSuffix}_$timestamp.${ImageImportConstants.heicConvertedOutputExtension}';
  }

  String _fileExtension(String path) {
    final int dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex >= path.length - 1) {
      return '';
    }
    return path.substring(dotIndex + 1).toLowerCase();
  }

  Future<void> _cleanupStaleTemporaryConvertedFiles() async {
    try {
      final Directory tempDirectory = Directory(_tempDirectoryPath);
      if (!await tempDirectory.exists()) {
        return;
      }

      final DateTime now = DateTime.now();
      final DateTime cutoff = now.subtract(
        Duration(hours: ImageImportConstants.tempConvertedFileMaxAgeHours),
      );
      final List<FileSystemEntity> matchingFiles = await tempDirectory
          .list(followLinks: false)
          .where(
            (FileSystemEntity entity) =>
                entity is File &&
                entity.path.contains(ImageImportConstants.heicTempSuffix) &&
                entity.path.toLowerCase().endsWith(
                  '.${ImageImportConstants.heicConvertedOutputExtension}',
                ),
          )
          .toList();

      final List<File> files = matchingFiles.whereType<File>().toList();
      final List<_TempFileMeta> metadata = <_TempFileMeta>[];
      for (final File file in files) {
        final FileStat stat = await file.stat();
        metadata.add(
          _TempFileMeta(
            file: file,
            modified: stat.modified,
          ),
        );
      }

      for (final _TempFileMeta item in metadata) {
        if (item.modified.isBefore(cutoff)) {
          await item.file.delete();
        }
      }

      if (files.length <= ImageImportConstants.tempConvertedFileMaxCount) {
        return;
      }

      metadata.sort(
        (_TempFileMeta a, _TempFileMeta b) => a.modified.compareTo(b.modified),
      );
      final int overflow =
          metadata.length - ImageImportConstants.tempConvertedFileMaxCount;
      for (int i = 0; i < overflow; i += 1) {
        final File file = metadata[i].file;
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {
      // Best-effort temp cleanup only.
    }
  }

  Future<void> _convertHeicToDisplayableImage({
    required String sourcePath,
    required String outputPath,
  }) async {
    final File outputFile = File(outputPath);
    await outputFile.parent.create(recursive: true);

    bool packageConversionSucceeded = false;
    final Stopwatch packageStopwatch = Stopwatch()..start();
    try {
      packageConversionSucceeded = await _heicFileConverter(
        sourcePath: sourcePath,
        outputPath: outputPath,
        maxPreviewDimension: ImageImportConstants.heicMaxPreviewDimension,
      );
    } catch (_) {
      packageConversionSucceeded = false;
    }
    packageStopwatch.stop();
    _logDebug(
      'package conversion success=$packageConversionSucceeded duration=${packageStopwatch.elapsedMilliseconds}ms',
    );

    if (!packageConversionSucceeded) {
      final Stopwatch fallbackStopwatch = Stopwatch()..start();
      final bool externalSucceeded = await _externalHeicConverter(
        sourcePath: sourcePath,
        outputPath: outputPath,
      );
      fallbackStopwatch.stop();
      _logDebug(
        'fallback conversion success=$externalSucceeded duration=${fallbackStopwatch.elapsedMilliseconds}ms',
      );
      if (!externalSucceeded) {
        throw const ConversionFailedException(
          ImageImportConstants.heicConversionFailedMessage,
        );
      }
    }

    if (!await outputFile.exists() || await outputFile.length() == 0) {
      throw const ConversionFailedException(
        ImageImportConstants.heicConversionFailedMessage,
      );
    }
  }

  static Future<bool> _defaultHeicFileConverter({
    required String sourcePath,
    required String outputPath,
    required int maxPreviewDimension,
  }) async {
    bool packageConversionSucceeded = false;
    try {
      final String writtenPath = await HeicConverter.convertFile(
        inputPath: sourcePath,
        outputPath: outputPath,
        format: ImageFormat.png,
        maxWidth: maxPreviewDimension,
        maxHeight: maxPreviewDimension,
      ).timeout(ImageImportConstants.heicPackageConversionTimeout);
      final File convertedFile = File(writtenPath);
      if (await convertedFile.exists() && await convertedFile.length() > 0) {
        packageConversionSucceeded = true;
      }
    } catch (_) {
      packageConversionSucceeded = false;
    }
    return packageConversionSucceeded;
  }

  static Future<bool> _defaultExternalHeicConverter({
    required String sourcePath,
    required String outputPath,
  }) async {
    try {
      final List<String> args = <String>[
        sourcePath,
        ...ImageImportConstants.heicFallbackConverterOptions,
        outputPath,
      ];
      final ProcessResult result = await Process.run(
        ImageImportConstants.heicFallbackConverterCommand,
        args,
      );
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  void _logDebug(String message) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('${ImageImportConstants.importDiagnosticsPrefix} $message');
  }
}

class _TempFileMeta {
  const _TempFileMeta({
    required this.file,
    required this.modified,
  });

  final File file;
  final DateTime modified;
}
