import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';

class MarkupTypographyUtils {
  const MarkupTypographyUtils._();

  static String normalizeFontFamily(String? value) {
    final String trimmed = value?.trim() ?? '';
    for (final String allowed
        in MarkupTypographyConstants.allowedFontFamilies) {
      if (allowed == trimmed) {
        return allowed;
      }
    }
    return MarkupTypographyConstants.defaultFontFamily;
  }

  static double normalizeFontSize(double? value) {
    final double raw = value ?? MarkupTypographyConstants.defaultFontSize;
    return raw.clamp(
      MarkupTypographyConstants.minFontSize,
      MarkupTypographyConstants.maxFontSize,
    );
  }

  static String? resolveTextStyleFontFamily(String? value) {
    final String normalized = normalizeFontFamily(value);
    if (normalized == MarkupTypographyConstants.defaultFontFamily) {
      return null;
    }
    return normalized;
  }

  static TextStyle baseTextStyle({
    required Color color,
    required double fontSize,
    required FontWeight fontWeight,
    required String? fontFamily,
  }) {
    return TextStyle(
      color: color,
      fontSize: normalizeFontSize(fontSize),
      fontWeight: fontWeight,
      fontFamily: resolveTextStyleFontFamily(fontFamily),
    );
  }
}
