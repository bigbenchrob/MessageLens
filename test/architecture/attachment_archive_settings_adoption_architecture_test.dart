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

  test('render edge carries no archive or configuration authority', () {
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

  test('sidebar dispatcher has no Attachment Archive workflow path', () {
    final source = File(
      'lib/essentials/sidebar/application/sidebar_action_dispatcher.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('AttachmentArchiveUseExistingRequested')));
    expect(
      source,
      isNot(contains('attachmentArchiveAdoptionWorkflowProvider')),
    );
    expect(source, isNot(contains('attachmentArchiveAdoptionServiceProvider')));
    expect(source, isNot(contains('attachmentArchiveLocationProvider')));
    expect(source, isNot(contains('activateVerifiedAdoption')));
    expect(source, isNot(contains('persistConfiguration')));
  });

  test('adoptable verification stays private to attachments workflow', () {
    final workflow = File(
      'lib/features/attachments/application/'
      'attachment_archive_adoption_workflow_provider.dart',
    ).readAsStringSync();
    final publicState = File(
      'lib/features/attachments/application/'
      'attachment_archive_adoption_workflow.dart',
    ).readAsStringSync();
    final panel = File(
      'lib/features/settings/presentation/view/attachment_archive_panel.dart',
    ).readAsStringSync();

    expect(
      workflow,
      contains(
        'AttachmentArchiveCandidateVerificationResult? _readyVerification',
      ),
    );
    expect(
      workflow,
      contains('result is AttachmentArchiveCandidateComplete ||'),
    );
    expect(workflow, contains('result is AttachmentArchiveCandidateBehind'));
    expect(
      publicState,
      isNot(contains('AttachmentArchiveCandidateVerificationResult?')),
    );
    expect(panel, isNot(contains('AttachmentArchiveCandidateComplete')));
    expect(panel, isNot(contains('bookmark')));
    expect(panel, isNot(contains('fingerprint')));
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

  test('Attachment Archive navigation projects only the center workflow', () {
    final flow = File(
      'lib/essentials/sidebar/application/sidebar_flow_state_provider.dart',
    ).readAsStringSync();
    final topology = File(
      'lib/essentials/sidebar/domain/entities/cascade/'
      'sidebar_utility_topology.dart',
    ).readAsStringSync();
    final settingsViewSpec = File(
      'lib/features/settings/domain/spec_classes/settings_view_spec.dart',
    ).readAsStringSync();
    final centerCoordinator = File(
      'lib/features/settings/application/view_spec/coordinators/'
      'view_spec_coordinator.dart',
    ).readAsStringSync();
    final descriptor = File(
      'lib/features/settings/application/view_spec/payloads/'
      'settings_panel_render_descriptor.dart',
    ).readAsStringSync();
    final renderRouter = File(
      'lib/features/settings/presentation/rendering/'
      'settings_panel_render_router.dart',
    ).readAsStringSync();
    final cassetteSpec = File(
      'lib/features/settings/domain/spec_classes/settings_cassette_spec.dart',
    ).readAsStringSync();

    expect(flow, contains('SettingsViewSpec.attachmentArchiveWorkflow()'));
    expect(topology, contains('case SettingsMenuActionId.attachmentArchive:'));
    expect(topology, contains('return null;'));
    expect(
      settingsViewSpec,
      contains('const factory SettingsViewSpec.attachmentArchiveWorkflow()'),
    );
    expect(
      centerCoordinator,
      contains('SettingsPanelRenderDescriptor.attachmentArchiveWorkflow'),
    );
    expect(centerCoordinator, isNot(contains('Widget')));
    expect(centerCoordinator, isNot(contains('AttachmentArchivePanel')));
    expect(descriptor, contains('attachmentArchiveWorkflow'));
    expect(descriptor, isNot(contains('package:flutter')));
    expect(renderRouter, contains('const AttachmentArchivePanel()'));
    expect(cassetteSpec, isNot(contains('attachmentArchive')));
  });

  test('Attachment Archive panel is constructed only at render edge', () {
    final applicationRoot = Directory('lib/features/settings/application');
    for (final file
        in applicationRoot
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      expect(
        source,
        isNot(contains('AttachmentArchivePanel(')),
        reason: file.path,
      );
    }
    final renderRouter = File(
      'lib/features/settings/presentation/rendering/'
      'settings_panel_render_router.dart',
    ).readAsStringSync();
    expect(renderRouter, contains('const AttachmentArchivePanel()'));
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
  'lib/features/settings/application/view_spec/coordinators/view_spec_coordinator.dart',
  'lib/features/settings/feature_level_providers.dart',
  'lib/features/attachments/feature_level_providers.dart',
];

const _renderBoundaryPaths = <String>[
  'lib/features/settings/presentation/rendering/settings_panel_render_router.dart',
  'lib/features/settings/presentation/view/attachment_archive_panel.dart',
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
