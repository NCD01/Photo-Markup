class DimensionLabelFormatter {
  const DimensionLabelFormatter._();

  static final RegExp _inchesOnly = RegExp(
    r'''^(\d+)\s*(?:"|in|inch|inches)?$''',
    caseSensitive: false,
  );

  static final RegExp _feetAndInchesWithSpace = RegExp(
    r'''^(\d+)\s+(\d+)$''',
    caseSensitive: false,
  );

  static final RegExp _feetOnly = RegExp(
    r'''^(\d+)\s*(?:ft|feet|')\s*$''',
    caseSensitive: false,
  );

  static final RegExp _feetInchesWithUnits = RegExp(
    r'''^(\d+)\s*(?:ft|feet|')\s*(?:[-\s]*\s*(\d+)\s*(?:"|in|inch|inches)?)?$''',
    caseSensitive: false,
  );

  static String format(String input) {
    final String trimmed = input.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final RegExpMatch? inchesMatch = _inchesOnly.firstMatch(trimmed);
    if (inchesMatch != null) {
      final int? inches = int.tryParse(inchesMatch.group(1)!);
      if (inches != null) {
        return _formatInches(inches);
      }
    }

    final RegExpMatch? feetSpaceMatch = _feetAndInchesWithSpace.firstMatch(
      trimmed,
    );
    if (feetSpaceMatch != null) {
      final int? feet = int.tryParse(feetSpaceMatch.group(1)!);
      final int? inches = int.tryParse(feetSpaceMatch.group(2)!);
      if (feet != null && inches != null) {
        return _formatInches((feet * 12) + inches);
      }
    }

    final RegExpMatch? feetOnlyMatch = _feetOnly.firstMatch(trimmed);
    if (feetOnlyMatch != null) {
      final int? feet = int.tryParse(feetOnlyMatch.group(1)!);
      if (feet != null) {
        return _formatInches(feet * 12);
      }
    }

    final RegExpMatch? feetMatch = _feetInchesWithUnits.firstMatch(trimmed);
    if (feetMatch != null) {
      final int? feet = int.tryParse(feetMatch.group(1)!);
      final int inches = int.tryParse(feetMatch.group(2) ?? '0') ?? 0;
      if (feet != null) {
        return _formatInches((feet * 12) + inches);
      }
    }

    return trimmed;
  }

  static String _formatInches(int inches) {
    return '$inches"';
  }
}
