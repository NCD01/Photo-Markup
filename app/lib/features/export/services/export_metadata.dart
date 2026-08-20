import 'package:flutter/widgets.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/integration/models/photo_markup_launch_context.dart';
import 'package:ncd_photo_markup/features/markup/models/scale_calibration.dart';
import 'package:ncd_photo_markup/features/markup/utils/measurement_value_utils.dart';

/// The field set stamped onto an export and written into the markup sidecar.
///
/// Every value here is something the app already knows: it came in on the
/// command line from Control Center, or it is a fact about the photo and the
/// markup on it. Nothing is invented, asked for, or filled in with a
/// placeholder, because a metadata field that says "Unknown" on a document
/// going to a client is worse than a field that is not there.
///
/// Keywords follow the PNG specification where one exists for the thing being
/// recorded: `Software`, `Creation Time` and `Source` are standard keywords
/// that other tools already understand. The rest are prefixed `NCD ` so it is
/// obvious where they came from when someone opens the file in Explorer.
class ExportMetadata {
  const ExportMetadata._();

  static const String softwareKey = 'Software';
  static const String creationTimeKey = 'Creation Time';
  static const String sourceKey = 'Source';
  static const String clientKey = 'NCD Client';
  static const String projectKey = 'NCD Project';
  static const String sourceLabelKey = 'NCD Source Label';
  static const String photoSizeKey = 'NCD Photo Size';
  static const String scaleKey = 'NCD Scale';
  static const String markCountKey = 'NCD Marks';

  /// Builds the field set. Anything the app does not know is left out.
  static Map<String, String> build({
    required String appVersion,
    required DateTime exportedAtUtc,
    PhotoMarkupLaunchContext? launchContext,
    String? sourceImageFileName,
    Size? imagePixelSize,
    ScaleCalibration? scaleCalibration,
    int markCount = 0,
  }) {
    final Map<String, String> fields = <String, String>{
      softwareKey: '${AppConstants.appName} $appVersion',
      creationTimeKey: exportedAtUtc.toUtc().toIso8601String(),
    };

    _put(fields, sourceKey, sourceImageFileName);
    _put(fields, clientKey, launchContext?.clientName);
    _put(fields, projectKey, launchContext?.projectCode);
    _put(fields, sourceLabelKey, launchContext?.sourceLabel);

    if (imagePixelSize != null &&
        imagePixelSize.width > 0 &&
        imagePixelSize.height > 0) {
      fields[photoSizeKey] =
          '${imagePixelSize.width.round()} x '
          '${imagePixelSize.height.round()} px';
    }

    if (scaleCalibration != null) {
      // The same text the app shows on the calibration line, so what is in the
      // file and what was on the screen cannot drift apart.
      fields[scaleKey] = MeasurementValueUtils.calibrationDisplayLabel(
        scaleCalibration,
      );
    }

    if (markCount > 0) {
      fields[markCountKey] = '$markCount';
    }

    return fields;
  }

  static void _put(Map<String, String> fields, String key, String? value) {
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      fields[key] = trimmed;
    }
  }
}
