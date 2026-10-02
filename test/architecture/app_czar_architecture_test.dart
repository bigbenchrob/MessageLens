import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppCzar package cannot import semantic or execution authorities', () {
    final files = Directory('lib/essentials/app_czar')
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    const forbiddenImports = <String>[
      '/onboarding/',
      '/environment_readiness/',
      '/navigation/',
      'operation_snapshot',
      'coordinator_provider',
      'chat_db_change_monitor',
    ];
    for (final file in files) {
      final source = file.readAsStringSync();
      for (final forbidden in forbiddenImports) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: '${file.path} must not import $forbidden',
        );
      }
    }
  });

  test('AppCzar infrastructure contains no SQLite mutation statement', () {
    final sources = <File>[
      File(
        'lib/essentials/app_czar/infrastructure/'
        'sqlite_app_czar_observation_reader.dart',
      ),
      File(
        'lib/features/attachments/infrastructure/repositories/'
        'read_only_app_czar_attachment_archive_probe.dart',
      ),
    ].map((file) => file.readAsStringSync()).join('\n');

    expect(
      sources,
      isNot(
        matches(
          RegExp(
            r'\b(INSERT|UPDATE|DELETE|CREATE|DROP|ALTER|REPLACE|VACUUM|REINDEX)\b',
          ),
        ),
      ),
    );
    expect(sources, contains('OpenMode.readOnly'));
    expect(sources, contains('PRAGMA query_only = ON'));
  });

  test('virtual coordinator selection is data and has no constructor seam', () {
    final model = File(
      'lib/essentials/app_czar/domain/app_czar_models.dart',
    ).readAsStringSync();
    final evaluator = File(
      'lib/essentials/app_czar/application/app_czar_evaluator.dart',
    ).readAsStringSync();

    expect(model, contains('enum AppCzarVirtualCoordinator'));
    expect(evaluator, isNot(contains('OnboardingJourneyCoordinator')));
    expect(evaluator, isNot(contains('ArchiveMutationCoordinator')));
    expect(evaluator, isNot(contains('Ball')));
  });

  test('presentation significance cannot become fact-selection authority', () {
    final evaluator = File(
      'lib/essentials/app_czar/application/app_czar_evaluator.dart',
    ).readAsStringSync();
    final presentation = File(
      'lib/essentials/app_czar/application/'
      'app_czar_presentation_projector.dart',
    ).readAsStringSync();
    final harness = File(
      'lib/essentials/app_czar/presentation/app_czar_startup_harness.dart',
    ).readAsStringSync();

    expect(evaluator, isNot(contains('AppCzarPresentationSignificance')));
    expect(harness, isNot(contains('AppCzarTruth')));
    expect(presentation, isNot(contains('AppCzarEvaluator')));
    expect(
      <String>[evaluator, presentation, harness].join('\n'),
      isNot(contains('Full Disk Access')),
    );
  });

  test('only the coordinator host may cross into Data Update presentation', () {
    final files = Directory('lib/essentials/app_czar')
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final source = file.readAsStringSync();
      if (file.path.endsWith('app_czar_startup_harness.dart')) {
        expect(
          source,
          contains(
            '../../app_czar_data_update/application/'
            'app_czar_data_update_controller.dart',
          ),
        );
        expect(
          source,
          contains(
            '../../app_czar_data_update/presentation/'
            'app_czar_data_update_screen.dart',
          ),
        );
        continue;
      }
      expect(
        source,
        isNot(contains('/app_czar_data_update/')),
        reason: '${file.path} must remain observation/evaluation-only',
      );
    }
  });

  test('Data Update has one exact mutation-admission edge', () {
    final files = _dataUpdateFiles();
    const executorPath =
        'lib/essentials/app_czar_data_update/application/'
        'app_czar_data_update_executor_provider.dart';

    for (final file in files) {
      final source = file.readAsStringSync();
      if (file.path == executorPath) {
        expect(source, contains('archiveMutationCoordinatorProvider'));
        expect(source, contains('.runWithCapability<LiveGraphUpdateResult>'));
        expect(
          RegExp(
            r'operation:\s*ArchiveMutationOperation\.liveGraphUpdate',
          ).allMatches(source),
          hasLength(1),
        );
        continue;
      }
      expect(
        source,
        isNot(contains('archiveMutationCoordinatorProvider')),
        reason: '${file.path} must not acquire mutation authority',
      );
      expect(
        source,
        isNot(contains('ArchiveMutationCoordinator')),
        reason: '${file.path} must not define a second mutation coordinator',
      );
    }
  });

  test('Data Update executes only the exact selected mapping', () {
    final controller = File(
      'lib/essentials/app_czar_data_update/application/'
      'app_czar_data_update_controller.dart',
    ).readAsStringSync();

    expect(
      controller,
      contains(
        'assessmentState.assessment?.virtualCoordinator ==\n'
        '      AppCzarVirtualCoordinator.dataUpdate',
      ),
    );
    expect(
      controller,
      isNot(matches(RegExp(r'switch\s*\([^)]*virtualCoordinator'))),
    );
    expect(controller, isNot(contains('AppCzarVirtualCoordinator.onboarding')));
    expect(
      controller,
      isNot(contains('AppCzarVirtualCoordinator.operatingSession')),
    );
    expect(
      controller,
      isNot(contains('AppCzarVirtualCoordinator.sourceAccessRepair')),
    );
  });

  test(
    'Data Update progress is memory-only and cannot publish app semantics',
    () {
      final sources = _dataUpdateFiles()
          .map((file) => file.readAsStringSync())
          .join('\n');
      const forbidden = <String>[
        '/onboarding/',
        '/environment_readiness/',
        '/navigation/',
        'operation_snapshot',
        'OnboardingJourneyCoordinator',
        'StartupApp',
        'messageDataVersionProvider',
        'ready=true',
      ];
      for (final term in forbidden) {
        expect(
          sources,
          isNot(contains(term)),
          reason: 'Data Update must not contain semantic/durable term $term',
        );
      }
    },
  );

  test('only the development restarter owns process-boundary mechanics', () {
    final files = _dataUpdateFiles();
    const restarterPath =
        'lib/essentials/app_czar_data_update/infrastructure/'
        'macos_development_process_restarter.dart';

    for (final file in files) {
      final source = file.readAsStringSync();
      if (file.path == restarterPath) {
        expect(source, contains("import 'dart:io';"));
        expect(source, contains('ProcessStartMode.detached'));
        expect(source, contains('/usr/bin/open -n'));
        expect(source, contains('_terminateCurrentProcess(0)'));
        expect(source, isNot(contains('WD_ELEMENTS')));
        expect(source, isNot(contains('MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT')));
        continue;
      }
      expect(source, isNot(contains("import 'dart:io';")));
      expect(source, isNot(contains('Process.start')));
      expect(source, isNot(contains('exit(')));
    }
  });
}

Iterable<File> _dataUpdateFiles() {
  return Directory('lib/essentials/app_czar_data_update')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
