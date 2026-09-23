import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/application/archive_access_authority_provider.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_access_authority.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_build_identity.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_instance_id.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/resolved_archive_identity.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/db_maintenance_lock_provider.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_evidence_providers.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_evidence_repository.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_package_info_reader.dart';
import 'package:remember_this_text/features/environment_summary/domain/entities/environment_summary.dart';

void main() {
  test('uses the narrow PackageInfo reader seam', () async {
    final reader = _RecordingPackageInfoReader();
    final container = ProviderContainer(
      overrides: <Override>[
        environmentPackageInfoReaderProvider.overrideWithValue(reader),
      ],
    );
    addTearDown(container.dispose);

    final evidence = await container.read(
      environmentPackageInfoEvidenceProvider.future,
    );

    expect(evidence.semanticVersion, '1.2.3');
    expect(evidence.buildNumber, '45');
    expect(reader.readCount, 1);
  });

  test(
    'already-live maintenance evidence suppresses every database read',
    () async {
      final repository = _RecordingEvidenceRepository();
      final container = ProviderContainer(
        overrides: <Override>[
          admittedArchiveAccessAuthorityProvider.overrideWithValue(_authority),
          dbMaintenanceLockProvider.overrideWithValue(true),
          environmentEvidenceRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(dbMaintenanceLockProvider), isTrue);

      await expectLater(
        container.read(environmentMessageEvidenceProvider.future),
        throwsA(isA<EnvironmentEvidenceUnavailableException>()),
      );
      await expectLater(
        container.read(environmentContactsEvidenceProvider.future),
        throwsA(isA<EnvironmentEvidenceUnavailableException>()),
      );
      await expectLater(
        container.read(environmentDatabaseEvidenceProvider.future),
        throwsA(isA<EnvironmentEvidenceUnavailableException>()),
      );
      await expectLater(
        container.read(environmentFtsEvidenceProvider.future),
        throwsA(isA<EnvironmentEvidenceUnavailableException>()),
      );

      expect(repository.calls, isEmpty);
    },
  );
}

final class _RecordingPackageInfoReader
    implements EnvironmentPackageInfoReader {
  int readCount = 0;

  @override
  Future<EnvironmentPackageInfoEvidence> read() async {
    readCount += 1;
    return const EnvironmentPackageInfoEvidence(
      semanticVersion: '1.2.3',
      buildNumber: '45',
    );
  }
}

final class _RecordingEvidenceRepository
    implements EnvironmentEvidenceRepository {
  final List<String> calls = <String>[];

  @override
  Future<List<EnvironmentDatabaseSummary>> inspectDatabases(
    String canonicalRootPath,
  ) async {
    calls.add('databases');
    return const <EnvironmentDatabaseSummary>[];
  }

  @override
  Future<EnvironmentRootEvidence> inspectDataRoot(
    String canonicalRootPath,
  ) async {
    calls.add('root');
    return const EnvironmentRootEvidence(
      availability: EnvironmentAvailability.connected,
      displayVolumeName: 'This Mac',
    );
  }

  @override
  Future<EnvironmentContactsEvidence> readContactsEvidence(
    String canonicalRootPath,
  ) async {
    calls.add('contacts');
    return const EnvironmentContactsEvidence(
      projectedContactCount: 0,
      linkedHandleCount: 0,
      importedChannelCount: 0,
    );
  }

  @override
  Future<EnvironmentFtsEvidence> readFtsEvidence(
    String canonicalRootPath,
  ) async {
    calls.add('fts');
    return const EnvironmentFtsEvidence(isAvailable: false, rowCount: null);
  }

  @override
  Future<List<EnvironmentMessageDateRangeEvidence>> readMessageDateRanges(
    String canonicalRootPath,
    Iterable<int> sourceIds,
  ) async {
    calls.add('dates');
    return const <EnvironmentMessageDateRangeEvidence>[];
  }

  @override
  Future<EnvironmentMessageEvidence> readMessageEvidence(
    String canonicalRootPath,
  ) async {
    calls.add('messages');
    return EnvironmentMessageEvidence(
      projectedMessageCount: 0,
      conversationCount: 0,
      attachmentReferenceCount: 0,
      sources: const <EnvironmentMessageSourceEvidence>[],
    );
  }
}

final ArchiveAccessAuthority _authority = ArchiveAccessAuthority(
  identity: ResolvedArchiveIdentity(
    environment: ArchiveEnvironment.test,
    buildIdentity: ArchiveBuildIdentity.testHarness,
    archiveInstanceId: ArchiveInstanceId(
      '33333333-3333-4333-8333-333333333333',
    ),
    canonicalRootPath: '/tmp/environment-evidence-provider-test',
    bundleIdentifier: 'com.bigbenchsoftware.MessageLens.test',
    productName: 'MessageLens Test',
  ),
);
