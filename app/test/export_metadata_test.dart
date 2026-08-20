import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/export/services/export_metadata.dart';
import 'package:ncd_photo_markup/features/export/services/png_metadata_writer.dart';
import 'package:ncd_photo_markup/features/integration/models/photo_markup_launch_context.dart';
import 'package:ncd_photo_markup/features/markup/models/scale_calibration.dart';

/// A one pixel PNG, base64, so the chunk work is tested against a real file
/// rather than something this test invented.
const String _onePixelPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmM'
    'IQAAAABJRU5ErkJggg==';

Uint8List _onePixelPng() => base64Decode(_onePixelPngBase64);

void main() {
  group('PngMetadataWriter', () {
    test('a stamped PNG is still a PNG', () {
      final Uint8List stamped = PngMetadataWriter.withTextFields(
        _onePixelPng(),
        <String, String>{'Software': 'NCD Photo Markup v0.43'},
      );
      expect(PngMetadataWriter.isPng(stamped), isTrue);
      expect(stamped.length, greaterThan(_onePixelPng().length));
    });

    test('what goes in comes back out', () {
      final Map<String, String> fields = <String, String>{
        'Software': 'NCD Photo Markup v0.43',
        'NCD Client': 'Smith Residence',
        'NCD Project': 'JOB-2261',
      };
      final Uint8List stamped = PngMetadataWriter.withTextFields(
        _onePixelPng(),
        fields,
      );
      expect(PngMetadataWriter.readTextFields(stamped), fields);
    });

    test('the image data is untouched', () {
      final Uint8List original = _onePixelPng();
      final Uint8List stamped = PngMetadataWriter.withTextFields(
        original,
        <String, String>{'NCD Client': 'Smith Residence'},
      );
      // The signature and IHDR are byte for byte what they were, and every
      // byte after IHDR is still there in order at the end. Only text chunks
      // were inserted between the two; no pixel was decoded or re-encoded.
      const int headerEnd = 8 + 4 + 4 + 13 + 4; // signature + IHDR
      expect(stamped.sublist(0, headerEnd), original.sublist(0, headerEnd));
      final Uint8List originalTail = original.sublist(headerEnd);
      expect(
        stamped.sublist(stamped.length - originalTail.length),
        originalTail,
      );
    });

    test('an empty value is left out rather than written blank', () {
      final Uint8List stamped = PngMetadataWriter.withTextFields(
        _onePixelPng(),
        <String, String>{'NCD Client': '   ', 'NCD Project': 'JOB-2261'},
      );
      final Map<String, String> read = PngMetadataWriter.readTextFields(
        stamped,
      );
      expect(read.containsKey('NCD Client'), isFalse);
      expect(read['NCD Project'], 'JOB-2261');
    });

    test('bytes that are not a PNG come back unchanged', () {
      final Uint8List notAPng = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
      expect(
        PngMetadataWriter.withTextFields(notAPng, <String, String>{
          'Software': 'x',
        }),
        notAPng,
      );
    });

    test('no fields means no change at all', () {
      final Uint8List original = _onePixelPng();
      expect(
        PngMetadataWriter.withTextFields(original, const <String, String>{}),
        original,
      );
    });

    test('a character PNG text cannot hold does not corrupt the file', () {
      final Uint8List stamped = PngMetadataWriter.withTextFields(
        _onePixelPng(),
        <String, String>{'NCD Client': 'Sm中th'},
      );
      expect(PngMetadataWriter.isPng(stamped), isTrue);
      expect(PngMetadataWriter.readTextFields(stamped)['NCD Client'], 'Sm?th');
    });

    test('reading a file with no text chunks finds nothing', () {
      expect(PngMetadataWriter.readTextFields(_onePixelPng()), isEmpty);
    });
  });

  group('ExportMetadata field set', () {
    test('the always-present fields are the software and the time', () {
      final Map<String, String> fields = ExportMetadata.build(
        appVersion: 'v0.43',
        exportedAtUtc: DateTime.utc(2026, 8, 20, 12, 30),
      );
      expect(fields[ExportMetadata.softwareKey], 'NCD Photo Markup v0.43');
      expect(
        fields[ExportMetadata.creationTimeKey],
        DateTime.utc(2026, 8, 20, 12, 30).toIso8601String(),
      );
    });

    test('job fields come from the launch context and nowhere else', () {
      final Map<String, String> fields = ExportMetadata.build(
        appVersion: 'v0.43',
        exportedAtUtc: DateTime.utc(2026, 8, 20),
        launchContext: const PhotoMarkupLaunchContext(
          launchedFromControlCenter: true,
          clientName: 'Smith Residence',
          projectCode: 'JOB-2261',
          sourceLabel: 'Front elevation',
        ),
      );
      expect(fields[ExportMetadata.clientKey], 'Smith Residence');
      expect(fields[ExportMetadata.projectKey], 'JOB-2261');
      expect(fields[ExportMetadata.sourceLabelKey], 'Front elevation');
    });

    test('nothing is invented when the app was not told', () {
      final Map<String, String> fields = ExportMetadata.build(
        appVersion: 'v0.43',
        exportedAtUtc: DateTime.utc(2026, 8, 20),
      );
      expect(fields.containsKey(ExportMetadata.clientKey), isFalse);
      expect(fields.containsKey(ExportMetadata.projectKey), isFalse);
      expect(fields.containsKey(ExportMetadata.sourceLabelKey), isFalse);
      expect(fields.containsKey(ExportMetadata.scaleKey), isFalse);
      expect(fields.containsKey(ExportMetadata.markCountKey), isFalse);
      // Specifically: no placeholder text.
      for (final String value in fields.values) {
        expect(value.toLowerCase(), isNot(contains('unknown')));
        expect(value.toLowerCase(), isNot(contains('n/a')));
      }
    });

    test('a blank launch context value is treated as not knowing', () {
      final Map<String, String> fields = ExportMetadata.build(
        appVersion: 'v0.43',
        exportedAtUtc: DateTime.utc(2026, 8, 20),
        launchContext: const PhotoMarkupLaunchContext(
          launchedFromControlCenter: true,
          clientName: '   ',
        ),
      );
      expect(fields.containsKey(ExportMetadata.clientKey), isFalse);
    });

    test('capture fields describe the photo and the markup on it', () {
      final Map<String, String> fields = ExportMetadata.build(
        appVersion: 'v0.43',
        exportedAtUtc: DateTime.utc(2026, 8, 20),
        sourceImageFileName: 'front.jpg',
        imagePixelSize: const Size(4032, 3024),
        markCount: 7,
        scaleCalibration: const ScaleCalibration(
          id: 1,
          startNormalized: Offset(0, 0.5),
          endNormalized: Offset(1, 0.5),
          realDistance: 10,
          unitLabel: 'ft',
        ),
      );
      expect(fields[ExportMetadata.sourceKey], 'front.jpg');
      expect(fields[ExportMetadata.photoSizeKey], '4032 x 3024 px');
      expect(fields[ExportMetadata.markCountKey], '7');
      expect(fields[ExportMetadata.scaleKey], contains('10'));
      expect(fields[ExportMetadata.scaleKey], contains('ft'));
    });

    test('a photo with no marks does not claim a mark count', () {
      final Map<String, String> fields = ExportMetadata.build(
        appVersion: 'v0.43',
        exportedAtUtc: DateTime.utc(2026, 8, 20),
        markCount: 0,
      );
      expect(fields.containsKey(ExportMetadata.markCountKey), isFalse);
    });

    test('the whole field set survives a trip through a PNG', () {
      final Map<String, String> fields = ExportMetadata.build(
        appVersion: AppConstants.appVersion,
        exportedAtUtc: DateTime.utc(2026, 8, 20, 9),
        launchContext: const PhotoMarkupLaunchContext(
          launchedFromControlCenter: true,
          clientName: 'Smith Residence',
          projectCode: 'JOB-2261',
          sourceLabel: 'Front elevation',
        ),
        sourceImageFileName: 'front.jpg',
        imagePixelSize: const Size(4032, 3024),
        markCount: 7,
      );
      final Uint8List stamped = PngMetadataWriter.withTextFields(
        _onePixelPng(),
        fields,
      );
      expect(PngMetadataWriter.readTextFields(stamped), fields);
    });
  });
}
