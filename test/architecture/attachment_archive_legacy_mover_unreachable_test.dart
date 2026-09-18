import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Settings and sidebar expose no legacy mover route', () {
    final sources = <String, String>{
      for (final path in _settingsRoutePaths)
        path: File(path).readAsStringSync(),
    };

    for (final MapEntry(key: path, value: source) in sources.entries) {
      for (final token in _settingsRouteTokens) {
        expect(source, isNot(contains(token)), reason: '$path exposes $token');
      }
    }
  });

  test('legacy Settings action shell cannot invoke mover execution', () {
    final source = File(
      'lib/features/settings/application/'
      'attachment_archive_relocation_actions_provider.dart',
    ).readAsStringSync();

    expect(source, contains('Inert legacy shell'));
    expect(
      source,
      isNot(contains('../../attachments/feature_level_providers.dart')),
    );
    expect(
      source,
      isNot(contains('attachmentArchiveRelocationWorkflowProvider')),
    );
    expect(
      source,
      isNot(contains('attachmentArchiveRelocationExecutionEnabledProvider')),
    );
    expect(source, isNot(contains('chooseDestinationAndPrepare')));
    expect(source, isNot(contains('prepareForReview')));
    expect(source, isNot(contains('refreshFromJournal')));
  });

  test('ordinary production code has no legacy mover execution reference', () {
    final offenders = <String>[];
    for (final file in _productionDartFiles()) {
      if (_isReviewedLegacyMoverBoundary(file.path)) {
        continue;
      }
      final source = file.readAsStringSync();
      if (_executionTokens.any(source.contains)) {
        offenders.add(file.path);
      }
    }

    expect(offenders, isEmpty);
  });

  test('normal Settings composition cannot discover the legacy journal', () {
    final composition = File(
      'lib/essentials/sidebar/application/'
      'cassette_widget_coordinator_provider.dart',
    ).readAsStringSync();
    final settingsCoordinator = File(
      'lib/features/settings/application/sidebar_cassette_spec/'
      'coordinators/settings_coordinator.dart',
    ).readAsStringSync();

    for (final source in [composition, settingsCoordinator]) {
      expect(source, isNot(contains('Relocation')));
      expect(source, isNot(contains('relocation')));
      expect(source, isNot(contains('Journal')));
      expect(source, isNot(contains('journal')));
    }
  });

  test('verified activeArchive authority remains confined to legacy mover', () {
    final permitCallers = <String>[];
    final activationCallers = <String>[];
    for (final file in _productionDartFiles()) {
      final source = file.readAsStringSync();
      if (source.contains('_activationGate.issuePermit(')) {
        permitCallers.add(file.path);
      }
      if (source.contains('.activateVerifiedRelocation(')) {
        activationCallers.add(file.path);
      }
    }

    expect(permitCallers, <String>[_legacyServicePath]);
    expect(activationCallers, <String>[_legacyProviderPath]);

    final controller = File(
      'lib/features/attachments/application/'
      'attachment_archive_location_controller.dart',
    ).readAsStringSync();
    expect(
      controller,
      contains('Active custom attachment archives require verified relocation'),
    );
    expect(
      controller,
      contains(
        'activationPermit.requireActivationConfiguration(configuration)',
      ),
    );
  });
}

const _legacyServicePath =
    'lib/features/attachments/application/'
    'attachment_archive_relocation_service.dart';
const _legacyProviderPath =
    'lib/features/attachments/application/'
    'attachment_archive_relocation_provider.dart';

const _settingsRoutePaths = <String>[
  'lib/essentials/sidebar/domain/sidebar_action_intent.dart',
  'lib/essentials/sidebar/application/sidebar_action_dispatcher.dart',
  'lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart',
  'lib/features/settings/application/sidebar_cassette_spec/coordinators/settings_coordinator.dart',
  'lib/features/settings/application/sidebar_cassette_spec/resolvers/attachment_archive_settings_resolver.dart',
  'lib/features/settings/feature_level_providers.dart',
  'lib/features/attachments/feature_level_providers.dart',
];

const _settingsRouteTokens = <String>[
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

const _executionTokens = <String>[
  'attachmentArchiveRelocationWorkflowProvider',
  'attachmentArchiveRelocationServiceProvider',
  'attachmentArchiveRelocationExecutionEnabledProvider',
  'FilesystemAttachmentArchiveRelocationJournalStore(',
];

Iterable<File> _productionDartFiles() sync* {
  for (final entity in Directory(
    'lib',
  ).listSync(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      yield entity;
    }
  }
}

bool _isReviewedLegacyMoverBoundary(String path) {
  return path.startsWith(
        'lib/features/attachments/application/'
        'attachment_archive_relocation_',
      ) ||
      path ==
          'lib/features/attachments/domain/entities/'
              'attachment_archive_relocation.dart' ||
      path.startsWith(
        'lib/features/attachments/infrastructure/repositories/'
        'filesystem_attachment_archive_relocation_',
      ) ||
      path ==
          'lib/features/attachments/infrastructure/repositories/'
              'overlay_attachment_archive_relocation_metadata_reader.dart' ||
      path ==
          'lib/features/attachments/infrastructure/repositories/'
              'darwin_exclusive_directory_finalizer.dart';
}
