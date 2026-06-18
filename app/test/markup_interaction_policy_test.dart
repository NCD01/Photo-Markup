import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_interaction_policy.dart';

void main() {
  group('MarkupInteractionPolicy', () {
    test('selection taps are limited to select mode', () {
      expect(
        MarkupInteractionPolicy.allowsTapSelection(MarkupTool.none),
        isTrue,
      );
      expect(
        MarkupInteractionPolicy.allowsTapSelection(MarkupTool.dimension),
        isFalse,
      );
      expect(
        MarkupInteractionPolicy.allowsTapSelection(MarkupTool.textNote),
        isFalse,
      );
    });

    test('selecting the active tool toggles back to select mode', () {
      expect(
        MarkupInteractionPolicy.resolveRequestedTool(
          currentTool: MarkupTool.dimension,
          requestedTool: MarkupTool.dimension,
        ),
        MarkupTool.none,
      );
      expect(
        MarkupInteractionPolicy.resolveRequestedTool(
          currentTool: MarkupTool.none,
          requestedTool: MarkupTool.rectangle,
        ),
        MarkupTool.rectangle,
      );
    });
  });
}
