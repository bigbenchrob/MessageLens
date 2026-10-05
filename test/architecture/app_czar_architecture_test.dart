import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';

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
      File(
        'lib/features/attachments/infrastructure/repositories/'
        'read_only_app_czar_attachment_coverage_probe.dart',
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

  test('attachment coverage remains observation-only and acquires no Ball', () {
    final source = File(
      'lib/features/attachments/infrastructure/repositories/'
      'read_only_app_czar_attachment_coverage_probe.dart',
    ).readAsStringSync();

    const forbidden = <String>[
      'ArchiveMutationCoordinator',
      'archiveMutationCoordinatorProvider',
      'ArchiveMutationCapability',
      'runWithCapability',
      'mutationTenure',
      'Ball',
      'OperationSnapshot',
      'updateSucceeded',
      'preservationComplete',
      'lastRepairSucceeded',
      'needsRepair',
    ];
    for (final term in forbidden) {
      expect(
        source,
        isNot(contains(term)),
        reason: 'Probe must not contain $term',
      );
    }
    expect(source, contains('OpenMode.readOnly'));
    expect(source, contains('PRAGMA query_only = ON'));
  });

  test('availability and coverage remain distinct Operating facts', () {
    final model = File(
      'lib/essentials/app_czar/domain/app_czar_models.dart',
    ).readAsStringSync();
    final operating = File(
      'lib/essentials/app_czar_operating_session/application/'
      'app_czar_operating_session_controller.dart',
    ).readAsStringSync();

    expect(model, contains('attachmentArchiveAvailable'));
    expect(model, contains('attachmentCoverageComplete'));
    expect(
      RegExp(
        r'AppCzarFactId\.attachmentArchiveAvailable',
      ).allMatches(operating),
      hasLength(1),
    );
    expect(
      RegExp(
        r'AppCzarFactId\.attachmentCoverageComplete',
      ).allMatches(operating),
      hasLength(1),
    );
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

  test('only the coordinator host may cross into executable presentation', () {
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
        expect(
          source,
          contains(
            '../../app_czar_operating_session/application/'
            'app_czar_operating_session_controller.dart',
          ),
        );
        expect(
          source,
          contains(
            '../../app_czar_operating_session/presentation/'
            'app_czar_operating_session_app.dart',
          ),
        );
        expect(
          source,
          contains(
            '../../app_czar_source_access/application/'
            'app_czar_source_access_controller.dart',
          ),
        );
        expect(
          source,
          contains(
            '../../app_czar_source_access/presentation/'
            'app_czar_source_access_screen.dart',
          ),
        );
        continue;
      }
      expect(
        source,
        isNot(contains('/app_czar_data_update/')),
        reason: '${file.path} must remain observation/evaluation-only',
      );
      expect(
        source,
        isNot(contains('/app_czar_source_access/')),
        reason: '${file.path} must remain observation/evaluation-only',
      );
      expect(
        source,
        isNot(contains('/app_czar_operating_session/')),
        reason: '${file.path} must remain observation/evaluation-only',
      );
    }
  });

  test('every AppCzar disposition has one explicit execution category', () {
    final sources = <File>[
      ..._dataUpdateFiles(),
      ..._sourceAccessFiles(),
      ..._operatingSessionFiles(),
    ].map((file) => file.readAsStringSync()).join('\n');
    final harness = File(
      'lib/essentials/app_czar/presentation/app_czar_startup_harness.dart',
    ).readAsStringSync();

    const classifications =
        <AppCzarVirtualCoordinator, _AppCzarExecutionCategory>{
          AppCzarVirtualCoordinator.dataUpdate:
              _AppCzarExecutionCategory.executableTopLevelCoordinator,
          AppCzarVirtualCoordinator.sourceAccessRepair:
              _AppCzarExecutionCategory.executableTopLevelCoordinator,
          AppCzarVirtualCoordinator.operatingSession:
              _AppCzarExecutionCategory.executableAdmittedSession,
          AppCzarVirtualCoordinator.onboarding:
              _AppCzarExecutionCategory.virtualOnly,
          AppCzarVirtualCoordinator.attachmentArchiveRepair:
              _AppCzarExecutionCategory.virtualOnly,
          AppCzarVirtualCoordinator.localDataRepair:
              _AppCzarExecutionCategory.virtualOnly,
          AppCzarVirtualCoordinator.diagnosticReview:
              _AppCzarExecutionCategory.virtualOnly,
        };

    expect(
      classifications.keys.toSet(),
      AppCzarVirtualCoordinator.values.toSet(),
    );
    expect(
      classifications.values
          .where(
            (category) =>
                category ==
                _AppCzarExecutionCategory.executableTopLevelCoordinator,
          )
          .length,
      2,
    );
    expect(
      classifications.values
          .where(
            (category) =>
                category == _AppCzarExecutionCategory.executableAdmittedSession,
          )
          .length,
      1,
    );
    expect(harness, contains('appCzarDataUpdateControllerProvider'));
    expect(harness, contains('appCzarSourceAccessControllerProvider'));
    expect(harness, contains('appCzarOperatingSessionControllerProvider'));

    expect(
      RegExp(r'bool shouldExecuteAppCzar').allMatches(sources),
      hasLength(3),
    );
    expect(sources, contains('shouldExecuteAppCzarDataUpdate'));
    expect(sources, contains('shouldExecuteAppCzarSourceAccessRepair'));
    expect(sources, contains('shouldExecuteAppCzarOperatingSession'));
    expect(sources, isNot(contains('shouldExecuteAppCzarOnboarding')));
    expect(sources, isNot(contains('shouldExecuteAppCzarAttachmentRepair')));
    expect(sources, isNot(contains('shouldExecuteAppCzarLocalDataRepair')));
    expect(sources, isNot(contains('shouldExecuteAppCzarDiagnosticReview')));
    expect(
      sources,
      isNot(matches(RegExp(r'execute\s*\([^)]*AppCzarVirtualCoordinator'))),
    );
    expect(
      sources,
      isNot(matches(RegExp(r'switch\s*\([^)]*virtualCoordinator'))),
    );
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

  test('Source Access Repair has bounded observation-only jurisdiction', () {
    final sources = _sourceAccessFiles()
        .map((file) => file.readAsStringSync())
        .join('\n');
    const forbidden = <String>[
      'ArchiveMutationCoordinator',
      'archiveMutationCoordinatorProvider',
      'ArchiveMutationOperation',
      'runWithCapability',
      'operation_snapshot',
      'OnboardingJourneyCoordinator',
      'onboardingJourneyCoordinatorProvider',
      'messageDataVersionProvider',
      'environment_readiness',
      '/navigation/',
      'SharedPreferences',
      'sqlite3',
      'TCC.db',
      'tccutil',
      'Process.run',
      'Process.start',
      'Timer.periodic',
      'appCzarDataUpdateControllerProvider',
      'appCzarDataUpdateExecutorProvider',
      'AppCzarVirtualCoordinator.operatingSession',
    ];
    for (final term in forbidden) {
      expect(
        sources,
        isNot(contains(term)),
        reason: 'Source Access Repair must not contain $term',
      );
    }
    expect(
      sources,
      isNot(matches(RegExp(r'\bBall\b'))),
      reason: 'Source Access Repair must not acquire the mutation Ball',
    );
  });

  test('Source Access Repair reuses only narrow qualified seams', () {
    const controllerPath =
        'lib/essentials/app_czar_source_access/application/'
        'app_czar_source_access_controller.dart';
    for (final file in _sourceAccessFiles()) {
      final source = file.readAsStringSync();
      if (file.path == controllerPath) {
        expect(
          source,
          contains(
            '../../app_czar_data_update/application/'
            'app_czar_process_restarter_provider.dart',
          ),
        );
        expect(
          source,
          contains(
            '../../onboarding/application/'
            'real_fda_settings_opening_authority_provider.dart',
          ),
        );
        expect(
          source,
          contains(
            '.read(appCzarObservationReaderProvider)\n          .readSource()',
          ),
        );
        continue;
      }
      expect(source, isNot(contains('/app_czar_data_update/')));
      expect(source, isNot(contains('/onboarding/')));
    }
  });

  test('Source Access Repair copy cannot claim Full Disk Access state', () {
    final screen = File(
      'lib/essentials/app_czar_source_access/presentation/'
      'app_czar_source_access_screen.dart',
    ).readAsStringSync();
    final normalized = screen.toLowerCase();

    expect(normalized, isNot(contains('full disk access is off')));
    expect(normalized, isNot(contains('full disk access is on')));
    expect(normalized, isNot(contains('permission repaired')));
    expect(normalized, contains('cannot determine from this evidence whether'));
  });

  test('Operating Session keeps one bounded internal jurisdiction', () {
    final files = _operatingSessionFiles().toList();
    final sources = files.map((file) => file.readAsStringSync()).join('\n');
    const forbidden = <String>[
      '/onboarding/',
      '/environment_readiness/',
      'production_macos_app_shell',
      'chat_db_change_monitor',
      'ChatDbChangeMonitor',
      'AdvancedStartFresh',
      'appCzarDataUpdateControllerProvider',
      'appCzarSourceAccessControllerProvider',
      'StartupApp',
      'Timer.periodic',
    ];
    for (final term in forbidden) {
      expect(
        sources,
        isNot(contains(term)),
        reason: 'Operating Session must not contain $term',
      );
    }
    expect(sources, contains('MessageLensWorkspaceShell'));
    expect(sources, contains('windowStateServiceProvider'));
    expect(
      sources,
      isNot(matches(RegExp(r'switch\s*\([^)]*virtualCoordinator'))),
    );
    expect(
      sources,
      isNot(matches(RegExp(r'execute\s*\([^)]*AppCzarVirtualCoordinator'))),
    );
  });

  test('Operating live update has one exact mutation-admission edge', () {
    const executorPath =
        'lib/essentials/app_czar_operating_session/application/'
        'app_czar_operating_live_update_executor_provider.dart';
    final files = _operatingSessionFiles().toList();
    final sources = files.map((file) => file.readAsStringSync()).join('\n');

    expect(RegExp(r'\.runWithCapability<').allMatches(sources), hasLength(1));
    expect(
      RegExp(
        r'operation:\s*ArchiveMutationOperation\.liveGraphUpdate',
      ).allMatches(sources),
      hasLength(1),
    );
    for (final file in files) {
      final source = file.readAsStringSync();
      if (file.path == executorPath) {
        expect(source, contains('archiveMutationCoordinatorProvider'));
        expect(source, contains('liveGraphUpdateWorkerProvider.future'));
        expect(source, contains('await worker.run('));
        expect(source, contains('.runWithCapability<LiveGraphUpdateResult>'));
        continue;
      }
      expect(
        source,
        isNot(contains('.runWithCapability<')),
        reason: '${file.path} must not acquire mutation authority',
      );
      expect(
        source,
        isNot(contains('ArchiveMutationCapability')),
        reason: '${file.path} must not retain a mutation capability',
      );
      expect(
        source,
        isNot(contains('ArchiveMutationOperation.liveGraphUpdate')),
        reason: '${file.path} must not name a second mutation edge',
      );
    }
  });

  test('Operating currentness has one-shot observation and exact taxonomy', () {
    final controller = File(
      'lib/essentials/app_czar_operating_session/application/'
      'app_czar_operating_currentness_controller.dart',
    ).readAsStringSync();
    final models = File(
      'lib/essentials/app_czar_operating_session/domain/'
      'app_czar_operating_currentness_models.dart',
    ).readAsStringSync();

    expect(controller, contains('Timer(_cadence'));
    expect(controller, isNot(contains('Timer.periodic')));
    expect(controller, contains('_activeFlight'));
    expect(controller, contains('stopAndDrain()'));
    expect(controller, contains('readCoverage()'));
    expect(controller, contains('appCzarProcessRestarterProvider'));
    const dispositions = <String>[
      'noChange',
      'sourceAhead',
      'sourceUnreadable',
      'sourceUnknown',
      'sourceUnstable',
      'localContradiction',
      'transient',
    ];
    for (final disposition in dispositions) {
      expect(models, contains(disposition));
    }
    expect(
      RegExp(
            r'enum AppCzarOperatingCurrentnessDisposition\s*\{([^}]*)\}',
            multiLine: true,
          )
          .firstMatch(models)![1]!
          .split(',')
          .where((value) => value.trim().isNotEmpty),
      hasLength(dispositions.length),
    );
  });

  test('Operating exit and replacement explicitly drain exact tenure', () {
    final session = File(
      'lib/essentials/app_czar_operating_session/application/'
      'app_czar_operating_session_controller.dart',
    ).readAsStringSync();
    final app = File(
      'lib/essentials/app_czar_operating_session/presentation/'
      'app_czar_operating_session_app.dart',
    ).readAsStringSync();
    final state = File(
      'lib/essentials/app_czar_operating_session/domain/'
      'app_czar_operating_session_state.dart',
    ).readAsStringSync();

    expect(state, contains('draining'));
    expect(state, contains('ownsOperatingShell'));
    expect(session, contains('.stopAndDrain()'));
    expect(session, contains('await drain'));
    expect(app, contains('session.ownsOperatingShell'));
    expect(app, contains('await stopAndDrain(occurrence)'));
    expect(
      app,
      contains(
        'appCzarOperatingCurrentnessControllerProvider(\n'
        '                occurrence,\n'
        '              ).notifier',
      ),
    );
  });

  test('Operating shell core has no legacy semantic authority imports', () {
    final neutralShell = File(
      'lib/essentials/navigation/presentation/view/macos_app_shell.dart',
    ).readAsStringSync();
    final productionShell = File(
      'lib/essentials/navigation/presentation/view/'
      'production_macos_app_shell.dart',
    ).readAsStringSync();
    final productionRouter = File(
      'lib/essentials/navigation/application/router.dart',
    ).readAsStringSync();

    expect(neutralShell, contains('class MessageLensWorkspaceShell'));
    expect(neutralShell, isNot(contains('/onboarding/')));
    expect(
      neutralShell,
      isNot(contains('onboardingJourneyCoordinatorProvider')),
    );
    expect(neutralShell, isNot(contains('OnboardingCenterPanelSyncObserver')));
    expect(neutralShell, isNot(contains('AdvancedStartFreshOverlayHost')));
    expect(neutralShell, isNot(contains('chatDbChangeMonitorProvider')));
    expect(productionShell, contains('onboardingJourneyCoordinatorProvider'));
    expect(productionShell, contains('OnboardingCenterPanelSyncObserver'));
    expect(productionShell, contains('AdvancedStartFreshOverlayHost'));
    expect(productionRouter, contains('production_macos_app_shell.dart'));
  });

  test('exact development gate owns neutral-history and reset policies', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final neutralShell = File(
      'lib/essentials/navigation/presentation/view/macos_app_shell.dart',
    ).readAsStringSync();
    final historyCoverageTrack = File(
      'lib/essentials/navigation/presentation/layout/'
      'message_history_coverage_page_track_plan.dart',
    ).readAsStringSync();
    const exactDevelopmentGate =
        '!ref.watch(attachmentArchiveAdoptionExecutionEnabledProvider)';
    expect(
      RegExp(
        r'sidebarNavigationRestorationEnabledProvider\.overrideWith[\s\S]*?'
        r'attachmentArchiveAdoptionExecutionEnabledProvider',
      ).hasMatch(mainSource),
      isTrue,
    );
    expect(
      RegExp(
        r'settingsResetMessageDataActionAvailableProvider\.overrideWith[\s\S]*?'
        r'attachmentArchiveAdoptionExecutionEnabledProvider',
      ).hasMatch(mainSource),
      isTrue,
    );
    expect(
      mainSource,
      contains(
        'sidebarNavigationRestorationEnabledProvider.overrideWith((ref) {\n'
        '        return $exactDevelopmentGate;\n'
        '      }),',
      ),
    );
    expect(
      mainSource,
      contains(
        'settingsResetMessageDataActionAvailableProvider.overrideWith((ref) {\n'
        '        return $exactDevelopmentGate;\n'
        '      }),',
      ),
    );
    expect(
      neutralShell,
      contains('settingsResetMessageDataActionAvailableProvider'),
    );
    expect(
      historyCoverageTrack,
      contains(
        'resetMessageDataActionAvailable: resetMessageDataActionAvailable',
      ),
    );
  });

  test('window delegate authority begins only after Operating admission', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final harness = File(
      'lib/essentials/app_czar/presentation/app_czar_startup_harness.dart',
    ).readAsStringSync();

    expect(mainSource, contains('onAppCzarOperatingAdmitted: ()'));
    expect(
      mainSource,
      isNot(
        matches(
          RegExp(
            r'startupPresentation\s*==\s*'
            r'MessageLensStartupPresentation\.appCzarHarness[\s\S]{0,160}'
            r'delegate\.attachContainer',
          ),
        ),
      ),
    );
    expect(harness, contains('operatingSession.isAdmitted'));
    expect(harness, contains('widget.onOperatingAdmitted?.call()'));
    expect(harness, contains('operatingSession.isEntryInFlight'));
  });

  test('pre-Operating packages cannot construct display identities', () {
    final sources =
        <File>[
              ...Directory(
                'lib/essentials/app_czar',
              ).listSync(recursive: true, followLinks: false).whereType<File>(),
              ..._dataUpdateFiles(),
              ..._sourceAccessFiles(),
            ]
            .where((file) => file.path.endsWith('.dart'))
            .map((file) => file.readAsStringSync())
            .join('\n');

    expect(sources, isNot(contains('displayIdentityResolverProvider')));
    expect(sources, isNot(contains('display_identity_resolver_provider.dart')));
  });
}

enum _AppCzarExecutionCategory {
  executableTopLevelCoordinator,
  executableAdmittedSession,
  virtualOnly,
}

Iterable<File> _dataUpdateFiles() {
  return Directory('lib/essentials/app_czar_data_update')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

Iterable<File> _sourceAccessFiles() {
  return Directory('lib/essentials/app_czar_source_access')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

Iterable<File> _operatingSessionFiles() {
  return Directory('lib/essentials/app_czar_operating_session')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
