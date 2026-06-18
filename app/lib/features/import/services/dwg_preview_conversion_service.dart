import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';

class DwgPreviewConversionService {
  DwgPreviewConversionService({
    String? tempDirectoryPath,
  }) : _cacheDirectoryPath =
           '${tempDirectoryPath ?? Directory.systemTemp.path}${Platform.pathSeparator}${ImageImportConstants.dwgPreviewCacheFolderName}';

  final String _cacheDirectoryPath;

  Future<String> prepareDisplayablePreview({required String sourcePath}) async {
    await _cleanupStalePreviewFiles();
    final String cacheBasePath = await _buildCachedPreviewBasePath(sourcePath);
    final String? cachedPath = await _findCachedPreviewPath(cacheBasePath);
    if (cachedPath != null) {
      final DwgPreviewQualityResult cachedResult = await _evaluatePreviewFile(
        previewPath: cachedPath,
        sourcePath: sourcePath,
        previewSource: 'cache',
      );
      if (cachedResult.isUsable) {
        _logDebug(
          'cache hit path=$cachedPath '
          'format=${cachedResult.fileExtension} '
          'size=${cachedResult.width}x${cachedResult.height} '
          'sourcePath=$sourcePath',
        );
        return cachedPath;
      }
      await _deleteFileIfExists(cachedPath);
      _logDebug(
        'cache reject path=$cachedPath '
        'format=${cachedResult.fileExtension} '
        'size=${cachedResult.width}x${cachedResult.height} '
        'reason=${cachedResult.rejectionReason} '
        'sourcePath=$sourcePath',
      );
    }

    final Uint8List dwgBytes = await File(sourcePath).readAsBytes();
    final DwgEmbeddedPreview? preview = extractEmbeddedPreview(dwgBytes);
    if (preview == null) {
      _logDebug('no embedded preview found sourcePath=$sourcePath');
      throw const ImageImportFailure(
        ImageImportConstants.dwgPreviewUnavailableMessage,
      );
    }

    final String outputPath = '$cacheBasePath.${preview.fileExtension}';
    final DwgPreviewQualityResult qualityResult = await evaluatePreviewQuality(
      previewBytes: preview.bytes,
      fileExtension: preview.fileExtension,
    );
    _logDebug(
      'embedded preview found '
      'format=${preview.fileExtension} '
      'size=${qualityResult.width}x${qualityResult.height} '
      'bytes=${preview.bytes.length} '
      'candidatePath=$outputPath '
      'usable=${qualityResult.isUsable} '
      'reason=${qualityResult.rejectionReason ?? 'accepted'} '
      'sourcePath=$sourcePath',
    );
    if (!qualityResult.isUsable) {
      throw const ImageImportFailure(
        ImageImportConstants.dwgPreviewUnavailableMessage,
      );
    }

    final File outputFile = File(outputPath);
    await outputFile.parent.create(recursive: true);
    await outputFile.writeAsBytes(preview.bytes, flush: true);
    _logDebug(
      'cached usable embedded ${preview.fileExtension} preview '
      'bytes=${preview.bytes.length} path=$outputPath sourcePath=$sourcePath',
    );
    return outputPath;
  }

  bool isManagedPreviewPath(String path) {
    final String normalizedPath = path.replaceAll('\\', '/').toLowerCase();
    final String normalizedCacheDir = _cacheDirectoryPath
        .replaceAll('\\', '/')
        .toLowerCase();
    return normalizedPath.startsWith('$normalizedCacheDir/');
  }

  @visibleForTesting
  static DwgEmbeddedPreview? extractEmbeddedPreview(Uint8List dwgBytes) {
    final int searchLimit = math.min(
      dwgBytes.length,
      ImageImportConstants.dwgPreviewSearchByteLimit,
    );
    final Uint8List searchBytes = Uint8List.sublistView(dwgBytes, 0, searchLimit);

    final DwgEmbeddedPreview? pngPreview = _extractPngPreview(searchBytes);
    if (pngPreview != null) {
      return pngPreview;
    }

    final DwgEmbeddedPreview? bmpPreview = _extractBmpPreview(searchBytes);
    if (bmpPreview != null) {
      return bmpPreview;
    }

    return null;
  }

