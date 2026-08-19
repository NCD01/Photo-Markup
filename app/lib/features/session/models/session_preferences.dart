import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/callout_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_typography_utils.dart';

/// The handful of choices worth carrying from one photo, and one day, to the
/// next, so the common case needs no setting up.
class SessionPreferences {
  const SessionPreferences({
    this.tool = MarkupTool.arrow,
    this.stylePresetId = MarkupStylePresets.defaultPresetId,
    this.strokeWidthScale = MarkupStrokeConstants.defaultScale,
    this.shapesFilled = false,
    this.calloutLabelStyle = CalloutLabelStyle.numbers,
    this.fontFamily = MarkupTypographyConstants.defaultFontFamily,
    this.fontSize = MarkupTypographyConstants.defaultFontSize,
    this.sidebarExpanded = false,
    this.lastExportDirectory,
  });

  final MarkupTool tool;
  final MarkupStylePresetId stylePresetId;
  final double strokeWidthScale;
  final bool shapesFilled;
  final CalloutLabelStyle calloutLabelStyle;
  final String fontFamily;
  final double fontSize;
  final bool sidebarExpanded;
  final String? lastExportDirectory;

  static const SessionPreferences defaults = SessionPreferences();

  SessionPreferences copyWith({
    MarkupTool? tool,
    MarkupStylePresetId? stylePresetId,
    double? strokeWidthScale,
    bool? shapesFilled,
    CalloutLabelStyle? calloutLabelStyle,
    String? fontFamily,
    double? fontSize,
    bool? sidebarExpanded,
    String? lastExportDirectory,
  }) {
    return SessionPreferences(
      tool: tool ?? this.tool,
      stylePresetId: stylePresetId ?? this.stylePresetId,
      strokeWidthScale: strokeWidthScale ?? this.strokeWidthScale,
      shapesFilled: shapesFilled ?? this.shapesFilled,
      calloutLabelStyle: calloutLabelStyle ?? this.calloutLabelStyle,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      sidebarExpanded: sidebarExpanded ?? this.sidebarExpanded,
      lastExportDirectory: lastExportDirectory ?? this.lastExportDirectory,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schemaVersion': SessionStateConstants.schemaVersion,
      'tool': tool.name,
      'stylePresetId': stylePresetId.name,
      'strokeWidthScale': strokeWidthScale,
      'shapesFilled': shapesFilled,
      'calloutLabelStyle': calloutLabelStyle.name,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'sidebarExpanded': sidebarExpanded,
      if (lastExportDirectory != null)
        'lastExportDirectory': lastExportDirectory,
    };
  }

  /// Never throws. Anything unreadable falls back to the default, because a
  /// corrupt preferences file must not stop the app from opening.
  factory SessionPreferences.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return defaults;
    }
    return SessionPreferences(
      tool: _toolFromName(json['tool']),
      stylePresetId: _presetFromName(json['stylePresetId']),
      strokeWidthScale: MarkupStrokeConstants.normalizeScale(
        _asDouble(json['strokeWidthScale']),
      ),
      shapesFilled: json['shapesFilled'] == true,
      calloutLabelStyle: CalloutMarkup.labelStyleFromName(
        json['calloutLabelStyle']?.toString(),
      ),
      fontFamily: MarkupTypographyUtils.normalizeFontFamily(
        json['fontFamily']?.toString(),
      ),
      fontSize: MarkupTypographyUtils.normalizeFontSize(
        _asDouble(json['fontSize']),
      ),
      sidebarExpanded: json['sidebarExpanded'] == true,
      lastExportDirectory: _cleanString(json['lastExportDirectory']),
    );
  }

  /// Tools that should not be restored on launch.
  ///
  /// Blur and the shape tools are fine to come back to, but coming back into a
  /// tool that creates something on a single tap would turn a stray tap on the
  /// photo into an annotation before the user has decided anything.
  static const Set<MarkupTool> notRestorable = <MarkupTool>{
    MarkupTool.textNote,
    MarkupTool.callout,
  };

  static MarkupTool _toolFromName(dynamic value) {
    final String name = (value ?? '').toString();
    for (final MarkupTool tool in MarkupTool.values) {
      if (tool.name == name) {
        return notRestorable.contains(tool) ? MarkupTool.none : tool;
      }
    }
    return defaults.tool;
  }

  static MarkupStylePresetId _presetFromName(dynamic value) {
    final String name = (value ?? '').toString();
    for (final MarkupStylePresetId id in MarkupStylePresetId.values) {
      if (id.name == name) {
        return id;
      }
    }
    return MarkupStylePresets.defaultPresetId;
  }

  static double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static String? _cleanString(dynamic value) {
    final String text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }
}
