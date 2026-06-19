import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/import/services/dwg_preview_conversion_service.dart';

void main() {
  group('DwgPreviewConversionService', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'ncd_photo_markup_dwg_preview_test_',
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('extracts usable embedded png preview and caches it', () async {
      final File dwgFile = File('${tempDir.path}/drawing1.dwg');
      await dwgFile.writeAsBytes(
        _buildFakeDwgWithPngPreview(_buildUsablePngPreviewBytes()),
      );

      final DwgPreviewConversionService service = DwgPreviewConversionService(
        tempDirectoryPath: tempDir.path,
      );

      final String firstPath = await service.prepareDisplayablePreview(
        sourcePath: dwgFile.path,
      );
      final String secondPath = await service.prepareDisplayablePreview(
        sourcePath: dwgFile.path,
      );

      expect(firstPath, secondPath);
      expect(
        firstPath.contains(ImageImportConstants.dwgPreviewCacheFolderName),
        isTrue,
      );
      expect(firstPath.endsWith('.png'), isTrue);
      expect(await File(firstPath).exists(), isTrue);
      expect(service.isManagedPreviewPath(firstPath), isTrue);
    });

    test('prefers configured offline converter output when usable', () async {
      final File dwgFile = File('${tempDir.path}/converter_source.dwg');
      await dwgFile.writeAsBytes(<int>[1, 2, 3, 4, 5]);

      final DwgPreviewConversionService service = DwgPreviewConversionService(
        tempDirectoryPath: tempDir.path,
        environmentLookup: _environmentFromMap(<String, String>{
          ImageImportConstants.dwgOfflineConverterCommandEnvVar:
              r'C:\tools\dwg_converter.cmd',
          ImageImportConstants.dwgOfflineConverterStrategyNameEnvVar:
              'test-converter',
          ImageImportConstants.dwgOfflineConverterOutputExtensionEnvVar: 'png',
        }),
        offlineConverterRunner:
            ({required DwgOfflineConverterInvocation invocation}) async {
              await File(
                invocation.outputPath,
              ).writeAsBytes(_buildUsablePngPreviewBytes(), flush: true);
              return const DwgOfflineConverterRunResult.success(exitCode: 0);
            },
      );

      final String previewPath = await service.prepareDisplayablePreview(
        sourcePath: dwgFile.path,
      );

      expect(previewPath.endsWith('.png'), isTrue);
      expect(await File(previewPath).exists(), isTrue);
      expect(await File(previewPath).length(), greaterThan(0));
    });

    test('falls back to embedded preview when converter fails', () async {
      final Uint8List embeddedPreviewBytes = _buildUsablePngPreviewBytes();
      final File dwgFile = File('${tempDir.path}/drawing1.dwg');
      await dwgFile.writeAsBytes(
        _buildFakeDwgWithPngPreview(embeddedPreviewBytes),
      );

      final DwgPreviewConversionService service = DwgPreviewConversionService(
        tempDirectoryPath: tempDir.path,
        environmentLookup: _environmentFromMap(<String, String>{
          ImageImportConstants.dwgOfflineConverterCommandEnvVar:
              r'C:\tools\dwg_converter.cmd',
        }),
        offlineConverterRunner:
            ({required DwgOfflineConverterInvocation invocation}) async {
              return const DwgOfflineConverterRunResult.failed(
                failureReason:
                    ImageImportConstants.dwgOfflineConverterExitCodeReason,
                exitCode: 1,
              );
            },
      );

      final String previewPath = await service.prepareDisplayablePreview(
        sourcePath: dwgFile.path,
      );

      expect(previewPath.endsWith('.png'), isTrue);
      expect(await File(previewPath).readAsBytes(), embeddedPreviewBytes);
    });

    test('rejects low-quality embedded preview thumbnails', () async {
      final File dwgFile = File('${tempDir.path}/drawing1.dwg');
      await dwgFile.writeAsBytes(
        _buildFakeDwgWithPngPreview(_buildLowQualityPngPreviewBytes()),
      );

      final DwgPreviewConversionService service = DwgPreviewConversionService(
        tempDirectoryPath: tempDir.path,
      );

      expect(
        () => service.prepareDisplayablePreview(sourcePath: dwgFile.path),
        throwsA(
          isA<ImageImportFailure>().having(
            (ImageImportFailure error) => error.message,
            'message',
            ImageImportConstants.dwgPreviewUnavailableMessage,
          ),
        ),
      );
    });

    test('rejects mostly-dark large previews with tiny drawing area', () async {
      final DwgPreviewQualityResult result =
          await DwgPreviewConversionService.evaluatePreviewQuality(
            previewBytes: _buildDarkBackgroundBmpPreviewBytes(),
            fileExtension: 'bmp',
          );

      expect(result.isUsable, isFalse);
      expect(
        result.rejectionReason,
        anyOf(
          ImageImportConstants.dwgPreviewRejectedMostlyDarkReason,
          ImageImportConstants.dwgPreviewRejectedMarginReason,
        ),
      );
    });

    test(
      'reports friendly error when configured converter times out',
      () async {
        final File dwgFile = File('${tempDir.path}/drawing1.dwg');
        await dwgFile.writeAsBytes(<int>[1, 2, 3, 4, 5, 6]);

        final DwgPreviewConversionService service = DwgPreviewConversionService(
          tempDirectoryPath: tempDir.path,
          environmentLookup: _environmentFromMap(<String, String>{
            ImageImportConstants.dwgOfflineConverterCommandEnvVar:
                r'C:\tools\dwg_converter.cmd',
          }),
          offlineConverterRunner:
              ({required DwgOfflineConverterInvocation invocation}) async {
                return const DwgOfflineConverterRunResult.failed(
                  failureReason:
                      ImageImportConstants.dwgOfflineConverterTimeoutReason,
                );
              },
        );

        expect(
          () => service.prepareDisplayablePreview(sourcePath: dwgFile.path),
          throwsA(
            isA<ImageImportFailure>().having(
              (ImageImportFailure error) => error.message,
              'message',
              ImageImportConstants.dwgPreviewUnavailableMessage,
            ),
          ),
        );
      },
    );

    test('reports friendly error when converter output is missing', () async {
      final File dwgFile = File('${tempDir.path}/drawing1.dwg');
      await dwgFile.writeAsBytes(<int>[1, 2, 3, 4, 5, 6]);

      final DwgPreviewConversionService service = DwgPreviewConversionService(
        tempDirectoryPath: tempDir.path,
        environmentLookup: _environmentFromMap(<String, String>{
          ImageImportConstants.dwgOfflineConverterCommandEnvVar:
              r'C:\tools\dwg_converter.cmd',
        }),
        offlineConverterRunner:
            ({required DwgOfflineConverterInvocation invocation}) async {
              return const DwgOfflineConverterRunResult.success(exitCode: 0);
            },
      );

      expect(
        () => service.prepareDisplayablePreview(sourcePath: dwgFile.path),
        throwsA(
          isA<ImageImportFailure>().having(
            (ImageImportFailure error) => error.message,
            'message',
            ImageImportConstants.dwgPreviewUnavailableMessage,
          ),
        ),
      );
    });

    test('rejects low-quality converter output', () async {
      final File dwgFile = File('${tempDir.path}/drawing1.dwg');
      await dwgFile.writeAsBytes(<int>[1, 2, 3, 4, 5, 6]);

      final DwgPreviewConversionService service = DwgPreviewConversionService(
        tempDirectoryPath: tempDir.path,
        environmentLookup: _environmentFromMap(<String, String>{
          ImageImportConstants.dwgOfflineConverterCommandEnvVar:
              r'C:\tools\dwg_converter.cmd',
        }),
        offlineConverterRunner:
            ({required DwgOfflineConverterInvocation invocation}) async {
              await File(
                invocation.outputPath,
              ).writeAsBytes(_buildLowQualityPngPreviewBytes(), flush: true);
              return const DwgOfflineConverterRunResult.success(exitCode: 0);
            },
      );

      expect(
        () => service.prepareDisplayablePreview(sourcePath: dwgFile.path),
        throwsA(
          isA<ImageImportFailure>().having(
            (ImageImportFailure error) => error.message,
            'message',
            ImageImportConstants.dwgPreviewUnavailableMessage,
          ),
        ),
      );
    });

    test(
      'changes converter cache key when converter settings change',
      () async {
        final File dwgFile = File('${tempDir.path}/cache_key_source.dwg');
        await dwgFile.writeAsBytes(<int>[1, 2, 3, 4, 5]);

        Future<DwgOfflineConverterRunResult> runner({
          required DwgOfflineConverterInvocation invocation,
        }) async {
          await File(
            invocation.outputPath,
          ).writeAsBytes(_buildUsablePngPreviewBytes(), flush: true);
          return const DwgOfflineConverterRunResult.success(exitCode: 0);
        }

        final DwgPreviewConversionService firstService =
            DwgPreviewConversionService(
              tempDirectoryPath: tempDir.path,
              environmentLookup: _environmentFromMap(<String, String>{
                ImageImportConstants.dwgOfflineConverterCommandEnvVar:
                    r'C:\tools\dwg_converter_a.cmd',
                ImageImportConstants.dwgOfflineConverterStrategyNameEnvVar:
                    'strategy-a',
              }),
              offlineConverterRunner: runner,
            );
        final DwgPreviewConversionService secondService =
            DwgPreviewConversionService(
              tempDirectoryPath: tempDir.path,
              environmentLookup: _environmentFromMap(<String, String>{
                ImageImportConstants.dwgOfflineConverterCommandEnvVar:
                    r'C:\tools\dwg_converter_b.cmd',
                ImageImportConstants.dwgOfflineConverterStrategyNameEnvVar:
                    'strategy-b',
              }),
              offlineConverterRunner: runner,
            );

        final String firstPath = await firstService.prepareDisplayablePreview(
          sourcePath: dwgFile.path,
        );
        final String secondPath = await secondService.prepareDisplayablePreview(
          sourcePath: dwgFile.path,
        );

        expect(firstPath, isNot(secondPath));
      },
    );

    test('reports friendly error when dwg preview is unavailable', () async {
      final File dwgFile = File('${tempDir.path}/drawing1.dwg');
      await dwgFile.writeAsBytes(<int>[1, 2, 3, 4, 5, 6]);

      final DwgPreviewConversionService service = DwgPreviewConversionService(
        tempDirectoryPath: tempDir.path,
      );

      expect(
        () => service.prepareDisplayablePreview(sourcePath: dwgFile.path),
        throwsA(
          isA<ImageImportFailure>().having(
            (ImageImportFailure error) => error.message,
            'message',
            ImageImportConstants.dwgPreviewUnavailableMessage,
          ),
        ),
      );
    });
  });
}

