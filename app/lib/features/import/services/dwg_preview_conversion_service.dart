import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';

typedef DwgEnvironmentLookup = String? Function(String key);
typedef DwgOfflineConverterRunner =
    Future<DwgOfflineConverterRunResult> Function({
      required DwgOfflineConverterInvocation invocation,
    });

class DwgPreviewConversionService {
  DwgPreviewConversionService({
    String? tempDirectoryPath,
    DwgEnvironmentLookup? environmentLookup,
    DwgOfflineConverterRunner? offlineConverterRunner,
  }) : _cacheDirectoryPath =
           '${tempDirectoryPath ?? Directory.systemTemp.path}${Platform.pathSeparator}${ImageImportConstants.dwgPreviewCacheFolderName}',
       _environmentLookup = environmentLookup ?? _defaultEnvironmentLookup,
       _offlineConverterRunner =
           offlineConverterRunner ?? _defaultOfflineConverterRunner;

  final String _cacheDirectoryPath;
  final DwgEnvironmentLookup _environmentLookup;
  final DwgOfflineConverterRunner _offlineConverterRunner;

  Future<String> prepareDisplayablePreview({required String sourcePath}) async {
    await _cleanupStalePreviewFiles();

    final DwgOfflineConverterConfig? converterConfig =
        _resolveOfflineConverterConfig();
    final String embeddedCacheBasePath = await _buildEmbeddedCacheBasePath(
      sourcePath,
    );

    if (converterConfig != null) {
      final String converterCacheBasePath =
          await _buildOfflineConverterCacheBasePath(
            sourcePath,
            converterConfig,
          );
      final String? cachedConverterPath = await _findUsableCachedPreviewPath(
        cacheBasePath: converterCacheBasePath,
        sourcePath: sourcePath,
        previewSource: 'offline-converter-cache',
      );
      if (cachedConverterPath != null) {
        return cachedConverterPath;
      }

      final String? convertedPreviewPath = await _tryOfflineConverterPreview(
        sourcePath: sourcePath,
        cacheBasePath: converterCacheBasePath,
        converterConfig: converterConfig,
      );
      if (convertedPreviewPath != null) {
        return convertedPreviewPath;
      }
    } else {
      _logDebug(
        'offline converter unavailable '
        'reason=${ImageImportConstants.dwgOfflineConverterMissingReason} '
        'sourcePath=$sourcePath',
      );
    }

    final String? cachedEmbeddedPath = await _findUsableCachedPreviewPath(
      cacheBasePath: embeddedCacheBasePath,
      sourcePath: sourcePath,
      previewSource: 'embedded-cache',
    );
    if (cachedEmbeddedPath != null) {
      return cachedEmbeddedPath;
    }

    return _extractEmbeddedPreviewToCache(
      sourcePath: sourcePath,
      cacheBasePath: embeddedCacheBasePath,
    );
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
    final Uint8List searchBytes = Uint8List.sublistView(
      dwgBytes,
      0,
      searchLimit,
    );

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
          rejectionReason:
              ImageImportConstants.dwgPreviewRejectedTooSmallReason,
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
          if (brightestChannel <=
              ImageImportConstants.dwgPreviewDarkPixelThreshold) {
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

      if (darkPixelRatio >=
              ImageImportConstants.dwgPreviewMaximumDarkPixelRatio &&
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

      if (darkPixelRatio >=
              ImageImportConstants.dwgPreviewMaximumDarkPixelRatio &&
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
      bytes: Uint8List.fromList(
        bytes.sublist(start, end + pngEndMarker.length),
      ),
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

  DwgOfflineConverterConfig? _resolveOfflineConverterConfig() {
    final String? configuredCommand = _readTrimmedEnvironmentValue(
      ImageImportConstants.dwgOfflineConverterCommandEnvVar,
    );
    if (configuredCommand == null) {
      return null;
    }

    final String strategyName =
        _readTrimmedEnvironmentValue(
          ImageImportConstants.dwgOfflineConverterStrategyNameEnvVar,
        ) ??
        ImageImportConstants.dwgOfflineConverterDefaultStrategyName;
    final String outputExtension = _resolveOfflineConverterOutputExtension();
    final Duration timeout = _resolveOfflineConverterTimeout();
    final String cacheSignature = <String>[
      strategyName,
      configuredCommand.toLowerCase(),
      outputExtension,
      timeout.inSeconds.toString(),
    ].join('|');

    return DwgOfflineConverterConfig(
      configuredCommand: configuredCommand,
      strategyName: strategyName,
      outputExtension: outputExtension,
      timeout: timeout,
      cacheSignature: cacheSignature,
    );
  }

  Future<String> _extractEmbeddedPreviewToCache({
    required String sourcePath,
    required String cacheBasePath,
  }) async {
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

  Future<String?> _tryOfflineConverterPreview({
    required String sourcePath,
    required String cacheBasePath,
    required DwgOfflineConverterConfig converterConfig,
  }) async {
    final String outputPath =
        '$cacheBasePath.${converterConfig.outputExtension}';
    await File(outputPath).parent.create(recursive: true);
    await _deleteFileIfExists(outputPath);

    final DwgOfflineConverterInvocation invocation =
        _buildOfflineConverterInvocation(
          sourcePath: sourcePath,
          outputPath: outputPath,
          converterConfig: converterConfig,
        );
    _logDebug(
      'offline converter try '
      'strategy=${converterConfig.strategyName} '
      'command=${invocation.diagnosticCommandLine} '
      'outputPath=$outputPath sourcePath=$sourcePath',
    );

    final DwgOfflineConverterRunResult result = await _offlineConverterRunner(
      invocation: invocation,
    );
    if (!result.wasSuccessful) {
      await _deleteFileIfExists(outputPath);
      _logDebug(
        'offline converter reject '
        'strategy=${converterConfig.strategyName} '
        'reason=${result.failureReason ?? ImageImportConstants.dwgOfflineConverterLaunchFailedReason} '
        'exitCode=${result.exitCode?.toString() ?? 'n/a'} '
        'stdout=${_truncateLogValue(result.stdout)} '
        'stderr=${_truncateLogValue(result.stderr)} '
        'sourcePath=$sourcePath',
      );
      return null;
    }

    final File outputFile = File(outputPath);
    if (!await outputFile.exists() || await outputFile.length() == 0) {
      await _deleteFileIfExists(outputPath);
      _logDebug(
        'offline converter reject '
        'strategy=${converterConfig.strategyName} '
        'reason=${ImageImportConstants.dwgOfflineConverterOutputMissingReason} '
        'sourcePath=$sourcePath',
      );
      return null;
    }

    final DwgPreviewQualityResult qualityResult = await _evaluatePreviewFile(
      previewPath: outputPath,
      sourcePath: sourcePath,
      previewSource: 'offline-converter',
    );
    if (!qualityResult.isUsable) {
      await _deleteFileIfExists(outputPath);
      _logDebug(
        'offline converter reject '
        'strategy=${converterConfig.strategyName} '
        'reason=${ImageImportConstants.dwgOfflineConverterOutputRejectedReason} '
        'qualityReason=${qualityResult.rejectionReason ?? 'unknown'} '
        'sourcePath=$sourcePath',
      );
      return null;
    }

    _logDebug(
      'offline converter accepted '
      'strategy=${converterConfig.strategyName} '
      'path=$outputPath '
      'format=${qualityResult.fileExtension} '
      'size=${qualityResult.width}x${qualityResult.height} '
      'sourcePath=$sourcePath',
    );
    return outputPath;
  }

  Future<String?> _findUsableCachedPreviewPath({
    required String cacheBasePath,
    required String sourcePath,
    required String previewSource,
  }) async {
    final String? cachedPath = await _findCachedPreviewPath(cacheBasePath);
    if (cachedPath == null) {
      return null;
    }

    final DwgPreviewQualityResult cachedResult = await _evaluatePreviewFile(
      previewPath: cachedPath,
      sourcePath: sourcePath,
      previewSource: previewSource,
    );
    if (cachedResult.isUsable) {
      _logDebug(
        '$previewSource hit path=$cachedPath '
        'format=${cachedResult.fileExtension} '
        'size=${cachedResult.width}x${cachedResult.height} '
        'sourcePath=$sourcePath',
      );
      return cachedPath;
    }

    await _deleteFileIfExists(cachedPath);
    _logDebug(
      '$previewSource reject path=$cachedPath '
      'format=${cachedResult.fileExtension} '
      'size=${cachedResult.width}x${cachedResult.height} '
      'reason=${cachedResult.rejectionReason} '
      'sourcePath=$sourcePath',
    );
    return null;
  }

  Future<String> _buildEmbeddedCacheBasePath(String sourcePath) {
    return _buildCacheBasePath(
      sourcePath: sourcePath,
      variantSignature: 'embedded-preview',
    );
  }

  Future<String> _buildOfflineConverterCacheBasePath(
    String sourcePath,
    DwgOfflineConverterConfig converterConfig,
  ) {
    return _buildCacheBasePath(
      sourcePath: sourcePath,
      variantSignature: converterConfig.cacheSignature,
    );
  }

  Future<String> _buildCacheBasePath({
    required String sourcePath,
    required String variantSignature,
  }) async {
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
        '${ImageImportConstants.dwgPreviewMaximumDominantMarginRatio}|'
        '$variantSignature';
    final String cacheKey = _stableCacheKey(signature);
    return '$_cacheDirectoryPath${Platform.pathSeparator}$cacheKey';
  }

  Future<String?> _findCachedPreviewPath(String cacheBasePath) async {
    for (final String extension
        in ImageImportConstants.dwgPreviewCacheExtensions) {
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
        if (!ImageImportConstants.dwgPreviewCacheExtensions.contains(
          extension,
        )) {
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
    debugPrint(
      '${ImageImportConstants.importDiagnosticsPrefix} [DWG] $message',
    );
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

  String? _readTrimmedEnvironmentValue(String key) {
    final String? value = _environmentLookup(key)?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  String _resolveOfflineConverterOutputExtension() {
    final String? configuredExtension = _readTrimmedEnvironmentValue(
      ImageImportConstants.dwgOfflineConverterOutputExtensionEnvVar,
    );
    final String normalizedExtension =
        configuredExtension?.toLowerCase() ??
        ImageImportConstants.dwgOfflineConverterDefaultOutputExtension;
    if (ImageImportConstants.dwgOfflineConverterAllowedOutputExtensions
        .contains(normalizedExtension)) {
      return normalizedExtension;
    }

    _logDebug(
      'offline converter output extension fallback '
      'configured=$configuredExtension '
      'fallback=${ImageImportConstants.dwgOfflineConverterDefaultOutputExtension}',
    );
    return ImageImportConstants.dwgOfflineConverterDefaultOutputExtension;
  }

  Duration _resolveOfflineConverterTimeout() {
    final String? rawValue = _readTrimmedEnvironmentValue(
      ImageImportConstants.dwgOfflineConverterTimeoutSecondsEnvVar,
    );
    final int? seconds = rawValue == null ? null : int.tryParse(rawValue);
    if (seconds == null || seconds <= 0) {
      return ImageImportConstants.dwgOfflineConverterTimeout;
    }
    return Duration(seconds: seconds);
  }

  DwgOfflineConverterInvocation _buildOfflineConverterInvocation({
    required String sourcePath,
    required String outputPath,
    required DwgOfflineConverterConfig converterConfig,
  }) {
    final String normalizedCommand = converterConfig.configuredCommand
        .toLowerCase();
    if (normalizedCommand.endsWith('.ps1')) {
      return DwgOfflineConverterInvocation(
        executable: 'powershell.exe',
        arguments: <String>[
          '-ExecutionPolicy',
          'Bypass',
          '-File',
          converterConfig.configuredCommand,
          sourcePath,
          outputPath,
        ],
        sourcePath: sourcePath,
        outputPath: outputPath,
        strategyName: converterConfig.strategyName,
        timeout: converterConfig.timeout,
        configuredCommand: converterConfig.configuredCommand,
        outputExtension: converterConfig.outputExtension,
      );
    }
    if (normalizedCommand.endsWith('.cmd') ||
        normalizedCommand.endsWith('.bat')) {
      return DwgOfflineConverterInvocation(
        executable: 'cmd.exe',
        arguments: <String>[
          '/c',
          converterConfig.configuredCommand,
          sourcePath,
          outputPath,
        ],
        sourcePath: sourcePath,
        outputPath: outputPath,
        strategyName: converterConfig.strategyName,
        timeout: converterConfig.timeout,
        configuredCommand: converterConfig.configuredCommand,
        outputExtension: converterConfig.outputExtension,
      );
    }
    return DwgOfflineConverterInvocation(
      executable: converterConfig.configuredCommand,
      arguments: <String>[sourcePath, outputPath],
      sourcePath: sourcePath,
      outputPath: outputPath,
      strategyName: converterConfig.strategyName,
      timeout: converterConfig.timeout,
      configuredCommand: converterConfig.configuredCommand,
      outputExtension: converterConfig.outputExtension,
    );
  }

  static String? _defaultEnvironmentLookup(String key) =>
      Platform.environment[key];

  static Future<DwgOfflineConverterRunResult> _defaultOfflineConverterRunner({
    required DwgOfflineConverterInvocation invocation,
  }) async {
    Process? process;
    try {
      process = await Process.start(
        invocation.executable,
        invocation.arguments,
      );
    } catch (_) {
      return const DwgOfflineConverterRunResult.failed(
        failureReason:
            ImageImportConstants.dwgOfflineConverterLaunchFailedReason,
        didStart: false,
      );
    }

    final StringBuffer stdoutBuffer = StringBuffer();
    final StringBuffer stderrBuffer = StringBuffer();
    final Future<void> stdoutFuture = process.stdout
        .transform(utf8.decoder)
        .forEach(stdoutBuffer.write);
    final Future<void> stderrFuture = process.stderr
        .transform(utf8.decoder)
        .forEach(stderrBuffer.write);

    try {
      final int exitCode = await process.exitCode.timeout(invocation.timeout);
      await _drainProcessStreams(stdoutFuture, stderrFuture);
      if (exitCode != 0) {
        return DwgOfflineConverterRunResult.failed(
          failureReason: ImageImportConstants.dwgOfflineConverterExitCodeReason,
          exitCode: exitCode,
          stdout: stdoutBuffer.toString(),
          stderr: stderrBuffer.toString(),
        );
      }
      return DwgOfflineConverterRunResult.success(
        exitCode: exitCode,
        stdout: stdoutBuffer.toString(),
        stderr: stderrBuffer.toString(),
      );
    } on TimeoutException {
      process.kill();
      await _drainProcessStreams(stdoutFuture, stderrFuture);
      return DwgOfflineConverterRunResult.failed(
        failureReason: ImageImportConstants.dwgOfflineConverterTimeoutReason,
        stdout: stdoutBuffer.toString(),
        stderr: stderrBuffer.toString(),
      );
    }
  }

  static Future<void> _drainProcessStreams(
    Future<void> stdoutFuture,
    Future<void> stderrFuture,
  ) async {
    try {
      await Future.wait<void>(<Future<void>>[
        stdoutFuture,
        stderrFuture,
      ]).timeout(const Duration(seconds: 1));
    } catch (_) {
      // Best-effort diagnostic stream drain only.
    }
  }

  static String _truncateLogValue(String value) {
    final String normalized = value
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .trim();
    if (normalized.isEmpty) {
      return '<empty>';
    }
    if (normalized.length <= 160) {
      return normalized;
    }
    return '${normalized.substring(0, 157)}...';
  }
}

class DwgEmbeddedPreview {
  const DwgEmbeddedPreview({required this.bytes, required this.fileExtension});

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

class DwgOfflineConverterConfig {
  const DwgOfflineConverterConfig({
    required this.configuredCommand,
    required this.strategyName,
    required this.outputExtension,
    required this.timeout,
    required this.cacheSignature,
  });

  final String configuredCommand;
  final String strategyName;
  final String outputExtension;
  final Duration timeout;
  final String cacheSignature;
}

class DwgOfflineConverterInvocation {
  const DwgOfflineConverterInvocation({
    required this.executable,
    required this.arguments,
    required this.sourcePath,
    required this.outputPath,
    required this.strategyName,
    required this.timeout,
    required this.configuredCommand,
    required this.outputExtension,
  });

  final String executable;
  final List<String> arguments;
  final String sourcePath;
  final String outputPath;
  final String strategyName;
  final Duration timeout;
  final String configuredCommand;
  final String outputExtension;

  String get diagnosticCommandLine =>
      <String>[executable, ...arguments].map(_quoteCommandArg).join(' ');
}

class DwgOfflineConverterRunResult {
  const DwgOfflineConverterRunResult.success({
    required this.exitCode,
    this.stdout = '',
    this.stderr = '',
  }) : didStart = true,
       failureReason = null;

  const DwgOfflineConverterRunResult.failed({
    required this.failureReason,
    this.didStart = true,
    this.exitCode,
    this.stdout = '',
    this.stderr = '',
  });

  final bool didStart;
  final int? exitCode;
  final String stdout;
  final String stderr;
  final String? failureReason;

  bool get wasSuccessful => didStart && failureReason == null && exitCode == 0;
}

class ImageImportFailure implements Exception {
  const ImageImportFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class _TempFileMeta {
  const _TempFileMeta({required this.file, required this.modified});

  final File file;
  final DateTime modified;
}

String _quoteCommandArg(String value) {
  if (value.isEmpty) {
    return '""';
  }
  if (!value.contains(' ') && !value.contains('"')) {
    return value;
  }
  return '"${value.replaceAll('"', '\\"')}"';
}
