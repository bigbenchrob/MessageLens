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
      File(
        'lib/features/attachments/infrastructure/repositories/'
        'sqlite_required_attachment_evidence_reader.dart',
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

  test('attachment coverage and repairability remain observation-only', () {
    final probe = File(
      'lib/features/attachments/infrastructure/repositories/'
      'read_only_app_czar_attachment_coverage_probe.dart',
    ).readAsStringSync();
    final repairabilityReader = File(
      'lib/features/attachments/application/'
      'attachment_repairability_evidence_reader.dart',
    ).readAsStringSync();
    final reader = File(
      'lib/features/attachments/infrastructure/repositories/'
      'sqlite_required_attachment_evidence_reader.dart',
    ).readAsStringSync();
    final source = '$probe\n$repairabilityReader\n$reader';

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
      'debtBaseline',
      'grandfather',
      'waiverGranted',
      'coverageExemption',
    ];
    for (final term in forbidden) {
      expect(
        source,
        isNot(contains(term)),
        reason: 'Probe must not contain $term',
      );
    }
    expect(probe, contains('RequiredAttachmentEvidenceReader'));
    expect(probe, contains('AttachmentRepairabilityEvidenceReader'));
    expect(probe, isNot(contains('JOIN message_to_attachment')));
    expect(
      repairabilityReader,
      contains('RequiredAttachmentEvidenceReader _requiredEvidenceReader'),
    );
    expect(
      repairabilityReader,
      contains('_requiredEvidenceReader.readSummary'),
    );
    expect(repairabilityReader, contains('_requiredEvidenceReader.readPage'));
    expect(reader, contains('OpenMode.readOnly'));
    expect(reader, contains('PRAGMA query_only = ON'));
  });

  test('availability coverage and repair opportunity stay distinct facts', () {
    final model = File(
      'lib/essentials/app_czar/domain/app_czar_models.dart',
    ).readAsStringSync();
    final operating = File(
      'lib/essentials/app_czar_operating_session/application/'
      'app_czar_operating_session_controller.dart',
    ).readAsStringSync();

    expect(model, contains('attachmentArchiveAvailable'));
    expect(model, contains('attachmentCoverageComplete'));
    expect(model, contains('attachmentRepairOpportunityPresent'));
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
    expect(
      RegExp(
        r'AppCzarFactId\.attachmentRepairOpportunityPresent',
      ).allMatches(operating),
      hasLength(1),
    );
    expect(operating, contains('coverageTruth != AppCzarTruth.trueValue'));
    expect(operating, contains('coverageTruth != AppCzarTruth.falseValue'));
    expect(operating, contains('archive.repairability.isOperatingSafe'));
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
            '../../app_czar_attachment_archive_repair/application/'
            'app_czar_attachment_archive_repair_controller.dart',
          ),
        );
        expect(
          source,
          contains(
            '../../app_czar_attachment_archive_repair/presentation/'
            'app_czar_attachment_archive_repair_screen.dart',
          ),
        );
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
            '../../app_czar_diagnostic_review/application/'
            'app_czar_diagnostic_review_controller.dart',
          ),
        );
        expect(
          source,
          contains(
            '../../app_czar_diagnostic_review/presentation/'
            'app_czar_diagnostic_review_screen.dart',
          ),
        );
        expect(
          source,
          contains(
            '../../app_czar_local_data_repair/application/'
            'app_czar_local_data_repair_controller.dart',
          ),
        );
        expect(
          source,
          contains(
            '../../app_czar_local_data_repair/presentation/'
            'app_czar_local_data_repair_screen.dart',
          ),
        );
        expect(
          source,
          contains(
            '../../app_czar_onboarding/application/'
            'app_czar_onboarding_controller.dart',
          ),
        );
        expect(
          source,
          contains(
            '../../app_czar_onboarding/presentation/'
            'app_czar_onboarding_screen.dart',
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
        isNot(contains('/app_czar_attachment_archive_repair/')),
        reason: '${file.path} must remain observation/evaluation-only',
      );
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
      expect(
        source,
        isNot(contains('/app_czar_local_data_repair/')),
        reason: '${file.path} must remain observation/evaluation-only',
      );
      expect(
        source,
        isNot(contains('/app_czar_onboarding/')),
        reason: '${file.path} must remain observation/evaluation-only',
      );
      expect(
        source,
        isNot(contains('/app_czar_diagnostic_review/')),
        reason: '${file.path} must remain observation/evaluation-only',
      );
    }
  });

  test('every AppCzar disposition has one explicit execution category', () {
    final sources = <File>[
      ..._attachmentArchiveRepairFiles(),
      ..._dataUpdateFiles(),
      ..._sourceAccessFiles(),
      ..._operatingSessionFiles(),
      ..._onboardingFiles(),
      ..._localDataRepairFiles(),
      ..._diagnosticReviewFiles(),
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
              _AppCzarExecutionCategory.executableTopLevelCoordinator,
          AppCzarVirtualCoordinator.attachmentArchiveRepair:
              _AppCzarExecutionCategory.executableTopLevelCoordinator,
          AppCzarVirtualCoordinator.localDataRepair:
              _AppCzarExecutionCategory.executableTopLevelCoordinator,
          AppCzarVirtualCoordinator.diagnosticReview:
              _AppCzarExecutionCategory.executableTopLevelCoordinator,
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
      6,
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
    expect(
      harness,
      contains('appCzarAttachmentArchiveRepairControllerProvider'),
    );
    expect(harness, contains('appCzarOperatingSessionControllerProvider'));
    expect(harness, contains('appCzarOnboardingControllerProvider'));
    expect(harness, contains('appCzarLocalDataRepairControllerProvider'));
    expect(harness, contains('appCzarDiagnosticReviewControllerProvider'));

    expect(
      RegExp(r'bool shouldExecuteAppCzar').allMatches(sources),
      hasLength(7),
    );
    expect(sources, contains('shouldExecuteAppCzarAttachmentArchiveRepair'));
    expect(sources, contains('shouldExecuteAppCzarDataUpdate'));
    expect(sources, contains('shouldExecuteAppCzarSourceAccessRepair'));
    expect(sources, contains('shouldExecuteAppCzarOperatingSession'));
    expect(sources, contains('shouldExecuteAppCzarOnboarding'));
    expect(sources, contains('shouldExecuteAppCzarLocalDataRepair'));
    expect(sources, contains('shouldExecuteAppCzarDiagnosticReview'));
    expect(sources, isNot(contains('shouldExecuteAppCzarAttachmentRepair')));
    expect(
      sources,
      isNot(matches(RegExp(r'execute\s*\([^)]*AppCzarVirtualCoordinator'))),
    );
    expect(
      sources,
      isNot(matches(RegExp(r'switch\s*\([^)]*virtualCoordinator'))),
    );
  });

  test('Diagnostic Review has bounded read-only lifecycle jurisdiction', () {
    final files = _diagnosticReviewFiles().toList();
    final sources = files.map((file) => file.readAsStringSync()).join('\n');
    const controllerPath =
        'lib/essentials/app_czar_diagnostic_review/application/'
        'app_czar_diagnostic_review_controller.dart';
    const forbidden = <String>[
      'ArchiveMutationCoordinator',
      'archiveMutationCoordinatorProvider',
      'ArchiveMutationOperation',
      'ArchiveMutationCapability',
      'runWithCapability',
      'MessageDataResetService',
      'startFresh',
      'operation_snapshot',
      'OnboardingJourneyCoordinator',
      'onboardingJourneyCoordinatorProvider',
      'environment_readiness',
      'pipeline_incident',
      'historicalArchive',
      'removeHistorical',
      'attachmentArchiveAdoption',
      'attachmentArchiveRepairExecutor',
      'appCzarObservationReaderProvider',
      'sourceScopedImportDatabaseProvider',
      'driftConversationGraphDatabaseProvider',
      'overlayDatabaseProvider',
      'Timer(',
      'Timer.periodic',
      '.runAgain(',
      "import 'dart:io';",
      'Process.start',
      'Process.run',
      'exit(',
      'Clipboard',
    ];

    expect(
      RegExp(r'bool shouldExecuteAppCzarDiagnosticReview').allMatches(sources),
      hasLength(1),
    );
    for (final term in forbidden) {
      expect(
        sources,
        isNot(contains(term)),
        reason: 'Diagnostic Review must not contain $term',
      );
    }
    expect(sources, isNot(matches(RegExp(r'\bBall\b'))));
    for (final file in files) {
      final source = file.readAsStringSync();
      if (file.path == controllerPath) {
        expect(source, contains('appCzarProcessRestarterProvider'));
        continue;
      }
      expect(source, isNot(contains('appCzarProcessRestarterProvider')));
    }
  });

  test('Diagnostic Review is the first completed-assessment host branch', () {
    final harness = File(
      'lib/essentials/app_czar/presentation/app_czar_startup_harness.dart',
    ).readAsStringSync();
    final diagnosticPredicate = harness.indexOf(
      'shouldExecuteAppCzarDiagnosticReview(assessment)',
    );
    final diagnosticWatch = harness.indexOf(
      'appCzarDiagnosticReviewControllerProvider',
    );
    final specialistWatches = <String>[
      'appCzarLocalDataRepairControllerProvider',
      'appCzarDataUpdateControllerProvider',
      'appCzarOnboardingControllerProvider',
      'appCzarSourceAccessControllerProvider',
      'appCzarAttachmentArchiveRepairControllerProvider',
    ].map(harness.indexOf);

    expect(diagnosticPredicate, greaterThanOrEqualTo(0));
    expect(diagnosticWatch, greaterThan(diagnosticPredicate));
    for (final specialistWatch in specialistWatches) {
      expect(specialistWatch, greaterThan(diagnosticWatch));
    }
    expect(
      RegExp(
        r'return const _AppCzarDiagnosticReviewLifecycleHost\(\);',
      ).allMatches(harness),
      hasLength(1),
    );
    expect(
      harness,
      isNot(matches(RegExp(r'switch\s*\([^)]*virtualCoordinator'))),
    );
  });

  test('Diagnostic projection remains pure and presentation-only', () {
    final projector = File(
      'lib/essentials/app_czar/application/'
      'app_czar_presentation_projector.dart',
    ).readAsStringSync();
    final screen = File(
      'lib/essentials/app_czar_diagnostic_review/presentation/'
      'app_czar_diagnostic_review_screen.dart',
    ).readAsStringSync();

    expect(projector, contains('projectDiagnostic('));
    expect(projector, isNot(contains('AppCzarEvaluator')));
    expect(projector, isNot(contains('Provider')));
    expect(projector, isNot(contains('sqlite')));
    expect(screen, isNot(contains('AppCzarFactId.')));
    expect(screen, isNot(contains('AppCzarTruth.')));
    expect(screen, isNot(contains('AppCzarVirtualCoordinator.')));
    expect(screen, isNot(contains("const Text('Copy")));
    expect(screen, isNot(contains("const Text('Export")));
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

  test('process restart follows AppCzar composition rather than adoption', () {
    final provider = File(
      'lib/essentials/app_czar_data_update/application/'
      'app_czar_process_restarter_provider.dart',
    ).readAsStringSync();

    expect(provider, contains('AppCzarDevelopmentCompositionPolicy'));
    expect(provider, contains('admittedArchiveAccessAuthorityProvider'));
    expect(
      provider,
      isNot(contains('attachmentArchiveAdoptionExecutionEnabledProvider')),
    );
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

  test('Attachment Archive Repair has bounded specialist jurisdiction', () {
    final sources = _attachmentArchiveRepairFiles()
        .map((file) => file.readAsStringSync())
        .join('\n');
    const forbidden = <String>[
      '/onboarding/',
      '/environment_readiness/',
      '/navigation/',
      'operation_snapshot',
      'OnboardingJourneyCoordinator',
      'onboardingJourneyCoordinatorProvider',
      'appCzarDataUpdateControllerProvider',
      'appCzarSourceAccessControllerProvider',
      'appCzarOperatingSessionControllerProvider',
      'chatDbChangeMonitorProvider',
      'SharedPreferences',
      'Timer.periodic',
      'repairCursor',
      'lastRepairSucceeded',
      'lastRepairFailed',
      'repairSucceeded',
      'repairFailed',
    ];
    for (final term in forbidden) {
      expect(
        sources,
        isNot(contains(term)),
        reason: 'Attachment Archive Repair must not contain $term',
      );
    }
    expect(sources, isNot(contains("import 'dart:io';")));
    expect(sources, isNot(contains('Process.start')));
    expect(sources, isNot(contains('Directory(')));
    expect(sources, isNot(contains('File(')));
  });

  test('Local Data Repair has one typed mutation-admission edge', () {
    const executorPath =
        'lib/essentials/app_czar_local_data_repair/application/'
        'app_czar_local_data_repair_executor_provider.dart';
    final files = _localDataRepairFiles().toList();
    final sources = files.map((file) => file.readAsStringSync()).join('\n');

    expect(RegExp(r'\.runWithCapability<').allMatches(sources), hasLength(1));
    expect(
      RegExp(
        r'operation:\s*ArchiveMutationOperation\.localDataRepair',
      ).allMatches(sources),
      hasLength(1),
    );
    for (final file in files) {
      final source = file.readAsStringSync();
      if (file.path == executorPath) {
        expect(source, contains('archiveMutationCoordinatorProvider'));
        expect(source, contains('readLocalDataRepairSafety'));
        expect(source, contains('hasSameMutationBinding'));
        expect(source, contains('resetActiveDerivedDataForLocalDataRepair'));
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
    }
  });

  test('Local Data Repair remains separate from semantic authorities', () {
    final sources = _localDataRepairFiles()
        .map((file) => file.readAsStringSync())
        .join('\n');
    const forbidden = <String>[
      'OnboardingJourneyCoordinator',
      'onboardingJourneyCoordinatorProvider',
      'AdvancedStartFresh',
      'startFresh',
      'operation_snapshot',
      'historicalArchive',
      'removeHistorical',
      'messageDataVersionProvider',
      'SharedPreferences',
      'Timer.periodic',
      'AppCzarVirtualCoordinator.diagnosticReview',
      'AppCzarVirtualCoordinator.onboarding',
    ];
    for (final term in forbidden) {
      expect(
        sources,
        isNot(contains(term)),
        reason: 'Local Data Repair must not contain $term',
      );
    }
    expect(
      sources,
      isNot(matches(RegExp(r'switch\s*\([^)]*virtualCoordinator'))),
    );
  });

  test(
    'Attachment Archive Repair executes only its exact selected mapping',
    () {
      final controller = File(
        'lib/essentials/app_czar_attachment_archive_repair/application/'
        'app_czar_attachment_archive_repair_controller.dart',
      ).readAsStringSync();

      expect(
        controller,
        contains('AppCzarVirtualCoordinator.attachmentArchiveRepair'),
      );
      expect(
        controller,
        contains('AppCzarDiagnosisKind.attachmentArchiveCoverageIncomplete'),
      );
      expect(
        RegExp(
          r'AppCzarFactId\.attachmentCoverageComplete[\s\S]{0,100}'
          r'AppCzarTruth\.falseValue',
        ).hasMatch(controller),
        isTrue,
      );
      expect(
        RegExp(
          r'AppCzarFactId\.attachmentArchiveAvailable[\s\S]{0,100}'
          r'AppCzarTruth\.trueValue',
        ).hasMatch(controller),
        isTrue,
      );
      expect(
        controller,
        contains('AppCzarFactId.attachmentRepairOpportunityPresent'),
      );
      expect(
        controller,
        contains('repairOpportunityTruth == AppCzarTruth.trueValue'),
      );
      expect(
        controller,
        contains('repairOpportunityTruth == AppCzarTruth.falseValue'),
      );
      expect(controller, contains('archive.hasCoherentCoverageBinding'));
      expect(controller, contains('archive.hasCoherentRepairabilityBinding'));
      expect(
        controller,
        isNot(matches(RegExp(r'switch\s*\([^)]*virtualCoordinator'))),
      );
    },
  );

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
    expect(controller, contains('_attachmentEvidencePermitsOperating'));
    expect(controller, contains('archive.repairability.isOperatingSafe'));
    expect(
      controller,
      isNot(
        matches(
          RegExp(
            r'coverage\.condition\s*==\s*'
            r'AppCzarAttachmentCoverageCondition\.complete',
          ),
        ),
      ),
    );
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

  test('attachment debt authority uses only current evidence', () {
    final sources = <String>[
      File(
        'lib/features/attachments/application/'
        'attachment_repairability_evidence_reader.dart',
      ).readAsStringSync(),
      File(
        'lib/essentials/app_czar/application/app_czar_evaluator.dart',
      ).readAsStringSync(),
      File(
        'lib/essentials/app_czar_operating_session/application/'
        'app_czar_operating_session_controller.dart',
      ).readAsStringSync(),
      File(
        'lib/essentials/app_czar_operating_session/application/'
        'app_czar_operating_currentness_controller.dart',
      ).readAsStringSync(),
    ].join('\n');

    for (final term in <String>[
      'debtBaseline',
      'historicalDebt',
      'grandfathered',
      'attachmentWaiver',
      'coverageExemption',
      'lastRepairSucceeded',
      'previousDebtCount',
    ]) {
      expect(
        sources,
        isNot(contains(term)),
        reason: 'Current attachment jurisdiction must not contain $term.',
      );
    }
    expect(sources, contains('sourceAbsentCount'));
    expect(sources, contains('sourceUnknownCount'));
    expect(sources, contains('recordBackedRecoveryCount'));
    expect(sources, contains('unsafeOrConflictingCount'));
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

  test('exit drains remain scoped to the visible AppCzar jurisdiction', () {
    final harness = File(
      'lib/essentials/app_czar/presentation/app_czar_startup_harness.dart',
    ).readAsStringSync();
    final operatingApp = File(
      'lib/essentials/app_czar_operating_session/presentation/'
      'app_czar_operating_session_app.dart',
    ).readAsStringSync();

    expect(harness, isNot(contains('with WidgetsBindingObserver')));
    expect(harness, isNot(contains('didRequestAppExit')));
    expect(
      harness,
      contains('class _AppCzarAttachmentArchiveRepairLifecycleHost'),
    );
    expect(harness, contains('class _AppCzarOnboardingLifecycleHost'));
    expect(
      harness,
      contains('return const _AppCzarAttachmentArchiveRepairLifecycleHost();'),
    );
    expect(RegExp(r'AppLifecycleListener\(').allMatches(harness), hasLength(4));
    expect(
      harness,
      contains('appCzarDiagnosticReviewControllerProvider.notifier'),
    );
    expect(
      harness,
      contains('appCzarAttachmentArchiveRepairControllerProvider.notifier'),
    );
    expect(harness, contains('.stopAndDrain();'));
    expect(harness, contains('appCzarOnboardingControllerProvider.notifier'));
    expect(
      harness,
      contains('appCzarLocalDataRepairControllerProvider.notifier'),
    );
    expect(
      harness,
      isNot(contains('appCzarOperatingCurrentnessControllerProvider')),
    );
    expect(
      RegExp(r'AppLifecycleListener\(').allMatches(operatingApp),
      hasLength(1),
    );
    expect(
      operatingApp,
      contains('appCzarOperatingCurrentnessControllerProvider'),
    );
    expect(
      operatingApp,
      isNot(contains('appCzarAttachmentArchiveRepairControllerProvider')),
    );
  });

  test('AppCzar composition cannot import legacy presentation authority', () {
    final sources = <File>[
      ...Directory(
        'lib/essentials/app_czar',
      ).listSync(recursive: true, followLinks: false).whereType<File>(),
      ...Directory(
        'lib/essentials/app_czar_onboarding',
      ).listSync(recursive: true, followLinks: false).whereType<File>(),
      ..._localDataRepairFiles(),
      ..._dataUpdateFiles(),
      ..._sourceAccessFiles(),
      ..._attachmentArchiveRepairFiles(),
      ..._operatingSessionFiles(),
      ..._diagnosticReviewFiles(),
    ].where((file) => file.path.endsWith('.dart'));

    const forbidden = <String>[
      'production_macos_app_shell.dart',
      'onboarding_overlay.dart',
      'onboarding_journey_path.dart',
      'onboarding_center_panel_sync_observer.dart',
      'onboardingJourneyCoordinatorProvider',
      'onboardingGateProvider',
      'OnboardingOverlay',
      'OnboardingCenterPanelSync',
      'environmentReadinessSurfaceProvider',
      'environmentReadinessActionsProvider',
    ];
    for (final file in sources) {
      final source = file.readAsStringSync();
      for (final term in forbidden) {
        expect(
          source,
          isNot(contains(term)),
          reason: '${file.path} must not depend on legacy authority $term',
        );
      }
    }
  });

  test('production keeps the legacy semantic shell composition', () {
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
    expect(productionShell, contains('journey.requiresOperationOverlay'));
    expect(productionShell, contains('const OnboardingOverlay()'));
    expect(productionRouter, contains('production_macos_app_shell.dart'));
  });

  test('development composition owns neutral-history and reset policies', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final compositionPolicy = File(
      'lib/essentials/app_czar/application/'
      'app_czar_development_composition_policy.dart',
    ).readAsStringSync();
    final adoptionGate = File(
      'lib/features/attachments/application/'
      'attachment_archive_adoption_enablement_provider.dart',
    ).readAsStringSync();
    final neutralShell = File(
      'lib/essentials/navigation/presentation/view/macos_app_shell.dart',
    ).readAsStringSync();
    final historyCoverageTrack = File(
      'lib/essentials/navigation/presentation/layout/'
      'message_history_coverage_page_track_plan.dart',
    ).readAsStringSync();
    expect(mainSource, contains('AppCzarDevelopmentCompositionPolicy'));
    expect(mainSource, contains('.admits(archiveAuthority)'));
    expect(
      mainSource,
      isNot(contains('attachmentArchiveAdoptionExecutionEnabledProvider')),
    );
    expect(
      mainSource,
      contains(
        'sidebarNavigationRestorationEnabledProvider.overrideWith((ref) {\n'
        '        return !appCzarDevelopmentCompositionEnabled;\n'
        '      }),',
      ),
    );
    expect(
      mainSource,
      contains(
        'settingsResetMessageDataActionAvailableProvider.overrideWith((ref) {\n'
        '        return !appCzarDevelopmentCompositionEnabled;\n'
        '      }),',
      ),
    );
    expect(compositionPolicy, contains('ArchiveAccessAuthority? authority'));
    expect(compositionPolicy, contains('if (authority == null)'));
    expect(compositionPolicy, isNot(contains('WD_ELEMENTS')));
    expect(compositionPolicy, isNot(contains('archiveInstanceId')));
    expect(adoptionGate, contains('_authorizedDevelopmentRoot'));
    expect(adoptionGate, contains('_authorizedDevelopmentArchiveInstanceId'));
    expect(adoptionGate, contains('identity.canonicalRootPath'));
    expect(adoptionGate, contains('identity.archiveInstanceId.value'));
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

  test('production eligibility is pure and activation is closed off', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final eligibilityPolicy = File(
      'lib/essentials/app_czar/application/'
      'app_czar_production_composition_eligibility_policy.dart',
    ).readAsStringSync();
    final activationPolicy = File(
      'lib/essentials/app_czar/application/'
      'production_app_czar_activation.dart',
    ).readAsStringSync();
    final restarter = File(
      'lib/essentials/app_czar_data_update/application/'
      'app_czar_process_restarter_provider.dart',
    ).readAsStringSync();
    final adoptionGate = File(
      'lib/features/attachments/application/'
      'attachment_archive_adoption_enablement_provider.dart',
    ).readAsStringSync();

    expect(eligibilityPolicy, contains('ArchiveAccessAuthority? authority'));
    expect(eligibilityPolicy, contains('ArchiveEnvironment.production'));
    expect(
      eligibilityPolicy,
      contains('ArchiveBuildIdentity.productionRelease'),
    );
    expect(eligibilityPolicy, isNot(contains('canonicalRootPath')));
    expect(eligibilityPolicy, isNot(contains('archiveInstanceId')));
    expect(eligibilityPolicy, isNot(contains('Provider')));
    expect(eligibilityPolicy, isNot(contains('Platform.environment')));
    expect(eligibilityPolicy, isNot(contains('SharedPreferences')));
    expect(eligibilityPolicy, isNot(contains('Ball')));
    expect(
      activationPolicy,
      contains('static const disabled = ProductionAppCzarActivation._();'),
    );
    expect(activationPolicy, contains('bool get isEnabled => false;'));
    expect(activationPolicy, isNot(contains('fromEnvironment')));
    expect(activationPolicy, isNot(contains('Platform.environment')));
    expect(activationPolicy, isNot(contains('SharedPreferences')));
    expect(
      mainSource,
      contains(
        'const productionAppCzarActivation = '
        'ProductionAppCzarActivation.disabled;',
      ),
    );
    expect(
      mainSource,
      contains('AppCzarProductionCompositionEligibilityPolicy'),
    );
    expect(
      mainSource.indexOf('archiveAuthority = await _admitArchive()'),
      lessThan(
        mainSource.indexOf(
          'AppCzarProductionCompositionEligibilityPolicy().isEligible',
        ),
      ),
    );
    expect(
      RegExp(
        r'ProductionAppCzarActivation\.[A-Za-z_]\w*',
      ).allMatches(mainSource).map((match) => match.group(0)).toList(),
      <String>['ProductionAppCzarActivation.disabled'],
    );
    expect(restarter, contains('AppCzarDevelopmentCompositionPolicy'));
    expect(
      restarter,
      isNot(contains('AppCzarProductionCompositionEligibilityPolicy')),
    );
    expect(adoptionGate, contains('_authorizedDevelopmentRoot'));
    expect(adoptionGate, contains('_authorizedDevelopmentArchiveInstanceId'));
    expect(
      mainSource,
      isNot(contains('attachmentArchiveAdoptionExecutionEnabledProvider')),
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
              ..._attachmentArchiveRepairFiles(),
              ..._onboardingFiles(),
              ..._localDataRepairFiles(),
              ..._diagnosticReviewFiles(),
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
}

Iterable<File> _attachmentArchiveRepairFiles() {
  return Directory('lib/essentials/app_czar_attachment_archive_repair')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
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

Iterable<File> _onboardingFiles() {
  return Directory('lib/essentials/app_czar_onboarding')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

Iterable<File> _localDataRepairFiles() {
  return Directory('lib/essentials/app_czar_local_data_repair')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

Iterable<File> _diagnosticReviewFiles() {
  return Directory('lib/essentials/app_czar_diagnostic_review')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
