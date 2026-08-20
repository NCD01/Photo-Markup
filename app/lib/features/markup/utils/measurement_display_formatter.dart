import 'dart:math' as math;

import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/settings/models/app_settings.dart';

/// Turns a raw measured length into something readable on a job site.
///
/// `0.42 ft` is a number a spreadsheet produces. `5 in` is what a person reads
/// off a tape. This is the one place that rule lives; change it here and every
/// measured label changes with it.
///
/// DISPLAY ONLY. Nothing here is ever written back into stored geometry. The
/// normalized points on a mark stay exactly as measured, and a label the user
/// types is never routed through this class.
class MeasurementDisplayFormatter {
  const MeasurementDisplayFormatter._();

  /// Formats [value], expressed in [unitLabel], for display.
  ///
  /// Never converts between imperial and metric. A value calibrated in feet is
  /// reported in feet and inches; a value calibrated in metres is reported in
  /// metric. An unrecognised unit is passed through untouched rather than
  /// guessed at.
  static String format({
    required double value,
    required String unitLabel,
    MeasurementDisplayMode mode = MeasurementDisplayMode.tape,
  }) {
    final String unit = unitLabel.trim();
    if (mode == MeasurementDisplayMode.decimal) {
      // The raw calibrated number, for copying into a quote.
      return _plain(value: value, unit: unit);
    }
    if (!value.isFinite || value < 0) {
      // Nonsense in, nonsense out, but no crash and no invented number.
      return _plain(value: value, unit: unit);
    }

    final _UnitFamily family = _familyFor(unit);
    switch (family) {
      case _UnitFamily.feet:
        return _formatFeet(value);
      case _UnitFamily.inches:
        return _formatInchesValue(value);
      case _UnitFamily.metres:
        return _formatMetres(value);
      case _UnitFamily.centimetres:
        return _formatCentimetres(value);
      case _UnitFamily.millimetres:
        return _formatMillimetres(value);
      case _UnitFamily.unknown:
        return _plain(value: value, unit: unit);
    }
  }

  // --- imperial -------------------------------------------------------------

  /// A value already expressed in feet.
  static String _formatFeet(double feetValue) {
    final int totalInches = (feetValue * MeasurementDisplayConstants.inchesPerFoot)
        .round();
    return _fromTotalInches(totalInches);
  }

  /// A value already expressed in inches.
  static String _formatInchesValue(double inchesValue) {
    return _fromTotalInches(inchesValue.round());
  }

  /// Single place that decides how whole inches read.
  ///
  /// Under a foot it is inches alone. A foot or more is feet plus inches, and
  /// inches are dropped when they are zero. Inches that round up to a full foot
  /// are promoted, so nothing ever displays as `12 in`.
  static String _fromTotalInches(int totalInches) {
    final int perFoot = MeasurementDisplayConstants.inchesPerFoot;
    final int feet = totalInches ~/ perFoot;
    final int inches = totalInches % perFoot;

    if (feet == 0) {
      return '$inches ${MeasurementDisplayConstants.inchShort}';
    }
    if (inches == 0) {
      return '$feet ${MeasurementDisplayConstants.footShort}';
    }
    return '$feet ${MeasurementDisplayConstants.footShort} '
        '$inches ${MeasurementDisplayConstants.inchShort}';
  }

  // --- metric ---------------------------------------------------------------

  /// A value already expressed in metres.
  static String _formatMetres(double metresValue) {
    if (metresValue >= 1) {
      return '${_fixed(metresValue, MeasurementDisplayConstants.metreDecimals)} '
          '${MeasurementDisplayConstants.metreShort}';
    }
    return _formatCentimetres(
      metresValue * MeasurementDisplayConstants.centimetresPerMetre,
    );
  }

  /// A value already expressed in centimetres.
  static String _formatCentimetres(double centimetresValue) {
    if (centimetresValue >= MeasurementDisplayConstants.centimetresPerMetre) {
      return '${_fixed(centimetresValue / MeasurementDisplayConstants.centimetresPerMetre, MeasurementDisplayConstants.metreDecimals)} '
          '${MeasurementDisplayConstants.metreShort}';
    }
    if (centimetresValue < 1) {
      return _formatMillimetres(
        centimetresValue * MeasurementDisplayConstants.millimetresPerCentimetre,
      );
    }
    return '${_fixed(centimetresValue, MeasurementDisplayConstants.centimetreDecimals)} '
        '${MeasurementDisplayConstants.centimetreShort}';
  }

  /// A value already expressed in millimetres.
  static String _formatMillimetres(double millimetresValue) {
    final double perCm = MeasurementDisplayConstants.millimetresPerCentimetre;
    if (millimetresValue >= perCm) {
      return _formatCentimetres(millimetresValue / perCm);
    }
    return '${millimetresValue.round()} '
        '${MeasurementDisplayConstants.millimetreShort}';
  }

  // --- shared ---------------------------------------------------------------

  static _UnitFamily _familyFor(String unit) {
    final String key = unit.toLowerCase();
    if (MeasurementDisplayConstants.footAliases.contains(key)) {
      return _UnitFamily.feet;
    }
    if (MeasurementDisplayConstants.inchAliases.contains(key)) {
      return _UnitFamily.inches;
    }
    if (MeasurementDisplayConstants.metreAliases.contains(key)) {
      return _UnitFamily.metres;
    }
    if (MeasurementDisplayConstants.centimetreAliases.contains(key)) {
      return _UnitFamily.centimetres;
    }
    if (MeasurementDisplayConstants.millimetreAliases.contains(key)) {
      return _UnitFamily.millimetres;
    }
    return _UnitFamily.unknown;
  }

  static String _plain({required double value, required String unit}) {
    final String shown = value.isFinite
        ? _fixed(value, MeasurementToolConstants.displayPrecision)
        : MeasurementDisplayConstants.invalidValueLabel;
    final String suffix = unit.isEmpty
        ? MeasurementToolConstants.defaultUnitLabel
        : unit;
    return '$shown $suffix';
  }

  /// Fixed decimals with trailing zeros trimmed, so `2.50` reads as `2.5`.
  static String _fixed(double value, int decimals) {
    String fixed = value.toStringAsFixed(math.max(0, decimals));
    if (!fixed.contains('.')) {
      return fixed;
    }
    // replaceFirst takes a literal replacement, so a `$1` backreference here
    // would be written out verbatim. Trim instead.
    fixed = fixed.replaceFirst(RegExp(r'0+$'), '');
    return fixed.replaceFirst(RegExp(r'\.$'), '');
  }
}

enum _UnitFamily { feet, inches, metres, centimetres, millimetres, unknown }
