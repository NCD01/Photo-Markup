import 'package:flutter/material.dart';

/// The single place the app's look is defined.
///
/// Everything that follows is chosen for one situation: a tablet held in one
/// hand, outdoors, in daylight, by someone wearing gloves. That means dark
/// chrome so the photo is the brightest thing on screen, heavy text, contrast
/// well past the accessibility minimums, and controls sized for a thumb.
class DesignTokens {
  const DesignTokens._();

  // ---------------------------------------------------------------- identity

  /// Bundled so the app looks the same offline and on every platform, and so
  /// the UI is not wearing the same typeface as everything else.
  static const String fontFamily = 'Barlow';

  /// NCD's blue, held for brand recognition but only used where it earns
  /// attention: the active tool, the focus ring, the primary action.
  static const Color brand = Color(0xFF00A8F0);
  static const Color brandBright = Color(0xFF5FD2FF);
  static const Color brandDim = Color(0xFF0A6E9C);

  // ----------------------------------------------------------------- surfaces

  /// Near-black, not pure black. Pure black next to a photo reads as a hole.
  static const Color canvasVoid = Color(0xFF0B0F12);
  static const Color surface = Color(0xFF141A1F);
  static const Color surfaceRaised = Color(0xFF1C242B);
  static const Color surfaceHigh = Color(0xFF27323B);
  static const Color hairline = Color(0xFF31404B);
  static const Color hairlineStrong = Color(0xFF4A5D6B);

  // --------------------------------------------------------------------- ink

  /// Contrast against [surface]: 15.2:1. Nothing below w600 is used at size,
  /// because thin type disappears in sunlight.
  static const Color inkPrimary = Color(0xFFF2F7FA);

  /// Contrast against [surface]: 8.6:1. This is as quiet as text gets. There is
  /// deliberately no third, dimmer step; grey-on-grey is unreadable outdoors.
  static const Color inkSecondary = Color(0xFFB4C4CF);
  static const Color inkOnBrand = Color(0xFF010D13);
  static const Color inkDisabled = Color(0xFF6E808D);

  // ------------------------------------------------------------------ states

  static const Color danger = Color(0xFFFF5C5C);
  static const Color success = Color(0xFF39D98A);
  static const Color warning = Color(0xFFFFC24B);
  static const Color selectedFill = Color(0x2900A8F0);
  static const Color pressedFill = Color(0x1FFFFFFF);

  // ------------------------------------------------------------------ metrics

  /// 4pt grid.
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;

  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 18;

  /// Minimum tappable size. Material says 48; a gloved thumb on a cold morning
  /// wants more, and there is room for it on a tablet.
  static const double touchTarget = 56;
  static const double touchTargetCompact = 48;
  static const double iconSize = 26;
  static const double iconSizeSmall = 20;

  // ------------------------------------------------------------------ type

  static const double textDisplay = 26;
  static const double textTitle = 19;
  static const double textBody = 16;
  static const double textLabel = 14;
  static const double textMicro = 12;

  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  // ---------------------------------------------------------------- motion

  /// Motion is used for one thing only: showing where a panel went, so it does
  /// not appear to teleport. Nothing decorative animates.
  static const Duration motionFast = Duration(milliseconds: 120);
  static const Duration motionPanel = Duration(milliseconds: 180);
  static const Curve motionCurve = Curves.easeOutCubic;

  // ------------------------------------------------------------------ layout

  static const double railWidth = 76;
  static const double railExpandedWidth = 232;
  static const double statusBarHeight = 60;
  static const double minimumCanvasWidth = 320;

  static ThemeData buildTheme() {
    const ColorScheme scheme = ColorScheme.dark(
      primary: brand,
      onPrimary: inkOnBrand,
      secondary: brandBright,
      onSecondary: inkOnBrand,
      surface: surface,
      onSurface: inkPrimary,
      error: danger,
      onError: inkOnBrand,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: canvasVoid,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: const DividerThemeData(color: hairline, thickness: 1),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: textDisplay,
          fontWeight: weightBold,
          color: inkPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: textTitle,
          fontWeight: weightBold,
          color: inkPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: textBody,
          fontWeight: weightRegular,
          color: inkPrimary,
        ),
        labelLarge: TextStyle(
          fontSize: textLabel,
          fontWeight: weightMedium,
          color: inkPrimary,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surfaceRaised,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: textTitle,
          fontWeight: weightBold,
          color: inkPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: textBody,
          fontWeight: weightRegular,
          color: inkSecondary,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: textBody,
          fontWeight: weightMedium,
          color: inkPrimary,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: inkPrimary,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: textBody,
            fontWeight: weightMedium,
          ),
          minimumSize: const Size(88, touchTargetCompact),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: inkOnBrand,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: textBody,
            fontWeight: weightBold,
          ),
          minimumSize: const Size(96, touchTargetCompact),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: surfaceHigh,
        selectedColor: brand,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: textLabel,
          fontWeight: weightMedium,
          color: inkPrimary,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: textLabel,
          fontWeight: weightBold,
          color: inkOnBrand,
        ),
        side: BorderSide(color: hairline),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderSide: BorderSide(color: hairline)),
        labelStyle: TextStyle(color: inkSecondary),
        hintStyle: TextStyle(color: inkDisabled),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceHigh,
          borderRadius: BorderRadius.all(Radius.circular(radiusSmall)),
        ),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: textLabel,
          fontWeight: weightMedium,
          color: inkPrimary,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: brand,
        inactiveTrackColor: hairline,
        thumbColor: brandBright,
      ),
    );
  }
}
