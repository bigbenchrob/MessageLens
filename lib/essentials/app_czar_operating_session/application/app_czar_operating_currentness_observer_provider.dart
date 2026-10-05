import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/attachments/feature_level_providers.dart'
    show attachmentArchiveLocationProvider;
import '../../app_czar/application/app_czar_assessment_provider.dart';
import '../../app_czar/domain/app_czar_models.dart';
import '../../archive_environment/feature_level_providers.dart'
    show archiveMutationCoordinatorProvider;
import '../../db/feature_level_providers.dart' show messageDataVersionProvider;
import '../domain/app_czar_operating_currentness_models.dart';

part 'app_czar_operating_currentness_observer_provider.g.dart';

abstract interface class AppCzarOperatingCurrentnessObserver {
  Future<AppCzarOperatingReadFence> readFence();

  Future<AppCzarOperatingCurrentnessObservation> readCurrentness();

  Future<AppCzarOperatingCoverageObservation> readCoverage();
}

final class ReadOnlyAppCzarOperatingCurrentnessObserver
    implements AppCzarOperatingCurrentnessObserver {
  const ReadOnlyAppCzarOperatingCurrentnessObserver({
    required Future<AppCzarOperatingReadFence> Function() readFence,
    required Future<AppCzarSourceObservation> Function() readSource,
    required Future<AppCzarDatabaseObservation> Function() readImportStore,
    required Future<AppCzarDatabaseObservation> Function() readGraphStore,
    required Future<AppCzarArchiveObservation> Function() readArchive,
  }) : _readFence = readFence,
       _readSource = readSource,
       _readImportStore = readImportStore,
       _readGraphStore = readGraphStore,
       _readArchive = readArchive;

  final Future<AppCzarOperatingReadFence> Function() _readFence;
  final Future<AppCzarSourceObservation> Function() _readSource;
  final Future<AppCzarDatabaseObservation> Function() _readImportStore;
  final Future<AppCzarDatabaseObservation> Function() _readGraphStore;
  final Future<AppCzarArchiveObservation> Function() _readArchive;

  @override
  Future<AppCzarOperatingReadFence> readFence() => _readFence();

  @override
  Future<AppCzarOperatingCurrentnessObservation> readCurrentness() async {
    final before = await _readFence();
    if (!before.isQuiescent) {
      return AppCzarOperatingCurrentnessObservation(
        before: before,
        after: before,
      );
    }

    final source = await _readSourceSafely();
    final importStore = await _readDatabaseSafely(
      _readImportStore,
      'Import-store currentness inspection failed',
    );
    final graphStore = await _readDatabaseSafely(
      _readGraphStore,
      'Graph-store currentness inspection failed',
    );
    final after = await _readFence();
    return AppCzarOperatingCurrentnessObservation(
      before: before,
      after: after,
      source: source,
      importStore: importStore,
      graphStore: graphStore,
    );
  }

  @override
  Future<AppCzarOperatingCoverageObservation> readCoverage() async {
    final before = await _readFence();
    if (!before.isQuiescent) {
      return AppCzarOperatingCoverageObservation(
        before: before,
        after: before,
        archive: AppCzarArchiveObservation.unknown(
          'Attachment coverage inspection was deferred while another mutation was active.',
        ),
      );
    }

    AppCzarArchiveObservation archive;
    try {
      archive = await _readArchive();
    } on Object catch (error) {
      archive = AppCzarArchiveObservation.unknown(
        'Attachment coverage inspection failed: $error',
      );
    }
    final after = await _readFence();
    return AppCzarOperatingCoverageObservation(
      before: before,
      after: after,
      archive: archive,
    );
  }

  Future<AppCzarSourceObservation> _readSourceSafely() async {
    try {
      return await _readSource();
    } on Object catch (error) {
      return AppCzarSourceObservation.unknown(
        'Messages source currentness inspection failed: $error',
      );
    }
  }

  Future<AppCzarDatabaseObservation> _readDatabaseSafely(
    Future<AppCzarDatabaseObservation> Function() read,
    String failurePrefix,
  ) async {
    try {
      return await read();
    } on Object catch (error) {
      return AppCzarDatabaseObservation.unknown('$failurePrefix: $error');
    }
  }
}

@Riverpod(keepAlive: true)
AppCzarOperatingCurrentnessObserver appCzarOperatingCurrentnessObserver(
  Ref ref,
) {
  final appCzarReader = ref.watch(appCzarObservationReaderProvider);
  return ReadOnlyAppCzarOperatingCurrentnessObserver(
    readFence: () async {
      final location = await ref.read(attachmentArchiveLocationProvider.future);
      final mutation = ref.read(archiveMutationCoordinatorProvider);
      return AppCzarOperatingReadFence(
        messageDataGeneration: ref.read(messageDataVersionProvider),
        archiveLocation: AppCzarOperatingArchiveLocationEvidence(
          generation: location.generation,
          isReadable: location.isAvailable,
          isWritableMutationEligible: location.isWritableMutationEligible,
          resolvedPath: location.archiveRootPath,
          issue: location.issue,
        ),
        mutation: AppCzarOperatingMutationFence(
          isActive: mutation.isLocked,
          revisionToken: mutation,
          lastReleasedAtMicroseconds:
              mutation.lastReleasedAtUtc?.microsecondsSinceEpoch,
        ),
      );
    },
    readSource: appCzarReader.readSource,
    readImportStore: appCzarReader.readImportStore,
    readGraphStore: appCzarReader.readGraphStore,
    readArchive: appCzarReader.readAttachmentArchive,
  );
}
