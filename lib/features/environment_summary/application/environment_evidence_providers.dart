import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../../../essentials/db/feature_level_providers.dart'
    show dbMaintenanceLockProvider;
import '../domain/entities/environment_summary.dart';
import '../infrastructure/repositories/platform_environment_package_info_reader.dart';
import '../infrastructure/repositories/sqlite_environment_evidence_repository.dart';
import 'environment_evidence_repository.dart';
import 'environment_package_info_reader.dart';

part 'environment_evidence_providers.g.dart';

@riverpod
EnvironmentEvidenceRepository environmentEvidenceRepository(Ref ref) {
  return const SqliteEnvironmentEvidenceRepository();
}

@riverpod
EnvironmentPackageInfoReader environmentPackageInfoReader(Ref ref) {
  return const PlatformEnvironmentPackageInfoReader();
}

@riverpod
Future<EnvironmentPackageInfoEvidence> environmentPackageInfoEvidence(Ref ref) {
  return ref.watch(environmentPackageInfoReaderProvider).read();
}

@riverpod
Future<EnvironmentRootEvidence> environmentDataRootEvidence(Ref ref) {
  final rootPath = ref.watch(archiveAccessAuthorityProvider).rootPath;
  return ref
      .watch(environmentEvidenceRepositoryProvider)
      .inspectDataRoot(rootPath);
}

@riverpod
Future<List<EnvironmentDatabaseSummary>> environmentDatabaseEvidence(Ref ref) {
  _requireDatabaseObservationAvailable(ref);
  final rootPath = ref.watch(archiveAccessAuthorityProvider).rootPath;
  return ref
      .watch(environmentEvidenceRepositoryProvider)
      .inspectDatabases(rootPath);
}

@riverpod
Future<EnvironmentMessageEvidence> environmentMessageEvidence(Ref ref) {
  _requireDatabaseObservationAvailable(ref);
  final rootPath = ref.watch(archiveAccessAuthorityProvider).rootPath;
  return ref
      .watch(environmentEvidenceRepositoryProvider)
      .readMessageEvidence(rootPath);
}

@riverpod
Future<List<EnvironmentMessageDateRangeEvidence>>
environmentMessageDateRangeEvidence(Ref ref) async {
  _requireDatabaseObservationAvailable(ref);
  final rootPath = ref.watch(archiveAccessAuthorityProvider).rootPath;
  final messages = await ref.watch(environmentMessageEvidenceProvider.future);
  return ref
      .watch(environmentEvidenceRepositoryProvider)
      .readMessageDateRanges(
        rootPath,
        messages.sources.map((source) => source.sourceId),
      );
}

@riverpod
Future<EnvironmentContactsEvidence> environmentContactsEvidence(Ref ref) {
  _requireDatabaseObservationAvailable(ref);
  final rootPath = ref.watch(archiveAccessAuthorityProvider).rootPath;
  return ref
      .watch(environmentEvidenceRepositoryProvider)
      .readContactsEvidence(rootPath);
}

@riverpod
Future<EnvironmentFtsEvidence> environmentFtsEvidence(Ref ref) {
  _requireDatabaseObservationAvailable(ref);
  final rootPath = ref.watch(archiveAccessAuthorityProvider).rootPath;
  return ref
      .watch(environmentEvidenceRepositoryProvider)
      .readFtsEvidence(rootPath);
}

void _requireDatabaseObservationAvailable(Ref ref) {
  if (ref.exists(dbMaintenanceLockProvider) &&
      ref.watch(dbMaintenanceLockProvider)) {
    throw const EnvironmentEvidenceUnavailableException(
      'Database evidence is unavailable while maintenance is active.',
    );
  }
}
