import 'dart:convert';
import 'dart:io';

import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/editable_markup_document.dart';
import 'package:ncd_photo_markup/features/session/models/session_preferences.dart';
import 'package:ncd_photo_markup/features/session/services/app_data_directory.dart';

/// An autosaved draft found on launch.
class RecoverableDraft {
  const RecoverableDraft({
    required this.document,
    required this.sourceImagePath,
    required this.savedAtUtc,
  });

  final EditableMarkupDocument document;
  final String sourceImagePath;
  final DateTime? savedAtUtc;
}

/// Remembers tool settings between runs and keeps a rolling autosave of
/// in-progress markup.
///
/// Every method here swallows its own errors. Losing preferences or an
/// autosave is a nuisance; an exception on a background timer that takes down
/// the markup screen is not acceptable.
class SessionStateService {
  SessionStateService({AppDataDirectory? directory})
    : _directory = directory ?? const AppDataDirectory();

  /// A service pointed at a throwaway folder, for tests.
  factory SessionStateService.inMemoryFolder(String folderPath) {
    return SessionStateService(
      directory: AppDataDirectory(
        environment: const <String, String>{},
        fallbackPath: folderPath,
      ),
    );
  }

  final AppDataDirectory _directory;

  String get _preferencesPath =>
      '${_directory.resolvePath()}${Platform.pathSeparator}'
      '${SessionStateConstants.preferencesFileName}';

  String get _draftPath =>
      '${_directory.resolvePath()}${Platform.pathSeparator}'
      '${SessionStateConstants.draftFileName}';

  Future<SessionPreferences> loadPreferences() async {
    try {
      final File file = File(_preferencesPath);
      if (!await file.exists()) {
        return SessionPreferences.defaults;
      }
      final dynamic decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return SessionPreferences.defaults;
      }
      return SessionPreferences.fromJson(decoded);
    } catch (_) {
      return SessionPreferences.defaults;
    }
  }

  Future<bool> savePreferences(SessionPreferences preferences) async {
    try {
      if (await _directory.ensure() == null) {
        return false;
      }
      await File(
        _preferencesPath,
      ).writeAsString(jsonEncode(preferences.toJson()), flush: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Writes the in-progress markup so a crash, a battery death or a closed lid
  /// does not cost the work.
  ///
  /// Written to a temporary name and then renamed, so a process that dies
  /// halfway through leaves the previous good draft in place rather than a
  /// half-written file.
  Future<bool> saveDraft(EditableMarkupDocument document) async {
    try {
      if (document.sourceImagePath.trim().isEmpty) {
        return false;
      }
      if (await _directory.ensure() == null) {
        return false;
      }
      final String temporaryPath =
          '$_draftPath${SessionStateConstants.partialSuffix}';
      final File temporaryFile = File(temporaryPath);
      await temporaryFile.writeAsString(
        jsonEncode(document.toJson()),
        flush: true,
      );
      await temporaryFile.rename(_draftPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearDraft() async {
    try {
      final File file = File(_draftPath);
      if (await file.exists()) {
        await file.delete();
      }
      final File partial = File(
        '$_draftPath${SessionStateConstants.partialSuffix}',
      );
      if (await partial.exists()) {
        await partial.delete();
      }
    } catch (_) {
      // Nothing to do; a stale draft is offered again next launch and can be
      // dismissed.
    }
  }

  /// Returns a draft only when it is worth offering: it parses, it names a
  /// source photo that is still on disk, and it actually contains markup.
  Future<RecoverableDraft?> loadDraft() async {
    try {
      final File file = File(_draftPath);
      if (!await file.exists()) {
        return null;
      }
      final dynamic decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final EditableMarkupDocument document = EditableMarkupDocument.fromJson(
        decoded,
      );
      final String sourcePath = document.sourceImagePath.trim();
      if (sourcePath.isEmpty || !File(sourcePath).existsSync()) {
        return null;
      }
      if (!documentHasMarkup(document)) {
        return null;
      }
      return RecoverableDraft(
        document: document,
        sourceImagePath: sourcePath,
        savedAtUtc: DateTime.tryParse(document.savedAtUtc),
      );
    } catch (_) {
      return null;
    }
  }

  static bool documentHasMarkup(EditableMarkupDocument document) {
    return document.dimensionLines.isNotEmpty ||
        document.arrows.isNotEmpty ||
        document.rectangles.isNotEmpty ||
        document.ovals.isNotEmpty ||
        document.freehands.isNotEmpty ||
        document.textNotes.isNotEmpty ||
        document.callouts.isNotEmpty ||
        document.blurs.isNotEmpty;
  }
}
