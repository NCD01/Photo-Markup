import 'package:flutter/material.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/settings/models/app_settings.dart';

/// The Settings sheet.
///
/// Built from the same AlertDialog the rest of the app uses, so it does not
/// introduce a second visual language. Every control carries a plain-English
/// line under it: the person reading it is a contractor, not a developer.
///
/// Edits are reported upward as they happen via [onChanged], so a setting takes
/// effect immediately and there is no Save button to forget to press.
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.appVersion,
    this.onChooseExportFolder,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;
  final String appVersion;

  /// Returns a chosen folder, or null if the user backed out.
  final Future<String?> Function()? onChooseExportFolder;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late AppSettings _settings;
  late final TextEditingController _suffixController;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _suffixController = TextEditingController(
      text: _settings.exportFileSuffix,
    );
  }

  @override
  void dispose() {
    _suffixController.dispose();
    super.dispose();
  }

  void _apply(AppSettings next) {
    setState(() => _settings = next);
    widget.onChanged(next);
  }

  void _applyAndSyncControllers(AppSettings next) {
    _suffixController.text = next.exportFileSuffix;
    _apply(next);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(SettingsConstants.dialogTitle),
      content: SizedBox(
        width: UiLayoutConstants.settingsDialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _section(
                title: SettingsConstants.measurementSectionTitle,
                onReset: () =>
                    _applyAndSyncControllers(_settings.resetMeasurementGroup()),
                children: <Widget>[
                  _setting(
                    label: SettingsConstants.displayModeLabel,
                    description: SettingsConstants.displayModeDescription,
                    control: SegmentedButton<MeasurementDisplayMode>(
                      key: const ValueKey<String>('settings-display-mode'),
                      segments: const <ButtonSegment<MeasurementDisplayMode>>[
                        ButtonSegment<MeasurementDisplayMode>(
                          value: MeasurementDisplayMode.tape,
                          label: Text(SettingsConstants.displayModeTapeOption),
                        ),
                        ButtonSegment<MeasurementDisplayMode>(
                          value: MeasurementDisplayMode.decimal,
                          label: Text(
                            SettingsConstants.displayModeDecimalOption,
                          ),
                        ),
                      ],
                      selected: <MeasurementDisplayMode>{
                        _settings.measurementDisplayMode,
                      },
                      onSelectionChanged:
                          (Set<MeasurementDisplayMode> selection) => _apply(
                            _settings.copyWith(
                              measurementDisplayMode: selection.first,
                            ),
                          ),
                    ),
                  ),
                  _setting(
                    label: SettingsConstants.unitSystemLabel,
                    description: SettingsConstants.unitSystemDescription,
                    control: SegmentedButton<MeasurementUnitSystem>(
                      key: const ValueKey<String>('settings-unit-system'),
                      segments: const <ButtonSegment<MeasurementUnitSystem>>[
                        ButtonSegment<MeasurementUnitSystem>(
                          value: MeasurementUnitSystem.auto,
                          label: Text(SettingsConstants.unitSystemAutoOption),
                        ),
                        ButtonSegment<MeasurementUnitSystem>(
                          value: MeasurementUnitSystem.imperial,
                          label: Text(
                            SettingsConstants.unitSystemImperialOption,
                          ),
                        ),
                        ButtonSegment<MeasurementUnitSystem>(
                          value: MeasurementUnitSystem.metric,
                          label: Text(SettingsConstants.unitSystemMetricOption),
                        ),
                      ],
                      selected: <MeasurementUnitSystem>{
                        _settings.measurementUnitSystem,
                      },
                      onSelectionChanged:
                          (Set<MeasurementUnitSystem> selection) => _apply(
                            _settings.copyWith(
                              measurementUnitSystem: selection.first,
                            ),
                          ),
                    ),
                  ),
                  _setting(
                    label: SettingsConstants.autoLabelLabel,
                    description: SettingsConstants.autoLabelDescription,
                    control: Align(
                      alignment: Alignment.centerLeft,
                      child: Switch(
                        key: const ValueKey<String>('settings-auto-label'),
                        value: _settings.autoLabelDimensions,
                        onChanged: (bool value) => _apply(
                          _settings.copyWith(autoLabelDimensions: value),
                        ),
                      ),
                    ),
                  ),
                  _setting(
                    label: SettingsConstants.autosaveIntervalLabel,
                    description:
                        SettingsConstants.autosaveIntervalDescription,
                    control: Row(
                      children: <Widget>[
                        Expanded(
                          child: Slider(
                            key: const ValueKey<String>(
                              'settings-autosave-interval',
                            ),
                            min: RecoveryConstants.minimumIntervalSeconds
                                .toDouble(),
                            max: RecoveryConstants.maximumIntervalSeconds
                                .toDouble(),
                            divisions:
                                (RecoveryConstants.maximumIntervalSeconds -
                                    RecoveryConstants.minimumIntervalSeconds) ~/
                                RecoveryConstants.intervalStepSeconds,
                            value: _settings.autosaveIntervalSeconds
                                .toDouble()
                                .clamp(
                                  RecoveryConstants.minimumIntervalSeconds
                                      .toDouble(),
                                  RecoveryConstants.maximumIntervalSeconds
                                      .toDouble(),
                                ),
                            label:
                                '${_settings.autosaveIntervalSeconds} '
                                '${SettingsConstants.autosaveIntervalSuffix}',
                            onChanged: (double value) => _apply(
                              _settings.copyWith(
                                autosaveIntervalSeconds: value.round(),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${_settings.autosaveIntervalSeconds} '
                          '${SettingsConstants.autosaveIntervalSuffix}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _section(
                title: SettingsConstants.defaultsSectionTitle,
                onReset: () =>
                    _applyAndSyncControllers(_settings.resetDefaultsGroup()),
                children: <Widget>[
                  _setting(
                    label: SettingsConstants.defaultColourLabel,
                    description: SettingsConstants.defaultColourDescription,
                    control: Wrap(
                      spacing: UiLayoutConstants.settingsChipSpacing,
                      children: MarkupStylePresets.all
                          .map(
                            (MarkupStylePreset preset) => ChoiceChip(
                              key: ValueKey<String>(
                                'settings-colour-${preset.id.name}',
                              ),
                              label: Text(preset.label),
                              selected:
                                  _settings.defaultStylePresetId == preset.id,
                              onSelected: (_) => _apply(
                                _settings.copyWith(
                                  defaultStylePresetId: preset.id,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _setting(
                    label: SettingsConstants.defaultFontSizeLabel,
                    description: SettingsConstants.defaultFontSizeDescription,
                    control: Row(
                      children: <Widget>[
                        Expanded(
                          child: Slider(
                            key: const ValueKey<String>('settings-font-size'),
                            min: MarkupTypographyConstants.minFontSize,
                            max: MarkupTypographyConstants.maxFontSize,
                            value: _settings.defaultFontSize,
                            onChanged: (double value) => _apply(
                              _settings.copyWith(
                                defaultFontSize: value.roundToDouble(),
                              ),
                            ),
                          ),
                        ),
                        Text('${_settings.defaultFontSize.round()}'),
                      ],
                    ),
                  ),
                ],
              ),
              _section(
                title: SettingsConstants.exportSectionTitle,
                onReset: () =>
                    _applyAndSyncControllers(_settings.resetExportGroup()),
                children: <Widget>[
                  _setting(
                    label: SettingsConstants.exportSuffixLabel,
                    description: SettingsConstants.exportSuffixDescription,
                    control: TextField(
                      key: const ValueKey<String>('settings-export-suffix'),
                      controller: _suffixController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (String value) {
                        // An empty suffix would make the export collide with
                        // the source photo, so it is not accepted.
                        if (value.trim().isEmpty) {
                          return;
                        }
                        _apply(_settings.copyWith(exportFileSuffix: value));
                      },
                    ),
                  ),
                  _setting(
                    label: SettingsConstants.exportFolderLabel,
                    description: SettingsConstants.exportFolderDescription,
                    control: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _settings.defaultExportDirectory ??
                                SettingsConstants.exportFolderEmptyValue,
                            key: const ValueKey<String>(
                              'settings-export-folder-value',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.onChooseExportFolder != null)
                          TextButton(
                            onPressed: () async {
                              final String? chosen =
                                  await widget.onChooseExportFolder!();
                              if (chosen != null && chosen.trim().isNotEmpty) {
                                _apply(
                                  _settings.copyWith(
                                    defaultExportDirectory: chosen,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              SettingsConstants.exportFolderChooseButton,
                            ),
                          ),
                        if (_settings.defaultExportDirectory != null)
                          TextButton(
                            onPressed: () => _apply(
                              _settings.copyWith(
                                clearDefaultExportDirectory: true,
                              ),
                            ),
                            child: const Text(
                              SettingsConstants.exportFolderClearButton,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              _section(
                title: SettingsConstants.aboutSectionTitle,
                children: <Widget>[
                  _readOnlyRow(
                    SettingsConstants.aboutVersionLabel,
                    widget.appVersion,
                  ),
                  _readOnlyRow(
                    SettingsConstants.aboutChangelogLabel,
                    SettingsConstants.aboutChangelogValue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(SettingsConstants.closeButton),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required List<Widget> children,
    VoidCallback? onReset,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: UiLayoutConstants.settingsSectionGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: UiLayoutConstants.settingsSectionTitleSize,
                  ),
                ),
              ),
              // Per section, not one global reset, so restoring the export
              // defaults never quietly changes your colours.
              if (onReset != null)
                TextButton(
                  key: ValueKey<String>('settings-reset-$title'),
                  onPressed: onReset,
                  child: const Text(SettingsConstants.resetSectionButton),
                ),
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _setting({
    required String label,
    required String description,
    required Widget control,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: UiLayoutConstants.settingsItemGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: UiLayoutConstants.settingsLabelGap),
          control,
          const SizedBox(height: UiLayoutConstants.settingsLabelGap),
          Text(
            description,
            style: TextStyle(
              fontSize: UiLayoutConstants.settingsDescriptionSize,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: UiLayoutConstants.settingsLabelGap,
      ),
      child: Row(
        children: <Widget>[
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: UiLayoutConstants.settingsChipSpacing),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
