import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class AppConstants {
  const AppConstants._();

  static const String appName = 'NCD Photo Markup';
  static const String appVersion = 'v0.3';
  static const String startupImageEnvKey = 'NCD_STARTUP_IMAGE_PATH';
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
}

class ToolbarConstants {
  const ToolbarConstants._();

  static const String openPhoto = 'Open Photo';
  static const List<String> labels = <String>[
    openPhoto,
    'Dimension',
    'Arrow',
    'Circle',
    'Rectangle',
    'Freehand',
    'Text',
    'Erase',
    'Undo',
    'Save',
    'Export',
  ];
}

class UiLayoutConstants {
  const UiLayoutConstants._();

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
}
