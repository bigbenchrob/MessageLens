import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  final repositoryRoot = _repositoryRoot();
  final featureRoot = Directory(
    path.join(repositoryRoot.path, 'lib', 'features', 'environment_summary'),
  );

  test('Environment owns no root, attachment, or mutation authority', () {
    final source = _featureSource(featureRoot);

    for (final forbidden in <String>[
      'MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT',
      'CanonicalArchiveRootPolicy',
      'ArchiveMutationCoordinator',
      'AttachmentArchiveWritableRootLease',
      'attachmentArchiveLocationProvider',
      'attachmentArchiveLocationNativeAdapterProvider',
      'attachmentArchiveAdoption',
      'useDefaultInternalLocation',
      'configureCustomLocation',
      'resetDerivedData',
      'clearArchive',
      'Directory.list',
      'listSync(',
      'sha256',
      'md5',
      'WD_ELEMENTS',
      'Toshiba_manual_bu',
    ]) {
      expect(source, isNot(contains(forbidden)), reason: forbidden);
    }
  });

  test('Environment inspection does not use persistent database providers', () {
    final source = _featureSource(featureRoot);

    for (final forbidden in <String>[
      'sourceScopedImportDatabaseProvider',
      'driftConversationGraphDatabaseProvider',
      'overlayDatabaseProvider',
      'presenceDatabaseProvider',
      'databaseHealthAuditServiceProvider',
      'graphHealthRepositoryProvider',
      'integrityValidator',
      'recoveryActionsProvider',
      'importServiceProvider',
    ]) {
      expect(source, isNot(contains(forbidden)), reason: forbidden);
    }
    expect(source, contains('OpenMode.readOnly'));
    expect(source, contains('PRAGMA query_only = ON'));
    expect(source, contains('assertEnvironmentSummaryReadOnlySql'));
  });

  test('formatter is pure and imports only its read model', () {
    final formatter = File(
      path.join(
        featureRoot.path,
        'domain',
        'services',
        'environment_summary_formatter.dart',
      ),
    ).readAsStringSync();

    expect(
      RegExp(r'^import ', multiLine: true).allMatches(formatter),
      hasLength(1),
    );
    expect(
      formatter,
      contains("import '../entities/environment_summary.dart';"),
    );
    for (final forbidden in <String>[
      'Provider',
      'dart:io',
      'sqlite',
      'Clipboard',
      'BuildContext',
      'bookmarkDataBase64',
      'canonicalSourcePath',
      'registryLabel',
    ]) {
      expect(formatter, isNot(contains(forbidden)), reason: forbidden);
    }
  });

  test('snapshot and read model cannot carry hidden mutation capabilities', () {
    final snapshot = File(
      path.join(
        repositoryRoot.path,
        'lib',
        'features',
        'attachments',
        'domain',
        'entities',
        'attachment_archive_location_snapshot.dart',
      ),
    ).readAsStringSync();
    final model = File(
      path.join(
        featureRoot.path,
        'domain',
        'entities',
        'environment_summary.dart',
      ),
    ).readAsStringSync();

    for (final source in <String>[snapshot, model]) {
      for (final forbidden in <String>[
        'bookmarkDataBase64',
        'WritableRootLease',
        'MutationAuthority',
        'NativeAdapter',
        'Directory ',
        'File ',
        'Database database',
        'Controller',
        'contactsSourcePath',
        'previousAttachment',
      ]) {
        expect(source, isNot(contains(forbidden)), reason: forbidden);
      }
    }
    expect(model, contains('physicalSourceIdentityRetained'));
    expect(model, isNot(contains('retainedAttachment')));
  });

  test('Environment adds no startup, main, or onboarding reverse edge', () {
    final startupFiles = <File>[
      File(path.join(repositoryRoot.path, 'lib', 'main.dart')),
      ...Directory(
            path.join(repositoryRoot.path, 'lib', 'essentials', 'onboarding'),
          )
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart')),
    ];

    for (final file in startupFiles) {
      expect(
        file.readAsStringSync(),
        isNot(contains('environment_summary')),
        reason: file.path,
      );
    }
  });

  test(
    'Settings reaches the Environment panel only through its public seam',
    () {
      final resolver = File(
        path.join(
          repositoryRoot.path,
          'lib',
          'features',
          'settings',
          'application',
          'view_spec',
          'resolvers',
          'environment_summary_panel_resolver.dart',
        ),
      ).readAsStringSync();
      final coordinator = File(
        path.join(
          repositoryRoot.path,
          'lib',
          'features',
          'settings',
          'application',
          'view_spec',
          'coordinators',
          'view_spec_coordinator.dart',
        ),
      ).readAsStringSync();

      expect(
        resolver,
        contains("environment_summary/feature_level_providers.dart'"),
      );
      expect(resolver, contains('show EnvironmentSummaryPanel'));
      expect(resolver, isNot(contains('environment_summary/application/')));
      expect(resolver, isNot(contains('environment_summary/domain/')));
      expect(coordinator, contains('EnvironmentSummaryPanelResolver'));
      expect(coordinator, contains('environmentSummary:'));
    },
  );

  test('Environment presentation consumes only the aggregate read model', () {
    final panel = File(
      path.join(
        featureRoot.path,
        'presentation',
        'view',
        'environment_summary_panel.dart',
      ),
    ).readAsStringSync();

    expect(panel, contains('ref.watch(environmentSummaryProvider)'));
    for (final forbidden in <String>[
      'attachmentArchiveLocationProvider',
      'environmentPackageInfoEvidenceProvider',
      'environmentDataRootEvidenceProvider',
      'environmentMessageEvidenceProvider',
      'environmentContactsEvidenceProvider',
      'environmentDatabaseEvidenceProvider',
      'environmentFtsEvidenceProvider',
      'archiveAccessAuthorityProvider',
      'dart:io',
      'sqlite',
      'Clipboard',
      'Process.run',
      'showInFinder',
      'revealInFinder',
      'AttachmentArchiveAdoption',
    ]) {
      expect(panel, isNot(contains(forbidden)), reason: forbidden);
    }
  });

  test('Environment is a persistent center-only Settings route', () {
    final settingsMenu = File(
      path.join(
        repositoryRoot.path,
        'lib',
        'features',
        'sidebar_utilities',
        'application',
        'sidebar_cassette_spec',
        'payloads',
        'settings_top_menu_cassette_payload.dart',
      ),
    ).readAsStringSync();
    final flow = File(
      path.join(
        repositoryRoot.path,
        'lib',
        'essentials',
        'sidebar',
        'application',
        'sidebar_flow_state_provider.dart',
      ),
    ).readAsStringSync();
    final topology = File(
      path.join(
        repositoryRoot.path,
        'lib',
        'essentials',
        'sidebar',
        'domain',
        'entities',
        'cascade',
        'sidebar_utility_topology.dart',
      ),
    ).readAsStringSync();

    expect(settingsMenu, contains("label: 'Environment'"));
    expect(settingsMenu, contains('SettingsMenuActionId.environment'));
    expect(flow, contains('SettingsViewSpec.environmentSummary()'));
    expect(topology, contains('case SettingsMenuActionId.environment:'));
    expect(
      topology,
      contains(
        'case SettingsMenuActionId.environment:\n          return null;',
      ),
    );
  });
}

String _featureSource(Directory featureRoot) {
  return featureRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => file.readAsStringSync())
      .join('\n');
}

Directory _repositoryRoot() {
  var current = Directory.current.absolute;
  while (!File(path.join(current.path, 'pubspec.yaml')).existsSync()) {
    final parent = current.parent;
    if (parent.path == current.path) {
      throw StateError('Could not locate repository root.');
    }
    current = parent;
  }
  return current;
}
