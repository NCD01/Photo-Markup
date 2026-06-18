import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:heic_to_png_jpg/heic_to_png_jpg.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/import/services/dwg_preview_conversion_service.dart';

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
    DwgPreviewConversionService? dwgPreviewConversionService,
    String? tempDirectoryPath,
  }) : _heicFileConverter = heicFileConverter ?? _defaultHeicFileConverter,
       _externalHeicConverter =
           externalHeicConverter ?? _defaultExternalHeicConverter,
       _dwgPreviewConversionService =
           dwgPreviewConversionService ??
               DwgPreviewConversionService(tempDirectoryPath: tempDirectoryPath),
       _cacheDirectoryPath =
           '${tempDirectoryPath ?? Directory.systemTemp.path}${Platform.pathSeparator}${ImageImportConstants.heicPreviewCacheFolderName}';

  final HeicFileConverter _heicFileConverter;
  final ExternalHeicConverter _externalHeicConverter;
  final DwgPreviewConversionService _dwgPreviewConversionService;
  final String _cacheDirectoryPath;

  Future<ImageImportResult> prepareDisplayableImage({
    required String sourcePath,
  }) async {
    final String extension = _fileExtension(sourcePath);
    if (ImageImportConstants.dwgExtensionsSet.contains(extension)) {
      final String previewPath = await _dwgPreviewConversionService
          .prepareDisplayablePreview(
        sourcePath: sourcePath,
      );
      return ImageImportResult(
        sourcePath: sourcePath,
        displayPath: previewPath,
        usedTemporaryConvertedCopy: true,
      );
    }
    if (!ImageImportConstants.heicExtensionsSet.contains(extension)) {
      return ImageImportResult(
        sourcePath: sourcePath,
        displayPath: sourcePath,
        usedTemporaryConvertedCopy: false,
      );
    }

    await _cleanupStaleTemporaryConvertedFiles();
    final String tempPath = await _buildCachedTempPath(sourcePath);
    if (await _isUsableConvertedFile(tempPath)) {
      _logDebug('cache hit path=$tempPath');
      return ImageImportResult(
        sourcePath: sourcePath,
        displayPath: tempPath,
        usedTemporaryConvertedCopy: true,
      );
    }

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
    if (_isHeicPreviewCachePath(displayPath) ||
        _dwgPreviewConversionService.isManagedPreviewPath(displayPath)) {
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

  Future<String> _buildCachedTempPath(String sourcePath) async {
    final File sourceFile = File(sourcePath);
    final FileStat sourceStat = await sourceFile.stat();
    final String absolutePath = sourceFile.absolute.path;
    final String signature =
        '${ImageImportConstants.heicPreviewCacheKeyVersion}|'
        '${absolutePath.toLowerCase()}|'
        '${sourceStat.size}|'
        '${sourceStat.modified.millisecondsSinceEpoch}|'
        '${ImageImportConstants.heicMaxPreviewDimension}|'
        '${ImageImportConstants.heicPreviewJpegQuality}|'
        '${ImageImportConstants.heicConvertedOutputExtension}|'
        '${ImageImportConstants.heicPreferFallbackConverterFirst}';
    final String cacheKey = _stableCacheKey(signature);
    return '$_cacheDirectoryPath${Platform.pathSeparator}$cacheKey.${ImageImportConstants.heicConvertedOutputExtension}';
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
      final Directory cacheDirectory = Directory(_cacheDirectoryPath);
      if (!await cacheDirectory.exists()) {
        return;
      }

      final DateTime now = DateTime.now();
      final DateTime cutoff = now.subtract(
        Duration(hours: ImageImportConstants.tempConvertedFileMaxAgeHours),
      );
      final List<FileSystemEntity> matchingFiles = await cacheDirectory
          .list(followLinks: false)
          .where(
            (FileSystemEntity entity) =>
                entity is File &&
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

    final bool preferFallbackFirst =
        ImageImportConstants.heicPreferFallbackConverterFirst;
    final bool conversionSucceeded = preferFallbackFirst
        ? await _tryFallbackThenPackage(
            sourcePath: sourcePath,
            outputPath: outputPath,
          )
        : await _tryPackageThenFallback(
            sourcePath: sourcePath,
            outputPath: outputPath,
          );
    if (!conversionSucceeded) {
      throw const ImageImportFailure(
        ImageImportConstants.heicConversionFailedMessage,
      );
    }

    if (!await outputFile.exists() || await outputFile.length() == 0) {
      throw const ImageImportFailure(
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
        format: _packageOutputFormat(),
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

  Future<bool> _tryPackageThenFallback({
    required String sourcePath,
    required String outputPath,
  }) async {
    final Stopwatch packageStopwatch = Stopwatch()..start();
    final bool packageSucceeded = await _tryPackageConvert(
      sourcePath: sourcePath,
      outputPath: outputPath,
    );
    packageStopwatch.stop();
    _logDebug(
      'package conversion success=$packageSucceeded duration=${packageStopwatch.elapsedMilliseconds}ms',
    );
    if (packageSucceeded) {
      return true;
    }

    final Stopwatch fallbackStopwatch = Stopwatch()..start();
    final bool fallbackSucceeded = await _tryFallbackConvert(
      sourcePath: sourcePath,
      outputPath: outputPath,
    );
    fallbackStopwatch.stop();
    _logDebug(
      'fallback conversion success=$fallbackSucceeded duration=${fallbackStopwatch.elapsedMilliseconds}ms',
    );
    return fallbackSucceeded;
  }

  Future<bool> _tryFallbackThenPackage({
    required String sourcePath,
    required String outputPath,
  }) async {
    final Stopwatch fallbackStopwatch = Stopwatch()..start();
    final bool fallbackSucceeded = await _tryFallbackConvert(
      sourcePath: sourcePath,
      outputPath: outputPath,
    );
    fallbackStopwatch.stop();
    _logDebug(
      'fallback conversion success=$fallbackSucceeded duration=${fallbackStopwatch.elapsedMilliseconds}ms',
    );
    if (fallbackSucceeded) {
      return true;
    }

    final Stopwatch packageStopwatch = Stopwatch()..start();
    final bool packageSucceeded = await _tryPackageConvert(
      sourcePath: sourcePath,
      outputPath: outputPath,
    );
    packageStopwatch.stop();
    _logDebug(
      'package conversion success=$packageSucceeded duration=${packageStopwatch.elapsedMilliseconds}ms',
    );
    return packageSucceeded;
  }

  Future<bool> _tryPackageConvert({
    required String sourcePath,
    required String outputPath,
  }) async {
    try {
      return await _heicFileConverter(
        sourcePath: sourcePath,
        outputPath: outputPath,
        maxPreviewDimension: ImageImportConstants.heicMaxPreviewDimension,
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> _tryFallbackConvert({
    required String sourcePath,
    required String outputPath,
  }) async {
    try {
      return await _externalHeicConverter(
        sourcePath: sourcePath,
        outputPath: outputPath,
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isUsableConvertedFile(String path) async {
    try {
      final File file = File(path);
      return await file.exists() && await file.length() > 0;
    } catch (_) {
      return false;
    }
  }

  bool _isHeicPreviewCachePath(String path) {
    final String normalizedPath = path.replaceAll('\\', '/').toLowerCase();
    final String normalizedCacheDir = _cacheDirectoryPath
        .replaceAll('\\', '/')
        .toLowerCase();
    return normalizedPath.startsWith('$normalizedCacheDir/');
  }

  static String _stableCacheKey(String input) {
    const int mask = 0xFFFFFFFF;
    int hash = 5381;
    for (final int value in input.codeUnits) {
      hash = ((hash << 5) + hash + value) & mask;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static ImageFormat _packageOutputFormat() {
    final String extension = ImageImportConstants.heicConvertedOutputExtension
        .toLowerCase();
    if (extension == 'jpg' || extension == 'jpeg') {
      return ImageFormat.jpg;
    }
    return ImageFormat.png;
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
