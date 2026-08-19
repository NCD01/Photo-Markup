import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';

/// A real-world length calibrated against the photo.
///
/// Drag across something whose size you know, tell the app what it is, and
/// every measurement on that photo can be stated in feet and inches instead of
/// typed by hand.
///
/// The calibration is stored as a normalised length across the photo, so it
/// survives window resizing and reopening exactly like every annotation does.
/// It is not stored in pixels, because the displayed pixel size changes.
@immutable
class PhotoScale {
  const PhotoScale({
    required this.referenceNormalizedLength,
    required this.referenceInches,
    required this.calibratedStart,
    required this.calibratedEnd,
  });

  /// Length of the calibration line as a fraction of the photo's diagonal.
  final double referenceNormalizedLength;

  /// What the user said that length is, in inches.
  final double referenceInches;

  final Offset calibratedStart;
  final Offset calibratedEnd;

  bool get isUsable =>
      referenceNormalizedLength > PhotoScaleConstants.minimumNormalizedLength &&
      referenceInches >= PhotoScaleConstants.minimumInches &&
      referenceInches <= PhotoScaleConstants.maximumInches;

  /// Inches per unit of normalised diagonal length.
  double get inchesPerNormalizedUnit =>
      referenceInches / referenceNormalizedLength;

  /// Converts a normalised diagonal length into inches.
  double inchesForNormalizedLength(double normalizedLength) =>
      normalizedLength * inchesPerNormalizedUnit;

  /// The diagonal-relative length of a segment on the photo.
  ///
  /// Using the diagonal rather than the width means a measurement is correct in
  /// any direction, which a width-only normalisation would not be on a
  /// non-square photo.
  static double normalizedLengthBetween({
    required Offset startNormalized,
    required Offset endNormalized,
    required Size imagePixelSize,
  }) {
    if (imagePixelSize.width <= 0 || imagePixelSize.height <= 0) {
      return 0;
    }
    final double dx =
        (endNormalized.dx - startNormalized.dx) * imagePixelSize.width;
    final double dy =
        (endNormalized.dy - startNormalized.dy) * imagePixelSize.height;
    final double pixels = Offset(dx, dy).distance;
    final double diagonal = Offset(
      imagePixelSize.width,
      imagePixelSize.height,
    ).distance;
    return diagonal <= 0 ? 0 : pixels / diagonal;
  }

  /// "6'-2"" for 74 inches, "9"" for nine.
  static String formatInches(double inches) {
    if (inches.isNaN || inches.isInfinite || inches < 0) {
      return '';
    }
    final int rounded = inches.round();
    if (rounded < 12) {
      return '$rounded"';
    }
    final int feet = rounded ~/ 12;
    final int remainder = rounded % 12;
    if (remainder == 0) {
      return "$feet'-0\"";
    }
    return "$feet'-$remainder\"";
  }

  /// Parses what the user typed for the reference length.
  ///
  /// Accepts 8, 8", 8 in, 4', 4 ft, 6'2", 6-2, and 6 2.
  static double? parseInches(String input) {
    final String text = input.trim().toLowerCase();
    if (text.isEmpty) {
      return null;
    }

    for (final RegExp pattern in <RegExp>[
      _feetMarkThenInches,
      _bareFeetDashInches,
    ]) {
      final RegExpMatch? match = pattern.firstMatch(text);
      if (match == null) {
        continue;
      }
      final double? feet = double.tryParse(match.group(1)!);
      final double inches = double.tryParse(match.group(2) ?? '0') ?? 0;
      if (feet != null) {
        return (feet * 12) + inches;
      }
    }

    final RegExpMatch? feetOnly = _feetOnly.firstMatch(text);
    if (feetOnly != null) {
      final double? feet = double.tryParse(feetOnly.group(1)!);
      if (feet != null) {
        return feet * 12;
      }
    }

    final RegExpMatch? inchesOnly = _inchesOnly.firstMatch(text);
    if (inchesOnly != null) {
      return double.tryParse(inchesOnly.group(1)!);
    }
    return null;
  }

  /// 6'2" and 6 ft 2 in: the foot mark itself separates the two numbers.
  static final RegExp _feetMarkThenInches = RegExp(
    r'''^(\d+(?:\.\d+)?)\s*(?:'|ft|feet)\s*[-\s]?\s*(\d+(?:\.\d+)?)\s*(?:"|in|inch|inches)?$''',
  );

  /// 6-2 and 6 2: no units at all, which is how it usually gets written down.
  static final RegExp _bareFeetDashInches = RegExp(
    r'''^(\d+(?:\.\d+)?)\s*[-\s]\s*(\d+(?:\.\d+)?)$''',
  );
  static final RegExp _feetOnly = RegExp(
    r"""^(\d+(?:\.\d+)?)\s*(?:'|ft|feet)$""",
  );
  static final RegExp _inchesOnly = RegExp(
    r'''^(\d+(?:\.\d+)?)\s*(?:"|in|inch|inches)?$''',
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'referenceNormalizedLength': referenceNormalizedLength,
    'referenceInches': referenceInches,
    'calibratedStart': <String, dynamic>{
      'x': calibratedStart.dx,
      'y': calibratedStart.dy,
    },
    'calibratedEnd': <String, dynamic>{
      'x': calibratedEnd.dx,
      'y': calibratedEnd.dy,
    },
  };

  static PhotoScale? fromJson(dynamic value) {
    if (value is! Map) {
      return null;
    }
    double? asDouble(dynamic raw) {
      if (raw is num) {
        return raw.toDouble();
      }
      if (raw is String) {
        return double.tryParse(raw);
      }
      return null;
    }

    Offset? asOffset(dynamic raw) {
      if (raw is! Map) {
        return null;
      }
      final double? x = asDouble(raw['x']);
      final double? y = asDouble(raw['y']);
      return (x == null || y == null) ? null : Offset(x, y);
    }

    final double? length = asDouble(value['referenceNormalizedLength']);
    final double? inches = asDouble(value['referenceInches']);
    final Offset? start = asOffset(value['calibratedStart']);
    final Offset? end = asOffset(value['calibratedEnd']);
    if (length == null || inches == null || start == null || end == null) {
      return null;
    }
    final PhotoScale scale = PhotoScale(
      referenceNormalizedLength: length,
      referenceInches: inches,
      calibratedStart: start,
      calibratedEnd: end,
    );
    return scale.isUsable ? scale : null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PhotoScale &&
        other.referenceNormalizedLength == referenceNormalizedLength &&
        other.referenceInches == referenceInches &&
        other.calibratedStart == calibratedStart &&
        other.calibratedEnd == calibratedEnd;
  }

  @override
  int get hashCode => Object.hash(
    referenceNormalizedLength,
    referenceInches,
    calibratedStart,
    calibratedEnd,
  );
}
