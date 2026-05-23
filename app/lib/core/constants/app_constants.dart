import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class AppConstants {
  const AppConstants._();

  static const String appName = 'NCD Photo Markup';
  static const String appVersion = 'v0.5';
  static const String startupImageEnvKey = 'NCD_STARTUP_IMAGE_PATH';
}

class BrandingAssetConstants {
  const BrandingAssetConstants._();

  static const String iconV15AssetPath = 'assets/branding/icon_v1_5.png';
  static const String splashV15AssetPath = 'assets/branding/splash_v1_5.png';
  static const int startupSplashDurationMs = 2200;
}

class AppThemeConstants {
  const AppThemeConstants._();

  static const Color ncdBlue = Color(0xFF009ADA);
  static const Color toolbarBackground = Color(0xFFF2FAFE);
  static const Color canvasFooterBorder = Color(0xFFD8E5EB);
  static const Color errorAccent = Colors.redAccent;
}

class ImageImportConstants {
  const ImageImportConstants._();

  static const String pickerGroupLabel = 'Images';
  static const String pickerConfirmButtonText = 'Open Photo';
  static const List<String> supportedExtensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const Set<String> supportedExtensionsSet = <String>{
    'jpg',
    'jpeg',
    'png',
    'webp',
  };
  static const String openErrorMessage =
      'Could not open this image. Please choose a JPG or PNG file.';
  static const String loadedPhotoPrefix = 'Loaded photo: ';
  static const String unknownLoadedPhotoName = 'Unknown';

  static const XTypeGroup imageTypeGroup = XTypeGroup(
    label: pickerGroupLabel,
    extensions: supportedExtensions,
  );
}

class UiCopyConstants {
  const UiCopyConstants._();

  static const String emptyStateTitle = 'Photo Canvas Placeholder';
  static const String emptyStateMessage =
      'Open or import a photo to start marking it up.';
  static const String splashFallbackLabel = 'NCD Photo Markup';
}

class ToolbarConstants {
  const ToolbarConstants._();

  static const String openPhoto = 'Open Photo';
  static const String dimension = 'Dimension';
  static const String undo = 'Undo';
  static const List<String> labels = <String>[
    openPhoto,
    dimension,
    'Arrow',
    'Circle',
    'Rectangle',
    'Freehand',
    'Text',
    'Erase',
    undo,
    'Save',
    'Export',
  ];
}

class UiLayoutConstants {
  const UiLayoutConstants._();

  static const double appBarBrandingIconSize = 32;
  static const double appBarBrandingIconPadding = 8;
  static const double splashImageWidthFactor = 0.97;
  static const double splashImageHeightFactor = 0.88;
  static const double splashImageHorizontalPadding = 12;
  static const double splashTitleTopGap = 16;
  static const double loadedNameMaxWidth = 260;
  static const double appBarLoadedNameRightPadding = 10;
  static const double appBarVersionRightPadding = 16;
  static const double canvasOuterPadding = 20;
  static const double canvasBorderRadius = 12;
  static const double canvasBorderWidth = 2;
  static const double toolbarHorizontalPadding = 12;
  static const double toolbarVerticalPadding = 12;
  static const double toolbarButtonGap = 4;
  static const double emptyStateHorizontalPadding = 24;
  static const double emptyStateIconSize = 64;
  static const double emptyStateTitleFontSize = 24;
  static const double emptyStateBodyFontSize = 18;
  static const double messageFontSize = 15;
  static const double emptyStateIconBottomGap = 16;
  static const double emptyStateTitleBottomGap = 12;
  static const double messageTopGap = 14;
  static const double imageAreaPadding = 12;
  static const double footerHorizontalPadding = 12;
  static const double footerVerticalPadding = 10;
  static const double toolbarButtonHeight = 56;
  static const double toolbarButtonMinWidth = 116;
  static const double toolbarButtonFontSize = 16;
  static const double loadedNameFontSize = 13;
  static const double toolbarButtonSelectedBorderWidth = 2.4;
  static const double dimensionEndpointOuterRadius = 5;
  static const double dimensionEndpointInnerRadius = 2.5;
  static const double dimensionTapDragMinDistance = 6;
}

class DimensionLineConstants {
  const DimensionLineConstants._();

  static const Color lineColor = Color(0xFF005C85);
  static const double strokeWidth = 3;
  static const double endpointStrokeWidth = 1.2;
  static const Color endpointFillColor = Colors.white;
}
