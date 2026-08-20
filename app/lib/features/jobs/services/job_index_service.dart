import 'dart:convert';
import 'dart:io';

import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/integration/models/photo_markup_launch_context.dart';
import 'package:ncd_photo_markup/features/jobs/models/job_group.dart';

/// Remembers which photos belong to which job.
///
/// An index of paths, nothing more. No photo is copied, moved, renamed or
/// written to, and deleting this file loses a convenience and not a single
/// piece of work.
///
/// Built on `dart:io` and stored beside the settings and recovery files, for
/// the same reason as those: no new dependency, and nothing written into the
/// customer's job folder.
class JobIndexService {
  JobIndexService({String? overrideDirectory, Map<String, String>? environment})
    : _overrideDirectory = overrideDirectory,
      _environment = environment ?? Platform.environment;

  final String? _overrideDirectory;
  final Map<String, String> _environment;

  /// The index, held in memory after the first read.
  ///
  /// Measured: without this, recording a photo re-read and re-parsed the whole
  /// file every time, so building a 40-job index of 50 photos each took longer
  /// than thirty seconds and never finished. It is O(n) work per record for no
  /// reason; the only writer of this file is the running app.
  List<JobGroup>? _cache;

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

  String get indexFilePath =>
      '${resolveDirectory()}${Platform.pathSeparator}'
      '${JobIndexConstants.fileName}';

  String get _partialPath => '$indexFilePath${JobIndexConstants.partialSuffix}';

  /// Every job, most recently opened first.
  ///
  /// A file that will not parse returns an empty list rather than throwing. A
  /// broken index is a lost convenience; it is never a reason to stop someone
  /// marking up a photo.
  Future<List<JobGroup>> load() async {
    final List<JobGroup>? cached = _cache;
    if (cached != null) {
      return cached;
    }
    final List<JobGroup> loaded = await _readFromDisk();
    _cache = loaded;
    return loaded;
  }

  Future<List<JobGroup>> _readFromDisk() async {
    try {
      final File file = File(indexFilePath);
      if (!file.existsSync()) {
        return const <JobGroup>[];
      }
      final Object? raw = jsonDecode(await file.readAsString());
      if (raw is! Map<String, dynamic>) {
        return const <JobGroup>[];
      }
      final Object? rawJobs = raw['jobs'];
      final List<JobGroup> jobs = <JobGroup>[];
      if (rawJobs is List) {
        for (final Object? entry in rawJobs) {
          final JobGroup? job = JobGroup.fromJson(entry);
          if (job != null) {
            jobs.add(job);
          }
        }
      }
      jobs.sort(
        (JobGroup a, JobGroup b) =>
            b.lastOpenedUtc.compareTo(a.lastOpenedUtc),
      );
      return List<JobGroup>.unmodifiable(jobs);
    } on Object {
      return const <JobGroup>[];
    }
  }

  /// Records that a photo was worked on, and returns the index as it now
  /// stands.
  ///
  /// The same photo opened twice updates its entry rather than adding a second
  /// one. A photo the app cannot place in any job is not recorded at all,
  /// because an unnamed bucket of unrelated photos helps nobody.
  Future<List<JobGroup>> recordPhoto({
    required String sourceImagePath,
    required String sourceImageFileName,
    required DateTime openedAtUtc,
    PhotoMarkupLaunchContext? launchContext,
    int markCount = 0,
    String? markupFilePath,
    String? exportPath,
  }) async {
    final JobKey? key = JobKey.forPhoto(
      launchContext: launchContext,
      sourceImagePath: sourceImagePath,
    );
    if (key == null || sourceImagePath.trim().isEmpty) {
      return load();
    }

    final List<JobGroup> jobs = <JobGroup>[...await load()];

    final JobPhoto photo = JobPhoto(
      sourceImagePath: sourceImagePath,
      sourceImageFileName: sourceImageFileName,
      lastOpenedUtc: openedAtUtc.toUtc(),
      markCount: markCount,
      markupFilePath: markupFilePath,
      exportPath: exportPath,
    );

    final int existing = jobs.indexWhere((JobGroup job) => job.key == key);
    if (existing >= 0) {
      jobs[existing] = jobs[existing]
          .withPhoto(photo)
          .withNames(
            clientName: launchContext?.clientName,
            projectCode: launchContext?.projectCode,
          );
    } else {
      jobs.add(
        JobGroup(
          key: key,
          photos: <JobPhoto>[photo],
          clientName: launchContext?.clientName?.trim().isEmpty ?? true
              ? null
              : launchContext!.clientName!.trim(),
          projectCode: launchContext?.projectCode?.trim().isEmpty ?? true
              ? null
              : launchContext!.projectCode!.trim(),
        ),
      );
    }

    _trim(jobs);
    jobs.sort(
      (JobGroup a, JobGroup b) => b.lastOpenedUtc.compareTo(a.lastOpenedUtc),
    );
    final List<JobGroup> result = List<JobGroup>.unmodifiable(jobs);
    _cache = result;
    await _write(jobs);
    return result;
  }