DwgEnvironmentLookup _environmentFromMap(Map<String, String> values) {
  return (String key) => values[key];
}

Uint8List _buildFakeDwgWithPngPreview(Uint8List pngBytes) {
  final BytesBuilder builder = BytesBuilder(copy: false);
  builder.add(Uint8List.fromList(List<int>.filled(567, 0)));
  builder.add(pngBytes);
  builder.add(Uint8List.fromList(List<int>.filled(64, 0)));
  return builder.toBytes();
}

Uint8List _buildLowQualityPngPreviewBytes() {
  return base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAQAAAACOCAAAAAD71ImmAAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAACYktHRAD/h4/MvwAAAAd0SU1FB+oGEgMbKJCeJckAAAAldEVYdGRhdGU6Y3JlYXRlADIwMjYtMDYtMThUMDM6Mjc6NDArMDA6MDCUNKPhAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDI2LTA2LTE4VDAzOjI3OjQwKzAwOjAw5WkbXQAAACh0RVh0ZGF0ZTp0aW1lc3RhbXAAMjAyNi0wNi0xOFQwMzoyNzo0MCswMDowMLJ8OoIAAAFASURBVHja7dwhDoBQDMBQPgHuf14UCo8geWKtmphomumtc5vNrgU0BdACmgJoAU0BtICmAFpAUwAtoCmAFtAUQAtoCqAFNAXQApoCaAFNAbSApgBaQFMALaApgBbQFEALaAqgBTQF0AKaAmgBTQG0gKYAWkBTAC2gKYAW0BRAC2gKoAU0BdACmkML/M/9Zel6h/EXUAAtoCmAFtAUQAtoCqAFNAXQApoCaAFNAbSApgBaQFMALaApgBbQFEALaAqgBTQF0AKaAmgBTQG0gKYAWkBTAC2gGR9g9Vh5OAXQApoCaAFNAbSApgBaQFMALaApgBbQFEALaAqgBTQF0AKaAmgBTQG0gKYAWkBTAC2gKYAW0BRAC2gKoAU0BdACmgJoAU0BtICmAFpAUwAtoCmAFtAUQAtoCqAFNAXQAprxAR6D2wInNgXPqgAAAABJRU5ErkJggg==',
  );
}

