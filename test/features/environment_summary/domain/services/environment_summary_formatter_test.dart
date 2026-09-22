import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_build_identity.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/startup_installation_validation.dart';
import 'package:remember_this_text/features/environment_summary/domain/entities/environment_summary.dart';
import 'package:remember_this_text/features/environment_summary/domain/services/environment_summary_formatter.dart';

void main() {
  const formatter = EnvironmentSummaryFormatter();

  test('formats a stable production support summary', () {
    final summary = _fixture(
      productName: 'MessageLens',
      environment: ArchiveEnvironment.production,
      buildIdentity: ArchiveBuildIdentity.productionRelease,
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
      dataRoot: '/Users/example/Library/Application Support/MessageLens',
      dataVolume: 'This Mac',
      attachmentRoot:
          '/Users/example/Library/Application Support/MessageLens/attachment_archive',
      attachmentVolume: 'This Mac',
    );

    expect(formatter.format(summary), '''
MessageLens Environment Summary

Installation
  Product: MessageLens
  Version: 0.2.124+142
  Environment: production
  Build identity: productionRelease
  Bundle identifier: com.bigbenchsoftware.MessageLens

Data folder
  Status: Connected
  Volume: This Mac
  Path: /Users/example/Library/Application Support/MessageLens

Attachment archive
  Status: Connected · read/write
  Volume: This Mac
  Path: /Users/example/Library/Application Support/MessageLens/attachment_archive

Data
  Messages in MessageLens: 3
  Message sources: 2 (1 current, 1 historical)
  Conversations: 2
  Contacts in MessageLens: 2
  Contacts provenance: Current Mac Contacts; physical source identity not retained

Technical
  Archive instance UUID: 11111111-1111-4111-8111-111111111111
  Startup admission: completed · boundedInspection
  Import database: /support/macos_import_ss.db · schema 10/10 · 100 bytes
  Graph database: /support/working_ss.db · schema 3/3 · 200 bytes
  Overlay database: /support/user_overlays.db · schema 8/8 · 300 bytes
  Presence database: Not present · schema Unknown/9 · Unknown
  FTS rows: 2''');
  });

  test('formats the same model shape for development', () {
    final summary = _fixture(
      productName: 'MessageLens Development',
      environment: ArchiveEnvironment.development,
      buildIdentity: ArchiveBuildIdentity.developmentDebug,
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens.development',
      dataRoot:
          '/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development',
      dataVolume: 'WD_ELEMENTS',
      attachmentRoot:
          '/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive',
      attachmentVolume: 'Toshiba_manual_bu',
    );

    expect(formatter.format(summary), contains('Environment: development'));
    expect(
      formatter.format(summary),
      contains('Build identity: developmentDebug'),
    );
    expect(formatter.format(summary), contains('Volume: WD_ELEMENTS'));
    expect(formatter.format(summary), contains('Volume: Toshiba_manual_bu'));
  });

  test('excludes user content and historical labels and paths', () {
    final summary = _fixture(
      productName: 'MessageLens',
      environment: ArchiveEnvironment.production,
      buildIdentity: ArchiveBuildIdentity.productionRelease,
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
      dataRoot: '/Users/example/Library/Application Support/MessageLens',
      dataVolume: 'This Mac',
      attachmentRoot: '/Volumes/Support/attachment_archive',
      attachmentVolume: 'Support',
      historicalLabel: 'PRIVATE PERSON NAME',
      historicalPath: '/Volumes/PRIVATE DRIVE/PRIVATE FOLDER/chat.db',
    );

    final formatted = formatter.format(summary);

    expect(formatted, isNot(contains('PRIVATE PERSON NAME')));
    expect(formatted, isNot(contains('PRIVATE DRIVE')));
    expect(formatted, isNot(contains('message text')));
    expect(formatted, isNot(contains('phone')));
    expect(formatted, isNot(contains('bookmark')));
    expect(formatted, isNot(contains('attachment filename')));
  });

  test('preserves Unknown, Unavailable, and Not retained distinctions', () {
    final base = _fixture(
      productName: 'MessageLens',
      environment: ArchiveEnvironment.production,
      buildIdentity: ArchiveBuildIdentity.productionRelease,
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
      dataRoot: '/support',
      dataVolume: 'This Mac',
      attachmentRoot: null,
      attachmentVolume: null,
    );
    final summary = EnvironmentSummary(
      installation: base.installation,
      dataRoot: base.dataRoot,
      attachmentArchive: const EnvironmentAttachmentArchiveSummary(
        status: EnvironmentSectionStatus.unavailable,
        availability: EnvironmentAvailability.disconnected,
        isReadable: false,
        isPhysicallyWritable: false,
        locationGeneration: 1,
      ),
      messages: EnvironmentMessageDataSummary(
        status: EnvironmentSectionStatus.unavailable,
        sources: const <EnvironmentMessageSourceSummary>[],
      ),
      contacts: const EnvironmentContactsDataSummary(
        status: EnvironmentSectionStatus.notRetained,
        physicalSourceIdentityRetained: false,
      ),
      technical: EnvironmentTechnicalSummary(
        status: EnvironmentSectionStatus.loading,
        databaseStatus: EnvironmentSectionStatus.loading,
        ftsStatus: EnvironmentSectionStatus.failed,
        databases: const <EnvironmentDatabaseSummary>[],
      ),
    );

    final formatted = formatter.format(summary);

    expect(formatted, contains('Messages in MessageLens: Unavailable'));
    expect(formatted, contains('Contacts in MessageLens: Not retained'));
    expect(formatted, contains('Startup admission: Unknown'));
    expect(formatted, contains('FTS rows: Unknown'));
  });
}

