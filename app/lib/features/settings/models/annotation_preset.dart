import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';

/// A saved way of marking something up, applied in one tap.
///
/// Holds the tool, the colour and the label typography. It does not hold a
/// stroke width, because the app has no stroke-width setting to hold; when one
/// exists this is where it goes.
///
/// A preset only decides what the next mark starts out as. Applying one never
/// touches a mark already on the photo.
class AnnotationPreset {
  const AnnotationPreset({
    required this.name,
    required this.tool,
    required this.stylePresetId,
    required this.fontFamily,
    required this.fontSize,
  });

  final String name;
  final MarkupTool tool;
  final MarkupStylePresetId stylePresetId;
  final String fontFamily;
  final double fontSize;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'tool': tool.name,
      'stylePresetId': stylePresetId.name,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
    };
  }

  /// Reads one preset, or null when it is not usable.
  ///
  /// A preset naming a tool or a colour this build does not have is dropped
  /// rather than repaired into something the user did not ask for.
  static AnnotationPreset? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    final Object? rawName = raw['name'];
    if (rawName is! String || rawName.trim().isEmpty) {
      return null;
    }
    final MarkupTool? tool = _toolFrom(raw['tool']);
    final MarkupStylePresetId? style = _styleFrom(raw['stylePresetId']);
    if (tool == null || style == null) {
      return null;
    }
    final Object? rawSize = raw['fontSize'];
    final double size = rawSize is num
        ? rawSize.toDouble()
        : MarkupTypographyConstants.defaultFontSize;
    if (size < MarkupTypographyConstants.minFontSize ||
        size > MarkupTypographyConstants.maxFontSize) {
      return null;
    }
    final Object? rawFamily = raw['fontFamily'];
    return AnnotationPreset(
      name: rawName.trim(),
      tool: tool,
      stylePresetId: style,
      fontFamily: rawFamily is String && rawFamily.trim().isNotEmpty
          ? rawFamily
          : MarkupTypographyConstants.defaultFontFamily,
      fontSize: size,
    );
  }

  static List<AnnotationPreset> listFromJson(Object? raw) {
    if (raw is! List) {
      return AnnotationPresetConstants.builtIns;
    }
    final List<AnnotationPreset> presets = <AnnotationPreset>[];
    for (final Object? entry in raw) {
      final AnnotationPreset? preset = fromJson(entry);
      if (preset != null && presets.length < AnnotationPresetConstants.maximum) {
        presets.add(preset);
      }
    }
    // An empty list is a deliberate state: the user deleted them all.
    return presets;
  }

  static MarkupTool? _toolFrom(Object? raw) {
    for (final MarkupTool tool in MarkupTool.values) {
      if (tool.name == raw) {
        return tool;
      }
    }
    return null;
  }

  static MarkupStylePresetId? _styleFrom(Object? raw) {
    for (final MarkupStylePresetId id in MarkupStylePresetId.values) {
      if (id.name == raw) {
        return id;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    return other is AnnotationPreset &&
        other.name == name &&
        other.tool == tool &&
        other.stylePresetId == stylePresetId &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize;
  }

  @override
  int get hashCode =>
      Object.hash(name, tool, stylePresetId, fontFamily, fontSize);
}
