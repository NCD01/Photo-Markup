import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';

void main() {
  test('defines required markup style presets', () {
    final List<MarkupStylePresetId> ids = MarkupStylePresets.all
        .map((MarkupStylePreset preset) => preset.id)
        .toList(growable: false);

    expect(ids, contains(MarkupStylePresetId.ncdBlue));
    expect(ids, contains(MarkupStylePresetId.red));
    expect(ids, contains(MarkupStylePresetId.yellow));
    expect(ids, contains(MarkupStylePresetId.white));
    expect(ids, contains(MarkupStylePresetId.black));
  });

  test('default preset resolves to NCD Blue label', () {
    final MarkupStylePreset preset = MarkupStylePresets.byId(
      MarkupStylePresets.defaultPresetId,
    );

    expect(preset.id, MarkupStylePresetId.ncdBlue);
    expect(preset.label, 'NCD Blue');
  });
}