EnvironmentSummary _fixture({
  required String productName,
  required ArchiveEnvironment environment,
  required ArchiveBuildIdentity buildIdentity,
  required String bundleIdentifier,
  required String dataRoot,
  required String dataVolume,
  required String? attachmentRoot,
  required String? attachmentVolume,
  String historicalLabel = 'Old Mac',
  String historicalPath = '/Volumes/Offline/Archive/chat.db',
}) {
  return EnvironmentSummary(
    installation: EnvironmentInstallationSummary(
      productName: productName,
      semanticVersion: '0.2.124',
      buildNumber: '142',
      environment: environment,
      buildIdentity: buildIdentity,
      bundleIdentifier: bundleIdentifier,
      archiveInstanceId: '11111111-1111-4111-8111-111111111111',
      runtimeMode: EnvironmentRuntimeMode.debug,
      packageStatus: EnvironmentSectionStatus.ready,
    ),
    dataRoot: EnvironmentDataRootSummary(
      canonicalPath: dataRoot,
      displayVolumeName: dataVolume,
      availability: EnvironmentAvailability.connected,
      status: EnvironmentSectionStatus.ready,
    ),
    attachmentArchive: EnvironmentAttachmentArchiveSummary(
      status: EnvironmentSectionStatus.ready,
      canonicalPath: attachmentRoot,
      volumeName: attachmentVolume,
      availability: attachmentRoot == null
          ? EnvironmentAvailability.disconnected
          : EnvironmentAvailability.connected,
      isReadable: attachmentRoot != null,
      isPhysicallyWritable: attachmentRoot != null,
      locationGeneration: 1,
    ),
    messages: EnvironmentMessageDataSummary(
      status: EnvironmentSectionStatus.ready,
      projectedMessageCount: 3,
      conversationCount: 2,
      attachmentReferenceCount: 1,
      sources: <EnvironmentMessageSourceSummary>[
        const EnvironmentMessageSourceSummary(
          sourceId: 1,
          sourceKey: 'live-chat-db',
          kind: EnvironmentMessageSourceKind.currentMacMessages,
          displayLabel: 'Current Mac Messages',
          projectedMessageCount: 1,
          dateRangeStatus: EnvironmentSectionStatus.ready,
        ),
        EnvironmentMessageSourceSummary(
          sourceId: 3,
          sourceKey: 'historical-messages-archive:$historicalPath',
          kind: EnvironmentMessageSourceKind.historicalMessagesArchive,
          displayLabel: historicalLabel,
          registryLabel: historicalLabel,
          canonicalSourcePath: historicalPath,
          projectedMessageCount: 2,
          dateRangeStatus: EnvironmentSectionStatus.ready,
        ),
      ],
    ),
    contacts: const EnvironmentContactsDataSummary(
      status: EnvironmentSectionStatus.ready,
      projectedContactCount: 2,
      linkedHandleCount: 3,
      importedChannelCount: 4,
      physicalSourceIdentityRetained: false,
    ),
    technical: EnvironmentTechnicalSummary(
      status: EnvironmentSectionStatus.ready,
      databaseStatus: EnvironmentSectionStatus.ready,
      ftsStatus: EnvironmentSectionStatus.ready,
      startupAdmissionBasis: StartupAdmissionBasis.boundedInspection,
      installationState: MessageLensInstallationStateKind.completed,
      maintenanceActive: false,
      ftsAvailable: true,
      ftsRowCount: 2,
      databases: const <EnvironmentDatabaseSummary>[
        EnvironmentDatabaseSummary(
          role: EnvironmentDatabaseRole.sourceImport,
          path: '/support/macos_import_ss.db',
          exists: true,
          readable: true,
          sizeBytes: 100,
          userVersion: 10,
          expectedVersion: 10,
        ),
        EnvironmentDatabaseSummary(
          role: EnvironmentDatabaseRole.conversationGraph,
          path: '/support/working_ss.db',
          exists: true,
          readable: true,
          sizeBytes: 200,
          userVersion: 3,
          expectedVersion: 3,
        ),
        EnvironmentDatabaseSummary(
          role: EnvironmentDatabaseRole.userOverlay,
          path: '/support/user_overlays.db',
          exists: true,
          readable: true,
          sizeBytes: 300,
          userVersion: 8,
          expectedVersion: 8,
        ),
        EnvironmentDatabaseSummary(
          role: EnvironmentDatabaseRole.presence,
          path: '/support/presence.db',
          exists: false,
          readable: false,
          expectedVersion: 9,
        ),
      ],
    ),
  );
}
