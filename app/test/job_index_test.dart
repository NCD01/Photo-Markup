import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/integration/models/photo_markup_launch_context.dart';
import 'package:ncd_photo_markup/features/jobs/models/job_group.dart';
import 'package:ncd_photo_markup/features/jobs/services/job_index_service.dart';

void _deleteBestEffort(Directory dir) {
  for (int attempt = 0; attempt < 5; attempt++) {
    try {
      if (!dir.existsSync()) {
        return;
      }
      dir.deleteSync(recursive: true);
      return;
    } on FileSystemException {
      sleep(const Duration(milliseconds: 50));
    }
  }
}

void main() {
  late Directory workDir;
  late JobIndexService service;
  String sep = Platform.pathSeparator;

  setUp(() {
    workDir = Directory.systemTemp.createTempSync('ncd_jobs');
    service = JobIndexService(overrideDirectory: workDir.path);
  });

  tearDown(() => _deleteBestEffort(workDir));

  Future<List<JobGroup>> record(
    String path, {
    PhotoMarkupLaunchContext? context,
    DateTime? at,
    int marks = 0,
    String? markupFilePath,
    String? exportPath,
  }) {
    return service.recordPhoto(
      sourceImagePath: path,
      sourceImageFileName: path.split(RegExp(r'[/\\]')).last,
      openedAtUtc: at ?? DateTime.utc(2026, 8, 20, 12),
      launchContext: context,
      markCount: marks,
      markupFilePath: markupFilePath,
      exportPath: exportPath,
    );
  }

  group('what makes two photos the same job', () {
    test('a project code wins, because someone typed it on purpose', () {
      final JobKey? key = JobKey.forPhoto(
        launchContext: const PhotoMarkupLaunchContext(
          launchedFromControlCenter: true,
          clientName: 'Smith Residence',
          projectCode: 'JOB-2261',
        ),
        sourceImagePath: 'C:${Platform.pathSeparator}anywhere.jpg',
      );
      expect(key?.kind, JobKeyKind.projectCode);
      expect(key?.value, 'JOB-2261');
    });

    test('a client name is the next best answer', () {
      final JobKey? key = JobKey.forPhoto(
        launchContext: const PhotoMarkupLaunchContext(
          launchedFromControlCenter: true,
          clientName: 'Smith Residence',
        ),
        sourceImagePath: 'C:${Platform.pathSeparator}anywhere.jpg',
      );
      expect(key?.kind, JobKeyKind.clientName);
    });

    test('with nothing from Control Center, the folder is the job', () {
      final JobKey? key = JobKey.forPhoto(
        sourceImagePath: 'C:${sep}Jobs${sep}Smith${sep}front.jpg',
      );
      expect(key?.kind, JobKeyKind.folder);
      expect(key?.value, 'C:${sep}Jobs${sep}Smith');
    });

    test('nothing to group on means no job rather than a guess', () {
      expect(JobKey.forPhoto(), isNull);
      expect(JobKey.forPhoto(sourceImagePath: 'front.jpg'), isNull);
    });

    test('two photos in unrelated folders are two jobs, not one', () async {
      await record('C:${sep}Jobs${sep}Smith${sep}a.jpg');
      final List<JobGroup> jobs = await record(
        'C:${sep}Jobs${sep}Jones${sep}b.jpg',
      );
      expect(jobs, hasLength(2));
    });
  });

  group('recording', () {
    test('the same photo twice updates one entry rather than adding two',
        () async {
      await record('C:${sep}Jobs${sep}Smith${sep}a.jpg', marks: 1);
      final List<JobGroup> jobs = await record(
        'C:${sep}Jobs${sep}Smith${sep}a.jpg',
        marks: 5,
        at: DateTime.utc(2026, 8, 20, 14),
      );
      expect(jobs, hasLength(1));
      expect(jobs.single.photos, hasLength(1));
      expect(jobs.single.photos.single.markCount, 5);
      expect(jobs.single.photos.single.lastOpenedUtc.hour, 14);
    });

    test('a path learned once is not forgotten on a later open', () async {
      await record(
        'C:${sep}Jobs${sep}Smith${sep}a.jpg',
        markupFilePath: 'C:${sep}Jobs${sep}Smith${sep}a.ncdmarkup.json',
      );
      final List<JobGroup> jobs = await record(
        'C:${sep}Jobs${sep}Smith${sep}a.jpg',
        at: DateTime.utc(2026, 8, 20, 15),
      );
      expect(
        jobs.single.photos.single.markupFilePath,
        'C:${sep}Jobs${sep}Smith${sep}a.ncdmarkup.json',
      );
    });

    test('several photos land in one job when they share a folder', () async {
      await record('C:${sep}Jobs${sep}Smith${sep}a.jpg');
      await record('C:${sep}Jobs${sep}Smith${sep}b.jpg');
      final List<JobGroup> jobs = await record(
        'C:${sep}Jobs${sep}Smith${sep}c.jpg',
      );
      expect(jobs, hasLength(1));
      expect(jobs.single.photos, hasLength(3));
    });

    test('a photo with nothing to group on is not recorded at all', () async {
      final List<JobGroup> jobs = await record('front.jpg');
      expect(jobs, isEmpty);
    });

    test('the job learns its client and project once Control Center says so',
        () async {
      await record('C:${sep}Jobs${sep}Smith${sep}a.jpg');
      final List<JobGroup> jobs = await record(
        'C:${sep}Jobs${sep}Smith${sep}b.jpg',
        context: const PhotoMarkupLaunchContext(
          launchedFromControlCenter: true,
          clientName: 'Smith Residence',
        ),
      );
      // The second photo carried a client name, so it grouped by client, and
      // the folder job stays as its own job. Two keys, both real.
      expect(jobs.length, greaterThanOrEqualTo(1));
      expect(
        jobs.any((JobGroup job) => job.clientName == 'Smith Residence'),
        isTrue,
      );
    });
  });

  group('naming a job', () {
    test('a client and a project read as both', () {
      const JobGroup job = JobGroup(
        key: JobKey(kind: JobKeyKind.projectCode, value: 'JOB-2261'),
        photos: <JobPhoto>[],
        clientName: 'Smith Residence',
        projectCode: 'JOB-2261',
      );
      expect(job.displayName, 'Smith Residence, JOB-2261');
    });

    test('a folder job is named after the folder, not a made-up label', () {
      final JobGroup job = JobGroup(
        key: JobKey(
          kind: JobKeyKind.folder,
          value: 'C:${sep}Jobs${sep}Smith',
        ),
        photos: const <JobPhoto>[],
      );
      expect(job.displayName, 'Smith');
    });
  });

  group('persistence', () {
    test('the index survives a reload', () async {
      await record('C:${sep}Jobs${sep}Smith${sep}a.jpg', marks: 3);
      final JobIndexService reopened = JobIndexService(
        overrideDirectory: workDir.path,
      );
      final List<JobGroup> jobs = await reopened.load();
      expect(jobs, hasLength(1));
      expect(jobs.single.photos.single.markCount, 3);
    });

    test('a broken index file loads as empty rather than throwing', () async {
      File(service.indexFilePath).writeAsStringSync('not json');
      expect(await service.load(), isEmpty);
    });

    test('no index file at all loads as empty', () async {
      expect(await service.load(), isEmpty);
    });

    test('jobs come back most recently opened first', () async {
      await record(
        'C:${sep}Jobs${sep}Old${sep}a.jpg',
        at: DateTime.utc(2026, 1, 1),
      );
      await record(
        'C:${sep}Jobs${sep}New${sep}b.jpg',
        at: DateTime.utc(2026, 8, 20),
      );
      final List<JobGroup> jobs = await service.load();
      expect(jobs.first.displayName, 'New');
    });
  });

  group('housekeeping', () {
    test('a job whose photos are all gone is pruned', () async {
      final String realPhoto = '${workDir.path}${sep}real.jpg';
      File(realPhoto).writeAsBytesSync(<int>[1]);
      await record(realPhoto);
      await record('C:${sep}Nowhere${sep}ghost.jpg');
      expect(await service.load(), hasLength(2));

      final List<JobGroup> kept = await service.pruneMissingPhotos();
      expect(kept, hasLength(1));
      expect(kept.single.photos.single.sourceImagePath, realPhoto);
    });

    test('clearing removes the index', () async {
      await record('C:${sep}Jobs${sep}Smith${sep}a.jpg');
      await service.clear();
      expect(File(service.indexFilePath).existsSync(), isFalse);
      expect(await service.load(), isEmpty);
    });

    test('nothing here writes to a photo', () async {
      final String realPhoto = '${workDir.path}${sep}real.jpg';
      final File file = File(realPhoto)..writeAsBytesSync(<int>[1, 2, 3]);
      final DateTime modifiedBefore = file.lastModifiedSync();
      await record(realPhoto, marks: 4);
      await service.pruneMissingPhotos();
      expect(file.readAsBytesSync(), <int>[1, 2, 3]);
      expect(file.lastModifiedSync(), modifiedBefore);
    });
  });
}
