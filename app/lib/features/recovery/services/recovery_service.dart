import 'dart:convert';
import 'dart:io';

import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/editable_markup_document.dart';

/// An autosaved document found on launch, with enough detail to ask the user
/// about it without opening it first.
class RecoverableDraft {
  const RecoverableDraft({
    required this.document,
    required this.sourceImagePath,
    required this.sourceImageFileName,
    required this.markCount,
    required this.savedAtUtc,
  });

  final EditableMarkupDocument document;
  final String sourceImagePath;
  final String sourceImageFileName;
  final int markCount;
  final DateTime savedAtUtc;
}

/// Keeps a rolling copy of the markup in progress so a crash, a power cut or a
/// process kill does not cost the work.
///
/// The source photo is never touched. Everything here writes and reads one
/// sidecar file in the app's own folder, in exactly the same JSON format as a
/// markup file the user saves themselves, so recovery is just an open.
///
/// Deliberately built on `dart:io` rather than adding a package. Every failure
/// path is swallowed: an exception on a background timer that took down the
/// app the user is drawing in would be worse than a lost autosave.
class RecoveryService {
  RecoveryService({String? overrideDirectory, Map<String, String>? environment})
    : _overrideDirectory = overrideDirectory,
      _environment = environment ?? Platform.environment;

  final String? _overrideDirectory;
  final Map<String, String> _environment;

  /// Where the recovery file lives.
  ///
  /// The same folder the settings file uses. Windows puts it under APPDATA;
  /// anything else falls back through the XDG config directory, the home
  /// directory, and finally the system temp directory, so there is always
  /// somewhere to write.
  String resolveDirectory() {
    final String? override = _overrideDirectory;
    if (override != null && override.trim().isNotEmpty) {
      return override;
    }
    for (final String key in SettingsConstants.directoryEnvironmentKeys) {
      final String? value = _environment[key];
      if (value != null && value.trim().isNotEmpty) {
        return '${value.trim()}${Platform.pathSeparator}'
            '${SettingsConstants.directoryName}';
      }
    }
    return '${Directory.systemTemp.path}${Platform.pathSeparator}'
        '${SettingsConstants.directoryName}';
  }

  String get recoveryFilePath =>
      '${resolveDirectory()}${Platform.pathSeparator}'
      '${RecoveryConstants.fileName}';

  String get _partialPath =>
      '$recoveryFilePath${RecoveryConstants.partialSuffix}';

  /// Writes the current markup over the previous autosave.
  ///
  /// Written to a temporary name and renamed into place, so a power cut in the
  /// middle leaves the previous good autosave rather than a half-written file
  /// that cannot be parsed. Returns whether anything was written.
  Future<bool> saveDraft(EditableMarkupDocument document) async {
    if (document.sourceImagePath.trim().isEmpty) {
      // Nothing worth recovering without a photo to put it back on.
      return false;
    }
    try {
      await Directory(resolveDirectory()).create(recursive: true);
      final File temporaryFile = File(_partialPath);
      await temporaryFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(document.toJson()),
        flush: true,
      );
      await temporaryFile.rename(recoveryFilePath);
      return true;
    } on Object {
      return false;
    }
  }

  /// Removes the autosave and any half-written temporary file.
  ///
  /// Called when the work has been saved or exported, which is the moment the
  /// autosave stops representing anything that could be lost.
  Future<void> clearDraft() async {
    for (final String path in <String>[recoveryFilePath, _partialPath]) {
      try {
        final File file = File(path);
        if (file.existsSync()) {
          await file.delete();
        }
      } on Object {
        // A recovery file that will not delete is offered again next launch,
        // where the user can decline it. Not worth failing anything over.
      }
    }
  }

  /// Returns a draft only when it is worth interrupting someone for.
  ///
  /// It has to parse, name a source image that still exists on disk, carry at
  /// least one mark, and be recent enough to still be the work the user
  /// remembers. Anything else is deleted where it sits rather than left to
  /// prompt again on every launch forever.
  Future<RecoverableDraft?> loadDraft() async {
    final File file = File(recoveryFilePath);
    try {
      if (!file.existsSync()) {
        return null;
      }
      final EditableMarkupDocument document = EditableMarkupDocument.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, dynamic>,
      );

      final String sourcePath = document.sourceImagePath.trim();
      if (sourcePath.isEmpty || !File(sourcePath).existsSync()) {
        // The photo is gone, so there is nothing to put the marks back onto.
        await clearDraft();
        return null;
      }

      final int markCount = _markCount(document);
      if (markCount == 0) {
        await clearDraft();
        return null;
      }

      final DateTime savedAt = _parseSavedAt(document.savedAtUtc);
      final Duration age = DateTime.now().toUtc().difference(savedAt);
      if (age > RecoveryConstants.maximumAge) {
        // Old enough that offering it would be confusing rather than helpful.
        await clearDraft();
        return null;
      }

      return RecoverableDraft(
        document: document,
        sourceImagePath: sourcePath,
        sourceImageFileName: document.sourceImageFileName,
        markCount: markCount,
        savedAtUtc: savedAt,
      );
    } on Object {
      // A recovery file that will not parse is worse than none, because it
      // prompts on every launch and never works. Delete it and move on.
      await clearDraft();
      return null;
    }
  }

  static int _markCount(EditableMarkupDocument document) {
    return document.dimensionLines.length +
        document.arrows.length +
        document.rectangles.length +
        document.ovals.length +
        document.freehands.length +
        document.textNotes.length +
        document.multiSegmentMeasurements.length +
        document.areaMeasurements.length +
        (document.scaleCalibration == null ? 0 : 1);
  }

  static DateTime _parseSavedAt(String raw) {
    return DateTime.tryParse(raw)?.toUtc() ?? DateTime.now().toUtc();
  }
}
