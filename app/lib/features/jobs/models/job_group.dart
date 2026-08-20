import 'package:ncd_photo_markup/features/integration/models/photo_markup_launch_context.dart';

/// What makes two photos part of the same job.
///
/// Control Center is the authority when it is involved: a project code is a
/// real identifier that someone typed once and means the same thing every
/// time. Failing that, a client name is a weaker but still deliberate answer.
/// Failing both, photos are grouped by the folder they live in, which is how
/// people already organise job photos without being asked to.
///
/// Nothing here guesses beyond that. Two photos in unrelated folders with no
/// Control Center context are two jobs, not one, because merging jobs that are
/// not the same job is worse than leaving them apart.
class JobKey {
  const JobKey({required this.kind, required this.value});

  final JobKeyKind kind;
  final String value;

  /// Derives the key for a photo, from what the app was told and where the
  /// photo is. Returns null when there is not enough to group on at all.
  static JobKey? forPhoto({
    PhotoMarkupLaunchContext? launchContext,
    String? sourceImagePath,
  }) {
    final String project = launchContext?.projectCode?.trim() ?? '';
    if (project.isNotEmpty) {
      return JobKey(kind: JobKeyKind.projectCode, value: project);
    }
    final String client = launchContext?.clientName?.trim() ?? '';
    if (client.isNotEmpty) {
      return JobKey(kind: JobKeyKind.clientName, value: client);
    }
    final String folder = _parentFolder(sourceImagePath?.trim() ?? '');
    if (folder.isNotEmpty) {
      return JobKey(kind: JobKeyKind.folder, value: folder);
    }
    return null;
  }

  static String _parentFolder(String path) {
    if (path.isEmpty) {
      return '';
    }
    final int lastSlash = path.lastIndexOf(RegExp(r'[/\\]'));
    return lastSlash <= 0 ? '' : path.substring(0, lastSlash);
  }

  String get storageId => '${kind.name}:$value';

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'kind': kind.name, 'value': value};

  static JobKey? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    final Object? value = raw['value'];
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    for (final JobKeyKind kind in JobKeyKind.values) {
      if (kind.name == raw['kind']) {
        return JobKey(kind: kind, value: value);
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is JobKey && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);
}

/// How a job was identified, kept so the app can say why two photos are
/// grouped rather than presenting the grouping as a fact from nowhere.
enum JobKeyKind { projectCode, clientName, folder }

/// One photo inside a job, and what the app knows about the work on it.
///
/// Paths only. No pixels are copied anywhere, and the source photo is never
/// moved, renamed or written to by anything in this feature.
class JobPhoto {
  const JobPhoto({
    required this.sourceImagePath,
    required this.sourceImageFileName,
    required this.lastOpenedUtc,
    this.markCount = 0,
    this.markupFilePath,
    this.exportPath,
  });

  final String sourceImagePath;
  final String sourceImageFileName;
  final DateTime lastOpenedUtc;
  final int markCount;
  final String? markupFilePath;
  final String? exportPath;

  JobPhoto mergedWith(JobPhoto newer) {
    return JobPhoto(
      sourceImagePath: newer.sourceImagePath,
      sourceImageFileName: newer.sourceImageFileName,
      lastOpenedUtc: newer.lastOpenedUtc.isAfter(lastOpenedUtc)
          ? newer.lastOpenedUtc
          : lastOpenedUtc,
      markCount: newer.markCount,
      // A path already known is not forgotten just because this time round the
      // app has not been told it again.
      markupFilePath: newer.markupFilePath ?? markupFilePath,
      exportPath: newer.exportPath ?? exportPath,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'sourceImagePath': sourceImagePath,
    'sourceImageFileName': sourceImageFileName,
    'lastOpenedUtc': lastOpenedUtc.toUtc().toIso8601String(),
    'markCount': markCount,
    if (markupFilePath != null) 'markupFilePath': markupFilePath,
    if (exportPath != null) 'exportPath': exportPath,
  };

  static JobPhoto? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    final Object? path = raw['sourceImagePath'];
    if (path is! String || path.trim().isEmpty) {
      return null;
    }
    final Object? name = raw['sourceImageFileName'];
    final Object? opened = raw['lastOpenedUtc'];
    final Object? count = raw['markCount'];
    return JobPhoto(
      sourceImagePath: path,
      sourceImageFileName: name is String && name.trim().isNotEmpty
          ? name
          : _fileName(path),
      lastOpenedUtc:
          (opened is String ? DateTime.tryParse(opened)?.toUtc() : null) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      markCount: count is num && count >= 0 ? count.round() : 0,
      markupFilePath: _optionalString(raw['markupFilePath']),
      exportPath: _optionalString(raw['exportPath']),
    );
  }

