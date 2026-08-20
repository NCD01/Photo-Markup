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
  /// With [system] left at [MeasurementUnitSystem.auto] nothing is converted:
  /// a value calibrated in feet is reported in feet and inches, and a value
  /// calibrated in metres is reported in metric. Choosing imperial or metric
  /// converts for display and nothing else. An unrecognised unit is passed
  /// through untouched in every case, because there is nothing to convert from.
  static String format({
    required double value,
    required String unitLabel,
    MeasurementDisplayMode mode = MeasurementDisplayMode.tape,
    MeasurementUnitSystem system = MeasurementUnitSystem.auto,
  }) {
    final String unit = unitLabel.trim();
    if (!value.isFinite || value < 0) {
      // Nonsense in, nonsense out, but no crash and no invented number.
      // Converting it would only dress the nonsense up in a different unit.
      return _plain(value: value, unit: unit);
    }

    final _UnitFamily sourceFamily = _familyFor(unit);
    final _Converted converted = _convert(
      value: value,
      family: sourceFamily,
      sourceUnit: unit,
      system: system,
    );

    if (mode == MeasurementDisplayMode.decimal) {
      // The calibrated number rather than a tape reading, for copying into a
      // quote. Still reported in the chosen system.
      return _plain(value: converted.value, unit: converted.unit);
    }

    switch (converted.family) {
      case _UnitFamily.feet:
        return _formatFeet(converted.value);
      case _UnitFamily.inches:
        return _formatInchesValue(converted.value);
      case _UnitFamily.metres:
        return _formatMetres(converted.value);
      case _UnitFamily.centimetres:
        return _formatCentimetres(converted.value);
      case _UnitFamily.millimetres:
        return _formatMillimetres(converted.value);
      case _UnitFamily.unknown:
        return _plain(value: converted.value, unit: converted.unit);
    }
  }

  // --- unit system ----------------------------------------------------------

  /// Moves a value into the system the user asked to read in.
  ///
  /// Display only, and the only place a measured number is ever multiplied by
  /// anything for presentation. A unit we do not recognise is left alone, on
  /// the grounds that converting from a unit you cannot identify is guessing.
  static _Converted _convert({
    required double value,
    required _UnitFamily family,
    required String sourceUnit,
    required MeasurementUnitSystem system,
  }) {
    // Anything not converted keeps the unit label it arrived with, so a unit
    // we do not recognise still prints the way the user wrote it.
    final _Converted unchanged = _Converted(
      value: value,
      family: family,
      unit: sourceUnit,
    );
    if (system == MeasurementUnitSystem.auto ||
        family == _UnitFamily.unknown) {
      return unchanged;
    }
    if (system == MeasurementUnitSystem.imperial && _isImperial(family)) {
      return unchanged;
    }
    if (system == MeasurementUnitSystem.metric && !_isImperial(family)) {
      return unchanged;
    }

    final double metres = _toMetres(value: value, family: family);
    if (system == MeasurementUnitSystem.metric) {
      return _Converted(
        value: metres,
        family: _UnitFamily.metres,
        unit: MeasurementDisplayConstants.metreShort,
      );
    }
    return _Converted(
      value: metres / MeasurementDisplayConstants.metresPerFoot,
      family: _UnitFamily.feet,
      unit: MeasurementDisplayConstants.footShort,
    );
  }

  static bool _isImperial(_UnitFamily family) {
    return family == _UnitFamily.feet || family == _UnitFamily.inches;
  }

  static double _toMetres({
    required double value,
    required _UnitFamily family,
  }) {
    switch (family) {
      case _UnitFamily.feet:
        return value * MeasurementDisplayConstants.metresPerFoot;
      case _UnitFamily.inches:
        return value * MeasurementDisplayConstants.metresPerInch;
      case _UnitFamily.metres:
        return value;
      case _UnitFamily.centimetres:
        return value / MeasurementDisplayConstants.centimetresPerMetre;
      case _UnitFamily.millimetres:
        return value /
            (MeasurementDisplayConstants.centimetresPerMetre *
                MeasurementDisplayConstants.millimetresPerCentimetre);
      case _UnitFamily.unknown:
        return value;
    }
  }

  // --- imperial -------------------------------------------------------------

  /// A value already expressed in feet.
  static String _formatFeet(double feetValue) {
    return _fromSixteenths(
      (feetValue * MeasurementDisplayConstants.fractionsPerFoot).round(),
    );
  }

  /// A value already expressed in inches.
  static String _formatInchesValue(double inchesValue) {
    return _fromSixteenths(
      (inchesValue * MeasurementDisplayConstants.fractionDenominator).round(),
    );
  }

  /// Single place that decides how an imperial length reads.
  ///
  /// Everything arrives here as a whole number of sixteenths of an inch, which
  /// is what a tape is marked in, so the rounding has already happened and this
  /// only has to decide how to say it. Under a foot it is inches alone. A foot
  /// or more is feet then inches, with inches dropped when there are none. The
  /// fraction is reduced, so eight sixteenths reads as a half, and it is left
  /// off entirely when it is zero. Sixteen sixteenths became a whole inch and
  /// twelve inches became a foot before we got here, by arithmetic, so nothing
  /// can ever read `16/16` or `12 in`.
  static String _fromSixteenths(int totalSixteenths) {
    if (totalSixteenths <= 0) {
      // A real length too small for a tape to show. Never `0 in`.
      return '${MeasurementDisplayConstants.belowSmallestFraction} '
          '1/${MeasurementDisplayConstants.fractionDenominator} '
          '${MeasurementDisplayConstants.inchShort}';
    }

    final int perFoot = MeasurementDisplayConstants.fractionsPerFoot;
    final int perInch = MeasurementDisplayConstants.fractionDenominator;
    final int feet = totalSixteenths ~/ perFoot;
    final int withinFoot = totalSixteenths % perFoot;
    final int inches = withinFoot ~/ perInch;
    final String fraction = _reducedFraction(withinFoot % perInch);

    final String inchText = _inchText(inches: inches, fraction: fraction);
    if (feet == 0) {
      return inchText;
    }
    final String feetText =
        '$feet ${MeasurementDisplayConstants.footShort}';
    if (inchText.isEmpty) {
      return feetText;
    }
    return '$feetText $inchText';
  }

  /// The inches half of a reading, empty when there is nothing to say.
  static String _inchText({required int inches, required String fraction}) {
    if (inches == 0 && fraction.isEmpty) {
      return '';
    }
    final String unit = MeasurementDisplayConstants.inchShort;
    if (fraction.isEmpty) {
      return '$inches $unit';
    }
    if (inches == 0) {
      return '$fraction $unit';
    }
    return '$inches $fraction $unit';
  }

  /// `8` sixteenths reads `1/2`, `12` reads `3/4`, `0` reads as nothing.
  static String _reducedFraction(int sixteenths) {
    if (sixteenths <= 0) {
      return '';
    }
    final int denominator = MeasurementDisplayConstants.fractionDenominator;
    final int divisor = _greatestCommonDivisor(sixteenths, denominator);
    return '${sixteenths ~/ divisor}/${denominator ~/ divisor}';
  }

  static int _greatestCommonDivisor(int a, int b) {
    int x = a;
    int y = b;
    while (y != 0) {
      final int next = x % y;
      x = y;
      y = next;
    }
    return x;
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

/// A value after the unit system has been applied, with the unit it is now in.
class _Converted {
  const _Converted({
    required this.value,
    required this.family,
    required this.unit,
  });

  final double value;
  final _UnitFamily family;
  final String unit;
}