  @visibleForTesting
  static Future<DwgPreviewQualityResult> evaluatePreviewQuality({
    required Uint8List previewBytes,
    required String fileExtension,
  }) async {
    ui.Codec? codec;
    ui.Image? image;
    ByteData? rgbaBytes;
    try {
      codec = await ui.instantiateImageCodec(previewBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      image = frameInfo.image;
      final int width = image.width;
      final int height = image.height;
      if (width < ImageImportConstants.dwgPreviewMinimumWidth ||
          height < ImageImportConstants.dwgPreviewMinimumHeight) {
        return DwgPreviewQualityResult.rejected(
          fileExtension: fileExtension,
          width: width,
          height: height,
          rejectionReason: ImageImportConstants.dwgPreviewRejectedTooSmallReason,
        );
      }

      rgbaBytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (rgbaBytes == null) {
        return DwgPreviewQualityResult.rejected(
          fileExtension: fileExtension,
          width: width,
          height: height,
          rejectionReason: ImageImportConstants.dwgPreviewRejectedDecodeReason,
        );
      }

      final Uint8List rgba = rgbaBytes.buffer.asUint8List();
      int opaquePixelCount = 0;
      int darkPixelCount = 0;
      int visiblePixelCount = 0;
      int minX = width;
      int minY = height;
      int maxX = -1;
      int maxY = -1;

      for (int y = 0; y < height; y += 1) {
        for (int x = 0; x < width; x += 1) {
          final int pixelIndex = ((y * width) + x) * 4;
          final int red = rgba[pixelIndex];
          final int green = rgba[pixelIndex + 1];
          final int blue = rgba[pixelIndex + 2];
          final int alpha = rgba[pixelIndex + 3];
          if (alpha < ImageImportConstants.dwgPreviewOpaqueAlphaThreshold) {
            continue;
          }

          opaquePixelCount += 1;
          final int brightestChannel = math.max(red, math.max(green, blue));
          if (brightestChannel <= ImageImportConstants.dwgPreviewDarkPixelThreshold) {
            darkPixelCount += 1;
            continue;
          }

          visiblePixelCount += 1;
          if (x < minX) {
            minX = x;
          }
          if (x > maxX) {
            maxX = x;
          }
          if (y < minY) {
            minY = y;
          }
          if (y > maxY) {
            maxY = y;
          }
        }
      }

      if (visiblePixelCount == 0 || maxX < minX || maxY < minY) {
        return DwgPreviewQualityResult.rejected(
          fileExtension: fileExtension,
          width: width,
          height: height,
          rejectionReason: ImageImportConstants.dwgPreviewRejectedEmptyReason,
        );
      }

      final int boundsWidth = (maxX - minX) + 1;
      final int boundsHeight = (maxY - minY) + 1;
      final double totalPixelCount = (width * height).toDouble();
      final double darkPixelRatio = opaquePixelCount == 0
          ? 1
          : darkPixelCount / opaquePixelCount;
      final double contentBoundsAreaRatio =
          (boundsWidth * boundsHeight) / totalPixelCount;
      final double leftMarginRatio = minX / width;
      final double rightMarginRatio = (width - maxX - 1) / width;
      final double topMarginRatio = minY / height;
      final double bottomMarginRatio = (height - maxY - 1) / height;
      final double dominantMarginRatio = math.max(
        math.max(leftMarginRatio, rightMarginRatio),
        math.max(topMarginRatio, bottomMarginRatio),
      );

      if (darkPixelRatio >= ImageImportConstants.dwgPreviewMaximumDarkPixelRatio &&
          contentBoundsAreaRatio <=
              ImageImportConstants.dwgPreviewMaximumDarkAreaRatio) {
        return DwgPreviewQualityResult.rejected(
          fileExtension: fileExtension,
          width: width,
          height: height,
          darkPixelRatio: darkPixelRatio,
          contentBoundsAreaRatio: contentBoundsAreaRatio,
          dominantMarginRatio: dominantMarginRatio,
          rejectionReason:
              ImageImportConstants.dwgPreviewRejectedMostlyDarkReason,
        );
      }

      if (darkPixelRatio >= ImageImportConstants.dwgPreviewMaximumDarkPixelRatio &&
          dominantMarginRatio >=
              ImageImportConstants.dwgPreviewMaximumDominantMarginRatio) {
        return DwgPreviewQualityResult.rejected(
          fileExtension: fileExtension,
          width: width,
          height: height,
          darkPixelRatio: darkPixelRatio,
          contentBoundsAreaRatio: contentBoundsAreaRatio,
          dominantMarginRatio: dominantMarginRatio,
          rejectionReason: ImageImportConstants.dwgPreviewRejectedMarginReason,
        );
      }

      return DwgPreviewQualityResult.accepted(
        fileExtension: fileExtension,
        width: width,
        height: height,
        darkPixelRatio: darkPixelRatio,
        contentBoundsAreaRatio: contentBoundsAreaRatio,
        dominantMarginRatio: dominantMarginRatio,
      );
    } catch (_) {
      return DwgPreviewQualityResult.rejected(
        fileExtension: fileExtension,
        width: 0,
        height: 0,
        rejectionReason: ImageImportConstants.dwgPreviewRejectedDecodeReason,
      );
    } finally {
      image?.dispose();
      codec?.dispose();
    }
  }

  static DwgEmbeddedPreview? _extractPngPreview(Uint8List bytes) {
    const List<int> pngSignature = <int>[
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
    ];
    const List<int> pngEndMarker = <int>[
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ];

    final int start = _indexOfPattern(bytes, pngSignature);
    if (start < 0) {
      return null;
    }

    final int end = _indexOfPattern(bytes, pngEndMarker, start);
    if (end < 0) {
      return null;
    }

    return DwgEmbeddedPreview(
      bytes: Uint8List.fromList(bytes.sublist(start, end + pngEndMarker.length)),
      fileExtension: 'png',
    );
  }

  static DwgEmbeddedPreview? _extractBmpPreview(Uint8List bytes) {
    const List<int> bmpSignature = <int>[0x42, 0x4D];
    final int start = _indexOfPattern(bytes, bmpSignature);
    if (start < 0 || start + 6 >= bytes.length) {
      return null;
    }

    final ByteData byteData = ByteData.sublistView(bytes);
    final int fileSize = byteData.getUint32(start + 2, Endian.little);
    if (fileSize <= 14 || start + fileSize > bytes.length) {
      return null;
    }

    return DwgEmbeddedPreview(
      bytes: Uint8List.fromList(bytes.sublist(start, start + fileSize)),
      fileExtension: 'bmp',
    );
  }

  static int _indexOfPattern(
    Uint8List data,
    List<int> pattern, [
    int startIndex = 0,
  ]) {
    if (pattern.isEmpty || data.length < pattern.length) {
      return -1;
    }
    for (int i = startIndex; i <= data.length - pattern.length; i += 1) {
      bool matches = true;
      for (int j = 0; j < pattern.length; j += 1) {
        if (data[i + j] != pattern[j]) {
          matches = false;
          break;
        }
      }
      if (matches) {
        return i;
      }
    }
    return -1;
  }

  Future<String> _buildCachedPreviewBasePath(String sourcePath) async {
    final File sourceFile = File(sourcePath);
    final FileStat sourceStat = await sourceFile.stat();
    final String signature =
        '${ImageImportConstants.dwgPreviewCacheKeyVersion}|'
        '${sourceFile.absolute.path.toLowerCase()}|'
        '${sourceStat.size}|'
        '${sourceStat.modified.millisecondsSinceEpoch}|'
        '${ImageImportConstants.dwgPreviewSearchByteLimit}|'
        '${ImageImportConstants.dwgPreviewMinimumWidth}|'
        '${ImageImportConstants.dwgPreviewMinimumHeight}|'
        '${ImageImportConstants.dwgPreviewMaximumDarkPixelRatio}|'
        '${ImageImportConstants.dwgPreviewMaximumDarkAreaRatio}|'
        '${ImageImportConstants.dwgPreviewMaximumDominantMarginRatio}';
    final String cacheKey = _stableCacheKey(signature);
    return '$_cacheDirectoryPath${Platform.pathSeparator}$cacheKey';
  }

  Future<String?> _findCachedPreviewPath(String cacheBasePath) async {
    for (final String extension in ImageImportConstants.dwgPreviewCacheExtensions) {
      final String candidate = '$cacheBasePath.$extension';
      final File file = File(candidate);
      if (await file.exists() && await file.length() > 0) {
        return candidate;
      }
    }
    return null;
  }

  Future<void> _cleanupStalePreviewFiles() async {
    try {
      final Directory cacheDirectory = Directory(_cacheDirectoryPath);
      if (!await cacheDirectory.exists()) {
        return;
      }

      final DateTime cutoff = DateTime.now().subtract(
        Duration(hours: ImageImportConstants.tempConvertedFileMaxAgeHours),
      );
      final List<FileSystemEntity> entries = await cacheDirectory
          .list(followLinks: false)
          .toList();
      final List<_TempFileMeta> metadata = <_TempFileMeta>[];

      for (final File file in entries.whereType<File>()) {
        final String extension = file.path.split('.').last.toLowerCase();
        if (!ImageImportConstants.dwgPreviewCacheExtensions.contains(extension)) {
          continue;
        }
        final FileStat stat = await file.stat();
        metadata.add(_TempFileMeta(file: file, modified: stat.modified));
      }

      for (final _TempFileMeta item in metadata) {
        if (item.modified.isBefore(cutoff) && await item.file.exists()) {
          await item.file.delete();
        }
      }

      if (metadata.length <= ImageImportConstants.tempConvertedFileMaxCount) {
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

  static String _stableCacheKey(String input) {
    const int mask = 0xFFFFFFFF;
    int hash = 5381;
    for (final int value in input.codeUnits) {
      hash = ((hash << 5) + hash + value) & mask;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  void _logDebug(String message) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('${ImageImportConstants.importDiagnosticsPrefix} [DWG] $message');
  }

  Future<DwgPreviewQualityResult> _evaluatePreviewFile({
    required String previewPath,
    required String sourcePath,
    required String previewSource,
  }) async {
    try {
      final File file = File(previewPath);
      final Uint8List previewBytes = await file.readAsBytes();
      final String fileExtension = previewPath.split('.').last.toLowerCase();
      final DwgPreviewQualityResult result = await evaluatePreviewQuality(
        previewBytes: previewBytes,
        fileExtension: fileExtension,
      );
      _logDebug(
        '$previewSource preview check '
        'format=$fileExtension '
        'size=${result.width}x${result.height} '
        'path=$previewPath '
        'usable=${result.isUsable} '
        'reason=${result.rejectionReason ?? 'accepted'} '
        'sourcePath=$sourcePath',
      );
      return result;
    } catch (_) {
      return DwgPreviewQualityResult.rejected(
        fileExtension: previewPath.split('.').last.toLowerCase(),
        width: 0,
        height: 0,
        rejectionReason: ImageImportConstants.dwgPreviewRejectedDecodeReason,
      );
    }
  }

  Future<void> _deleteFileIfExists(String path) async {
    final File file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

class DwgEmbeddedPreview {
  const DwgEmbeddedPreview({
    required this.bytes,
    required this.fileExtension,
  });

  final Uint8List bytes;
  final String fileExtension;
}

class DwgPreviewQualityResult {
  const DwgPreviewQualityResult._({
    required this.isUsable,
    required this.fileExtension,
    required this.width,
    required this.height,
    required this.darkPixelRatio,
    required this.contentBoundsAreaRatio,
    required this.dominantMarginRatio,
    this.rejectionReason,
  });

  const DwgPreviewQualityResult.accepted({
    required String fileExtension,
    required int width,
    required int height,
    required double darkPixelRatio,
    required double contentBoundsAreaRatio,
    required double dominantMarginRatio,
  }) : this._(
         isUsable: true,
         fileExtension: fileExtension,
         width: width,
         height: height,
         darkPixelRatio: darkPixelRatio,
         contentBoundsAreaRatio: contentBoundsAreaRatio,
         dominantMarginRatio: dominantMarginRatio,
       );

  const DwgPreviewQualityResult.rejected({
    required String fileExtension,
    required int width,
    required int height,
    required String rejectionReason,
    double darkPixelRatio = 0,
    double contentBoundsAreaRatio = 0,
    double dominantMarginRatio = 0,
  }) : this._(
         isUsable: false,
         fileExtension: fileExtension,
         width: width,
         height: height,
         darkPixelRatio: darkPixelRatio,
         contentBoundsAreaRatio: contentBoundsAreaRatio,
         dominantMarginRatio: dominantMarginRatio,
         rejectionReason: rejectionReason,
       );

  final bool isUsable;
  final String fileExtension;
  final int width;
  final int height;
  final double darkPixelRatio;
  final double contentBoundsAreaRatio;
  final double dominantMarginRatio;
  final String? rejectionReason;
}

class ImageImportFailure implements Exception {
  const ImageImportFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class _TempFileMeta {
  const _TempFileMeta({
    required this.file,
    required this.modified,
  });

  final File file;
  final DateTime modified;
}