  static String _fileName(String path) {
    final int lastSlash = path.lastIndexOf(RegExp(r'[/\\]'));
    return lastSlash < 0 ? path : path.substring(lastSlash + 1);
  }

  static String? _optionalString(Object? raw) {
    if (raw is! String) {
      return null;
    }
    final String trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  bool operator ==(Object other) =>
      other is JobPhoto &&
      other.sourceImagePath == sourceImagePath &&
      other.sourceImageFileName == sourceImageFileName &&
      other.lastOpenedUtc == lastOpenedUtc &&
      other.markCount == markCount &&
      other.markupFilePath == markupFilePath &&
      other.exportPath == exportPath;

  @override
  int get hashCode => Object.hash(
    sourceImagePath,
    sourceImageFileName,
    lastOpenedUtc,
    markCount,
    markupFilePath,
    exportPath,
  );
}

/// A job: the way it was identified, what it is called, and its photos.
class JobGroup {
  const JobGroup({
    required this.key,
    required this.photos,
    this.clientName,
    this.projectCode,
  });

  final JobKey key;
  final List<JobPhoto> photos;
  final String? clientName;
  final String? projectCode;

  /// What to call this job on screen. The project code if there is one, then
  /// the client, then the folder name. Never a made-up label.
  String get displayName {
    final String project = projectCode?.trim() ?? '';
    final String client = clientName?.trim() ?? '';
    if (project.isNotEmpty && client.isNotEmpty) {
      return '$client, $project';
    }
    if (project.isNotEmpty) {
      return project;
    }
    if (client.isNotEmpty) {
      return client;
    }
    return _lastPathSegment(key.value);
  }

  /// Most recently opened first, which is the order someone actually wants.
  List<JobPhoto> get photosByRecency {
    final List<JobPhoto> sorted = <JobPhoto>[...photos]
      ..sort(
        (JobPhoto a, JobPhoto b) => b.lastOpenedUtc.compareTo(a.lastOpenedUtc),
      );
    return List<JobPhoto>.unmodifiable(sorted);
  }

  DateTime get lastOpenedUtc {
    DateTime latest = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    for (final JobPhoto photo in photos) {
      if (photo.lastOpenedUtc.isAfter(latest)) {
        latest = photo.lastOpenedUtc;
      }
    }
    return latest;
  }

  JobGroup withPhoto(JobPhoto photo) {
    final List<JobPhoto> next = <JobPhoto>[...photos];
    final int existing = next.indexWhere(
      (JobPhoto item) => item.sourceImagePath == photo.sourceImagePath,
    );
    if (existing >= 0) {
      next[existing] = next[existing].mergedWith(photo);
    } else {
      next.add(photo);
    }
    // A name learned once is kept. Opening a photo from the same folder
    // without Control Center should not erase the client it belongs to; only
    // withNames can change a name, and only to a non-empty one.
    return JobGroup(
      key: key,
      photos: next,
      clientName: clientName,
      projectCode: projectCode,
    );
  }

  JobGroup withNames({String? clientName, String? projectCode}) {
    final String client = clientName?.trim() ?? '';
    final String project = projectCode?.trim() ?? '';
    return JobGroup(
      key: key,
      photos: photos,
      clientName: client.isEmpty ? this.clientName : client,
      projectCode: project.isEmpty ? this.projectCode : project,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'key': key.toJson(),
    if (clientName != null) 'clientName': clientName,
    if (projectCode != null) 'projectCode': projectCode,
    'photos': photos.map((JobPhoto photo) => photo.toJson()).toList(
      growable: false,
    ),
  };

  static JobGroup? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    final JobKey? key = JobKey.fromJson(raw['key']);
    if (key == null) {
      return null;
    }
    final Object? rawPhotos = raw['photos'];
    final List<JobPhoto> photos = <JobPhoto>[];
    if (rawPhotos is List) {
      for (final Object? entry in rawPhotos) {
        final JobPhoto? photo = JobPhoto.fromJson(entry);
        if (photo != null) {
          photos.add(photo);
        }
      }
    }
    if (photos.isEmpty) {
      // A job with no photos in it is not a job.
      return null;
    }
    return JobGroup(
      key: key,
      photos: photos,
      clientName: JobPhoto._optionalString(raw['clientName']),
      projectCode: JobPhoto._optionalString(raw['projectCode']),
    );
  }

  static String _lastPathSegment(String path) {
    final int lastSlash = path.lastIndexOf(RegExp(r'[/\\]'));
    return lastSlash < 0 || lastSlash == path.length - 1
        ? path
        : path.substring(lastSlash + 1);
  }
}
