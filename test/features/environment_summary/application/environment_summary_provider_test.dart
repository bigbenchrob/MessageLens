import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/application/archive_access_authority_provider.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_access_authority.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_build_identity.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_instance_id.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/resolved_archive_identity.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_snapshot.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_evidence_providers.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_evidence_repository.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_package_info_reader.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_summary_provider.dart';
import 'package:remember_this_text/features/environment_summary/domain/entities/environment_summary.dart';

void main() {
  test(
    'publishes immediate identity then isolates independent section results',
    () async {
      final package = Completer<EnvironmentPackageInfoEvidence>();
      final root = Completer<EnvironmentRootEvidence>();
      final messages = Completer<EnvironmentMessageEvidence>();
      final dates = Completer<List<EnvironmentMessageDateRangeEvidence>>();
      final contacts = Completer<EnvironmentContactsEvidence>();
      final databases = Completer<List<EnvironmentDatabaseSummary>>();
      final fts = Completer<EnvironmentFtsEvidence>();
      final configuration =
          AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: base64Encode(<int>[1]),
            lastKnownPath: '/Volumes/Attachments/attachment_archive',
            volumeName: 'Attachments',
            customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
          );
      final attachmentSnapshot =
          AttachmentArchiveLocationSnapshot.fromLocationState(
            AttachmentArchiveLocationState.customAvailable(
              configuration: configuration,
              archiveRootPath: '/Volumes/Attachments/attachment_archive',
            ),
          );
      final container = ProviderContainer(
        overrides: <Override>[
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            _authority(ArchiveEnvironment.development),
          ),
          environmentPackageInfoEvidenceProvider.overrideWith(
            (ref) => package.future,
          ),
          environmentDataRootEvidenceProvider.overrideWith(
            (ref) => root.future,
          ),
          environmentMessageEvidenceProvider.overrideWith(
            (ref) => messages.future,
          ),
          environmentMessageDateRangeEvidenceProvider.overrideWith(
            (ref) => dates.future,
          ),
          environmentContactsEvidenceProvider.overrideWith(
            (ref) => contacts.future,
          ),
          environmentDatabaseEvidenceProvider.overrideWith(
            (ref) => databases.future,
          ),
          environmentFtsEvidenceProvider.overrideWith((ref) => fts.future),
          attachmentArchiveLocationObservationProvider.overrideWith(
            () => _FixedAttachmentObservation(attachmentSnapshot),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(environmentSummaryProvider, (_, _) {});

      final initial = container.read(environmentSummaryProvider);

      expect(initial.installation.productName, 'MessageLens Development');
      expect(
        initial.installation.packageStatus,
        EnvironmentSectionStatus.loading,
      );
      expect(initial.dataRoot.canonicalPath, '/Volumes/Test/MessageLens');
      expect(initial.messages.status, EnvironmentSectionStatus.loading);
      expect(initial.contacts.status, EnvironmentSectionStatus.loading);
      expect(initial.technical.status, EnvironmentSectionStatus.loading);
      expect(initial.attachmentArchive.status, EnvironmentSectionStatus.ready);
      expect(container.exists(attachmentArchiveLocationProvider), isFalse);

      package.complete(
        const EnvironmentPackageInfoEvidence(
          semanticVersion: '1.0.0',
          buildNumber: '1',
        ),
      );
      root.complete(
        const EnvironmentRootEvidence(
          availability: EnvironmentAvailability.connected,
          displayVolumeName: 'Test',
        ),
      );
      messages.complete(
        EnvironmentMessageEvidence(
          projectedMessageCount: 2,
          conversationCount: 1,
          attachmentReferenceCount: 1,
          sources: const <EnvironmentMessageSourceEvidence>[
            EnvironmentMessageSourceEvidence(
              sourceId: 1,
              sourceKey: 'live-chat-db',
              kind: EnvironmentMessageSourceKind.currentMacMessages,
              displayLabel: 'Current Mac Messages',
              projectedMessageCount: 2,
            ),
          ],
        ),
      );
      dates.complete(<EnvironmentMessageDateRangeEvidence>[
        EnvironmentMessageDateRangeEvidence(
          sourceId: 1,
          earliestMessageUtc: DateTime.utc(2020),
          latestMessageUtc: DateTime.utc(2021),
        ),
      ]);
      contacts.completeError(StateError('Contacts evidence failed.'));
      databases.complete(const <EnvironmentDatabaseSummary>[]);
      fts.complete(
        const EnvironmentFtsEvidence(isAvailable: true, rowCount: 2),
      );
      await _settle();

      final settled = container.read(environmentSummaryProvider);

      expect(settled.installation.semanticVersion, '1.0.0');
      expect(settled.dataRoot.status, EnvironmentSectionStatus.ready);
      expect(settled.attachmentArchive.status, EnvironmentSectionStatus.ready);
      expect(
        settled.attachmentArchive.canonicalPath,
        '/Volumes/Attachments/attachment_archive',
      );
      expect(settled.messages.status, EnvironmentSectionStatus.ready);
      expect(settled.messages.projectedMessageCount, 2);
      expect(settled.messages.earliestMessageUtc, DateTime.utc(2020));
      expect(settled.contacts.status, EnvironmentSectionStatus.failed);
      expect(settled.technical.status, EnvironmentSectionStatus.ready);
      expect(container.exists(attachmentArchiveLocationProvider), isFalse);
    },
  );

  test(
    'maps unavailable evidence without failing unrelated sections',
    () async {
      final container = ProviderContainer(
        overrides: <Override>[
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            _authority(ArchiveEnvironment.production),
          ),
          environmentPackageInfoEvidenceProvider.overrideWith(
            (ref) async => const EnvironmentPackageInfoEvidence(
              semanticVersion: '1.0.0',
              buildNumber: '1',
            ),
          ),
          environmentDataRootEvidenceProvider.overrideWith(
            (ref) async => const EnvironmentRootEvidence(
              availability: EnvironmentAvailability.connected,
              displayVolumeName: 'This Mac',
            ),
          ),
          environmentMessageEvidenceProvider.overrideWith(
            (ref) => Future<EnvironmentMessageEvidence>.error(
              const EnvironmentEvidenceUnavailableException('Graph missing.'),
            ),
          ),
          environmentMessageDateRangeEvidenceProvider.overrideWith(
            (ref) async => const <EnvironmentMessageDateRangeEvidence>[],
          ),
          environmentContactsEvidenceProvider.overrideWith(
            (ref) async => const EnvironmentContactsEvidence(
              projectedContactCount: 0,
              linkedHandleCount: 0,
              importedChannelCount: 0,
            ),
          ),
          environmentDatabaseEvidenceProvider.overrideWith(
            (ref) async => const <EnvironmentDatabaseSummary>[],
          ),
          environmentFtsEvidenceProvider.overrideWith(
            (ref) async => const EnvironmentFtsEvidence(
              isAvailable: false,
              rowCount: null,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(environmentSummaryProvider, (_, _) {});
      await _settle();

      final summary = container.read(environmentSummaryProvider);

      expect(summary.messages.status, EnvironmentSectionStatus.unavailable);
      expect(summary.contacts.status, EnvironmentSectionStatus.ready);
      expect(summary.installation.productName, 'MessageLens');
    },
  );

  test(
    'production and development use the same immutable model shape',
    () async {
      final production = await _settledIdentitySummary(
        ArchiveEnvironment.production,
      );
      final development = await _settledIdentitySummary(
        ArchiveEnvironment.development,
      );

      expect(production.runtimeType, development.runtimeType);
      expect(
        production.installation.runtimeType,
        development.installation.runtimeType,
      );
      expect(production.messages.runtimeType, development.messages.runtimeType);
      expect(production.contacts.runtimeType, development.contacts.runtimeType);
      expect(
        production.technical.runtimeType,
        development.technical.runtimeType,
      );
    },
  );
}

Future<EnvironmentSummary> _settledIdentitySummary(
  ArchiveEnvironment environment,
) async {
  final container = ProviderContainer(
    overrides: <Override>[
      admittedArchiveAccessAuthorityProvider.overrideWithValue(
        _authority(environment),
      ),
      environmentPackageInfoEvidenceProvider.overrideWith(
        (ref) async => const EnvironmentPackageInfoEvidence(
          semanticVersion: '1',
          buildNumber: '1',
        ),
      ),
      environmentDataRootEvidenceProvider.overrideWith(
        (ref) async => const EnvironmentRootEvidence(
          availability: EnvironmentAvailability.connected,
          displayVolumeName: 'This Mac',
        ),
      ),
      environmentMessageEvidenceProvider.overrideWith(
        (ref) async => EnvironmentMessageEvidence(
          projectedMessageCount: 0,
          conversationCount: 0,
          attachmentReferenceCount: 0,
          sources: const <EnvironmentMessageSourceEvidence>[],
        ),
      ),
      environmentMessageDateRangeEvidenceProvider.overrideWith(
        (ref) async => const <EnvironmentMessageDateRangeEvidence>[],
      ),
      environmentContactsEvidenceProvider.overrideWith(
        (ref) async => const EnvironmentContactsEvidence(
          projectedContactCount: 0,
          linkedHandleCount: 0,
          importedChannelCount: 0,
        ),
      ),
      environmentDatabaseEvidenceProvider.overrideWith(
        (ref) async => const <EnvironmentDatabaseSummary>[],
      ),
      environmentFtsEvidenceProvider.overrideWith(
        (ref) async =>
            const EnvironmentFtsEvidence(isAvailable: false, rowCount: null),
      ),
    ],
  );
  container.listen(environmentSummaryProvider, (_, _) {});
  await _settle();
  final summary = container.read(environmentSummaryProvider);
  container.dispose();
  return summary;
}

ArchiveAccessAuthority _authority(ArchiveEnvironment environment) {
  final production = environment == ArchiveEnvironment.production;
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: environment,
      buildIdentity: production
          ? ArchiveBuildIdentity.productionRelease
          : ArchiveBuildIdentity.developmentDebug,
      archiveInstanceId: ArchiveInstanceId(
        production
            ? '11111111-1111-4111-8111-111111111111'
            : '22222222-2222-4222-8222-222222222222',
      ),
      canonicalRootPath: production
          ? '/tmp/MessageLens'
          : '/Volumes/Test/MessageLens',
      bundleIdentifier: production
          ? 'com.bigbenchsoftware.MessageLens'
          : 'com.bigbenchsoftware.MessageLens.development',
      productName: production ? 'MessageLens' : 'MessageLens Development',
    ),
  );
}

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

final class _FixedAttachmentObservation
    extends AttachmentArchiveLocationObservation {
  _FixedAttachmentObservation(this.snapshot);

  final AttachmentArchiveLocationSnapshot snapshot;

  @override
  AttachmentArchiveLocationSnapshot build() => snapshot;
}
