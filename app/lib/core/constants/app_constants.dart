import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class AppConstants {
  const AppConstants._();

  static const String appName = 'NCD Photo Markup';
  static const String appVersion = 'v0.15';
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
    'heic',
    'heif',
  ];
  static const Set<String> supportedExtensionsSet = <String>{
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'heif',
  };
  static const Set<String> heicExtensionsSet = <String>{'heic', 'heif'};
  static const String heicConversionFailedMessage =
      'Could not open this HEIC image. Please convert it to JPG/PNG or try another photo.';
  static const String heicTempSuffix = '_heic_converted';
  static const String heicConvertedOutputExtension = 'png';
  static const String heicFallbackConverterCommand = 'magick';
  static const List<String> heicFallbackConverterOptions = <String>[
    '-auto-orient',
  ];
  static const String openErrorMessage =
      'Could not open this image. Please choose a JPG, PNG, WEBP, or HEIC/HEIF file.';
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
  static const String dimensionLabelDialogTitle = 'Dimension Label';
  static const String dimensionLabelHint = 'Example: 72" or 6\'-0"';
  static const String dimensionLabelSaveButton = 'Save';
  static const String dimensionLabelSkipButton = 'Skip';
  static const String exportNoPhotoMessage = 'Load a photo before exporting.';
  static const String exportSuccessMessage = 'Export complete.';
  static const String exportFailureMessage =
      'Could not export this image. Please try again.';
  static const String eraseNoSelectionMessage = 'Select a markup to erase.';
}

class ToolbarConstants {
  const ToolbarConstants._();

  static const String openPhoto = 'Open Photo';
  static const String dimension = 'Dimension';
  static const String arrow = 'Arrow';
  static const String circle = 'Circle';
  static const String rectangle = 'Rectangle';
  static const String freehand = 'Freehand';
  static const String erase = 'Erase';
  static const String undo = 'Undo';
  static const String export = 'Export';
  static const List<String> labels = <String>[
    openPhoto,
    dimension,
    arrow,
    circle,
    rectangle,
    freehand,
    'Text',
    erase,
    undo,
    'Save',
    export,
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
  static const double splashVersionTopGap = 6;
  static const double splashVersionFontSize = 14;
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
  static const double dimensionLabelFontSize = 15;
  static const double dimensionLabelVerticalPadding = 6;
  static const double dimensionLabelHorizontalPadding = 10;
  static const double dimensionLabelBorderRadius = 8;
  static const double dimensionLabelOffsetFromLine = 14;
  static const double dimensionLabelClampPadding = 4;
  static const double dimensionLabelDialogFieldMinHeight = 64;
  static const double dimensionLabelDialogFieldPadding = 12;
  static const double dimensionLabelDialogButtonTopGap = 8;
}

class DimensionLineConstants {
  const DimensionLineConstants._();

  static const Color lineColor = Color(0xFF005C85);
  static const Color selectedLineColor = AppThemeConstants.ncdBlue;
  static const double strokeWidth = 3;
  static const double selectedStrokeMultiplier = 1.4;
  static const double endpointStrokeWidth = 1.2;
  static const Color endpointFillColor = Colors.white;
  static const Color labelTextColor = Colors.black87;
  static const Color labelBackgroundColor = Color(0xD9FFFFFF);
  static const Color labelBorderColor = Color(0xFF005C85);
  static const double labelBorderWidth = 1;
  static const double selectionTapDistance = 26;
  static const double tapMoveThreshold = 8;
}

class ArrowMarkupConstants {
  const ArrowMarkupConstants._();

  static const Color lineColor = Color(0xFF006B3F);
  static const Color selectedLineColor = Color(0xFF009A5F);
  static const double strokeWidth = 3.2;
  static const double selectedStrokeMultiplier = 1.35;
  static const double arrowHeadLength = 16;
  static const double arrowHeadAngleDegrees = 28;
  static const double minLength = 8;
}

class RectangleMarkupConstants {
  const RectangleMarkupConstants._();

  static const Color outlineColor = Color(0xFF7A4B00);
  static const Color selectedOutlineColor = Color(0xFFA46600);
  static const Color fillColor = Color(0x1FBD8A2A);
  static const double strokeWidth = 3;
  static const double selectedStrokeMultiplier = 1.35;
  static const double minSideLength = 8;
  static const double selectionHitDistance = 26;
}

class OvalMarkupConstants {
  const OvalMarkupConstants._();

  static const Color outlineColor = Color(0xFF8B1E00);
  static const Color selectedOutlineColor = Color(0xFFC02A00);
  static const Color fillColor = Color(0x1FD4572A);
  static const double strokeWidth = 3;
  static const double selectedStrokeMultiplier = 1.35;
  static const double minAxisLength = 8;
  static const double selectionHitDistance = 26;
}

class FreehandMarkupConstants {
  const FreehandMarkupConstants._();

  static const Color strokeColor = Color(0xFF5A2099);
  static const Color selectedStrokeColor = Color(0xFF7B2FD6);
  static const double strokeWidth = 3.2;
  static const double selectedStrokeMultiplier = 1.35;
  static const double pointMinDistance = 4;
  static const double selectionHitDistance = 24;
  static const int minimumPointCount = 2;
}

class ExportConstants {
  const ExportConstants._();

  static const String saveDialogConfirmButtonText = 'Export PNG';
  static const String saveTypeGroupLabel = 'PNG Image';
  static const String outputExtension = 'png';
  static const String defaultFileSuffix = '_marked';
  static const double maxPixelRatio = 3.0;

  static const XTypeGroup pngSaveTypeGroup = XTypeGroup(
    label: saveTypeGroupLabel,
    extensions: <String>[outputExtension],
  );
}
