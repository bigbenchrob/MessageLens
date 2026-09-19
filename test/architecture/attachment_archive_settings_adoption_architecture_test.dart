import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Settings adoption route contains no legacy mover dependency', () {
    for (final path in _settingsRoutePaths) {
      final source = File(path).readAsStringSync();
      for (final token in _legacyTokens) {
        expect(source, isNot(contains(token)), reason: '$path contains $token');
      }
    }
  });

  test('widgets and payloads carry no archive or configuration authority', () {
    for (final path in _renderBoundaryPaths) {
      final source = File(path).readAsStringSync();
      for (final token in <String>[
        "import 'dart:io'",
        'Directory(',
        'File(',
        'createBookmark',
        'resolveBookmark',
        'persistConfiguration',
        'activateVerifiedAdoption',
        'AttachmentArchiveCandidateComplete',
        'AttachmentArchiveAdoptionConfigurationAuthority',
        'activeArchive',
      ]) {
        expect(source, isNot(contains(token)), reason: '$path contains $token');
      }
    }
  });

  test('dispatcher reaches only the adoption workflow boundary', () {
    final source = File(
      'lib/essentials/sidebar/application/sidebar_action_dispatcher.dart',
    ).readAsStringSync();

    expect(source, contains('attachmentArchiveAdoptionWorkflowProvider'));
    expect(source, isNot(contains('attachmentArchiveAdoptionServiceProvider')));
    expect(source, isNot(contains('attachmentArchiveLocationProvider')));
    expect(source, isNot(contains('activateVerifiedAdoption')));
    expect(source, isNot(contains('persistConfiguration')));
  });

  test('complete verification stays private to attachments workflow', () {
    final workflow = File(
      'lib/features/attachments/application/'
      'attachment_archive_adoption_workflow_provider.dart',
    ).readAsStringSync();
    final publicState = File(
      'lib/features/attachments/application/'
      'attachment_archive_adoption_workflow.dart',
    ).readAsStringSync();
    final payload = File(
      'lib/features/settings/application/sidebar_cassette_spec/payloads/'
      'attachment_archive_settings_cassette_payload.dart',
    ).readAsStringSync();

    expect(
      workflow,
      contains('AttachmentArchiveCandidateComplete? _readyVerification'),
    );
    expect(publicState, isNot(contains('AttachmentArchiveCandidateComplete?')));
    expect(payload, isNot(contains('AttachmentArchiveCandidateComplete')));
    expect(payload, isNot(contains('bookmark')));
    expect(payload, isNot(contains('fingerprint')));
  });

  test('workflow never discovers or invokes legacy relocation artifacts', () {
    final source = File(
      'lib/features/attachments/application/'
      'attachment_archive_adoption_workflow_provider.dart',
    ).readAsStringSync();

    for (final token in <String>[
      '.attachment_archive_relocations',
      'RelocationJournal',
      'RelocationService',
      'RelocationProgress',
      'DestinationCapacity',
      'staging',
      'copyReceipt',
      'ExclusiveDirectoryFinalizer',
      'RelocationActivationPermit',
    ]) {
      expect(
        source,
        isNot(contains(token)),
        reason: 'workflow contains $token',
      );
    }
  });

  test('adoption gate is exact and has no runtime override', () {
    final source = File(
      'lib/features/attachments/application/'
      'attachment_archive_adoption_enablement_provider.dart',
    ).readAsStringSync();

    expect(source, contains('com.bigbenchsoftware.MessageLens.development'));
    expect(source, contains('MessageLens Development'));
    expect(
      source,
      contains(
        '/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development',
      ),
    );
    expect(source, contains('e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5'));
    expect(source, isNot(contains('Platform.environment')));
    expect(source, isNot(contains('String.fromEnvironment')));
    expect(source, isNot(contains('bool.fromEnvironment')));
    expect(source, isNot(contains('readSetting')));
    expect(source, isNot(contains('writeSetting')));
  });
}

const _settingsRoutePaths = <String>[
  'lib/essentials/sidebar/domain/sidebar_action_intent.dart',
  'lib/essentials/sidebar/application/sidebar_action_dispatcher.dart',
  'lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart',
  'lib/features/settings/application/sidebar_cassette_spec/coordinators/settings_coordinator.dart',
  'lib/features/settings/application/sidebar_cassette_spec/resolvers/attachment_archive_settings_resolver.dart',
  'lib/features/settings/feature_level_providers.dart',
  'lib/features/attachments/feature_level_providers.dart',
];

const _renderBoundaryPaths = <String>[
  'lib/features/settings/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart',
  'lib/features/settings/application/sidebar_cassette_spec/widget_builders/attachment_archive_settings_supplemental_content.dart',
  'lib/features/settings/application/sidebar_cassette_spec/widget_builders/settings_action_list.dart',
];

const _legacyTokens = <String>[
  'attachmentArchiveRelocation',
  'AttachmentArchiveRelocation',
  'AttachmentArchiveMoveRequested',
  'AttachmentArchiveChooseAnotherLocationRequested',
  'AttachmentArchiveRetryPreflightRequested',
  'AttachmentArchiveBeginRelocationRequested',
  'AttachmentArchivePauseRelocationRequested',
  'AttachmentArchiveResumeRelocationRequested',
  'AttachmentArchiveCancelRelocationRequested',
];