Uint8List _buildUsablePngPreviewBytes() {
  return base64Decode(
    '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',
  );
}

Uint8List _buildDarkBackgroundBmpPreviewBytes() {
  const int width = 640;
  const int height = 400;
  const int bytesPerPixel = 3;
  final int rowStride = ((width * bytesPerPixel) + 3) & ~3;
  final int pixelDataSize = rowStride * height;
  final ByteData header = ByteData(54);
  header.setUint8(0, 0x42);
  header.setUint8(1, 0x4D);
  header.setUint32(2, 54 + pixelDataSize, Endian.little);
  header.setUint32(10, 54, Endian.little);
  header.setUint32(14, 40, Endian.little);
  header.setInt32(18, width, Endian.little);
  header.setInt32(22, height, Endian.little);
  header.setUint16(26, 1, Endian.little);
  header.setUint16(28, 24, Endian.little);
  header.setUint32(34, pixelDataSize, Endian.little);

  final Uint8List bytes = Uint8List(54 + pixelDataSize);
  bytes.setRange(0, 54, header.buffer.asUint8List());

  for (int y = 0; y < height; y += 1) {
    for (int x = 0; x < width; x += 1) {
      final bool isContent = x >= 540 && x <= 620 && y >= 160 && y <= 240;
      final int rowOffset = 54 + ((height - 1 - y) * rowStride);
      final int pixelOffset = rowOffset + (x * bytesPerPixel);
      final int color = isContent ? 255 : 5;
      bytes[pixelOffset] = color;
      bytes[pixelOffset + 1] = color;
      bytes[pixelOffset + 2] = color;
    }
  }

  return bytes;
}