  /// Removes jobs whose photos are all gone from disk.
  ///
  /// Kept as a separate call rather than done on every load, because checking
  /// every path on a network share on every launch is slow and a stale entry
  /// is harmless until someone taps it.
  Future<List<JobGroup>> pruneMissingPhotos() async {
    final List<JobGroup> kept = <JobGroup>[];
    for (final JobGroup job in await load()) {
      final List<JobPhoto> photos = job.photos
          .where((JobPhoto photo) => File(photo.sourceImagePath).existsSync())
          .toList(growable: false);
      if (photos.isNotEmpty) {
        kept.add(
          JobGroup(
            key: job.key,
            photos: photos,
            clientName: job.clientName,
            projectCode: job.projectCode,
          ),
        );
      }
    }
    final List<JobGroup> result = List<JobGroup>.unmodifiable(kept);
    _cache = result;
    await _write(kept);
    return result;
  }

  Future<void> clear() async {
    _cache = const <JobGroup>[];
    for (final String path in <String>[indexFilePath, _partialPath]) {
      try {
        final File file = File(path);
        if (file.existsSync()) {
          await file.delete();
        }
      } on Object {
        // Nothing to do. A stale index is a convenience problem.
      }
    }
  }

  /// Keeps the index from growing without limit.
  ///
  /// Oldest jobs go first, and inside a job the oldest photos go first, so
  /// what survives is what someone touched most recently.
  void _trim(List<JobGroup> jobs) {
    for (int i = 0; i < jobs.length; i++) {
      final JobGroup job = jobs[i];
      if (job.photos.length > JobIndexConstants.maximumPhotosPerJob) {
        final List<JobPhoto> recent = job.photosByRecency
            .take(JobIndexConstants.maximumPhotosPerJob)
            .toList(growable: false);
        jobs[i] = JobGroup(
          key: job.key,
          photos: recent,
          clientName: job.clientName,
          projectCode: job.projectCode,
        );
      }
    }
    if (jobs.length > JobIndexConstants.maximumJobs) {
      jobs.sort(
        (JobGroup a, JobGroup b) => b.lastOpenedUtc.compareTo(a.lastOpenedUtc),
      );
      jobs.removeRange(JobIndexConstants.maximumJobs, jobs.length);
    }
  }

  Future<void> _write(List<JobGroup> jobs) async {
    try {
      await Directory(resolveDirectory()).create(recursive: true);
      final File temporaryFile = File(_partialPath);
      await temporaryFile.writeAsString(
        // Compact rather than indented. Nobody reads this file by hand, and
        // measured on a heavy document indenting costs half again as much time
        // and three times the bytes.
        jsonEncode(<String, dynamic>{
          'schemaVersion': JobIndexConstants.schemaVersion,
          'jobs': jobs.map((JobGroup job) => job.toJson()).toList(
            growable: false,
          ),
        }),
        flush: true,
      );
      await temporaryFile.rename(indexFilePath);
    } on Object {
      // Same rule as the autosave: never take the app down over an index.
    }
  }
}
