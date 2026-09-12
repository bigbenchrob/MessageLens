import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' as sched;
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show ExternalLibrary;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'config/theme/colors/theme_colors.dart';
import 'config/theme/theme_typography.dart';
import 'essentials/app_mode/feature_level_providers.dart'
    show platformBrightnessProvider, switchableDarkModeProvider;
import 'essentials/archive_environment/application.dart'
    show ArchiveAdmissionService, admittedArchiveAccessAuthorityProvider;
import 'essentials/archive_environment/domain.dart'
    show ArchiveAccessAuthority, ArchiveBuildIdentity, ArchiveIdentityValidator;
import 'essentials/archive_environment/infrastructure.dart'
    show
        DevelopmentArchiveRootOverrideResolver,
        ExactCanonicalArchiveRootPolicy,
        FileSystemArchiveMarkerStore,
        MethodChannelArchiveAdmissionFailurePresenter,
        MethodChannelNativeArchiveClaimReader;
import 'essentials/conversation_graph/feature_level_providers.dart'
    show chatDbChangeMonitorProvider;
import 'essentials/logging/application/diagnostic_report_actions.dart';
import 'essentials/logging/application/flutter_framework_error_reporter.dart';
import 'essentials/logging/feature_level_providers.dart'
    show appLoggerProvider, diagnosticReportExporterProvider;
import 'essentials/navigation/application/router.dart';
import 'essentials/onboarding/domain/message_lens_installation_state.dart';
import 'essentials/onboarding/feature_level_providers.dart'
    show messageLensInstallationStateProvider, startFreshServiceProvider;
import 'essentials/onboarding/infrastructure/compatibility/legacy_complete_installation_erase_journal_compatibility.dart';
import 'essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import 'essentials/onboarding/presentation/start_fresh_authorization_dialog.dart';
import 'essentials/services/startup_flags_service.dart';
import 'essentials/window_state/feature_level_providers.dart'
    show windowStateServiceProvider;
import 'features/presence_iteration_simple/presentation/linear_presence_experiment_host.dart';
import 'frb_generated.dart';

const bool _presenceDevelopmentHarnessEnabled = bool.fromEnvironment(
  'PRESENCE_DEVELOPMENT_HARNESS',
);

/// This method initializes macos_window_utils and styles the window.
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig(
    // toolbarStyle: NSWindowToolbarStyle.unified, // default
    toolbarStyle: NSWindowToolbarStyle.expanded,
  );
  await config.apply();
}

class _MyDelegate extends NSWindowDelegate {
  ProviderContainer? _container;
  Timer? _pendingSave;

  void attachContainer(ProviderContainer container) {
    _container = container;
  }

  @override
  void windowDidMove() {
    super.windowDidMove();
    _scheduleWindowStateSave(includeSize: false);
  }

  @override
  void windowDidEndLiveResize() {
    super.windowDidEndLiveResize();
    _scheduleWindowStateSave(includeSize: true);
  }

  @override
  void windowDidChangeScreen() {
    super.windowDidChangeScreen();
    final container = _container;
    if (container == null) {
      return;
    }

    // Cancel any in-flight save while the window is transitioning between displays.
    _pendingSave?.cancel();

    () async {
      final service = container.read(windowStateServiceProvider);
      await service.reconcileAfterScreenChange();
      _scheduleWindowStateSave(includeSize: false);
    }();
  }

  void _scheduleWindowStateSave({required bool includeSize}) {
    final container = _container;
    if (container != null) {
      _pendingSave?.cancel();
      _pendingSave = Timer(const Duration(milliseconds: 240), () {
        container
            .read(windowStateServiceProvider)
            .saveCurrentWindowState(includeSize: includeSize)
            .catchError((Object error, StackTrace stackTrace) {
              container
                  .read(appLoggerProvider.notifier)
                  .warn(
                    'Failed to save window state: $error',
                    source: 'WindowState',
                    context: {
                      'includeSize': includeSize.toString(),
                      'stack': stackTrace
                          .toString()
                          .split('\n')
                          .take(10)
                          .join('\n'),
                    },
                  );
            });
      });
    }
  }
}

final List<Object> _windowDelegateLifetimeHandles = <Object>[];

Future<ArchiveAccessAuthority> _admitArchive() async {
  const claimReader = MethodChannelNativeArchiveClaimReader();
  final claim = await claimReader.read();
  final applicationSupportDirectory = await getApplicationSupportDirectory();
  const rootOverrideResolver = DevelopmentArchiveRootOverrideResolver();
  final expectedRoot = rootOverrideResolver.resolveExpectedRoot(
    environment: claim.environment,
    defaultRootPath: applicationSupportDirectory.path,
    requireConfiguredOverride:
        claim.buildIdentity == ArchiveBuildIdentity.fdaExperiment,
  );
  final rootPolicy = ExactCanonicalArchiveRootPolicy(
    canonicalRoots: {claim.environment: expectedRoot},
    platformApplicationSupportRoot: applicationSupportDirectory.parent.path,
  );
  final validator = ArchiveIdentityValidator(rootPolicy: rootPolicy);
  validator.validateClaim(claim);
  final markerStore = FileSystemArchiveMarkerStore(
    rootPath: claim.canonicalRootPath,
  );
  final admissionService = ArchiveAdmissionService(
    validator: validator,
    markerStore: markerStore,
  );
  final compatibilityResult =
      await const LegacyCompleteInstallationEraseJournalCompatibility(
        evidenceReader: SqliteMessageLensInstallationEvidenceReader(),
      ).admit(
        canonicalRootPath: claim.canonicalRootPath,
        expectedEnvironment: claim.environment,
        markerStore: markerStore,
        ordinaryAdmission: () => admissionService.admit(claim),
      );
  if (compatibilityResult.disposition !=
      LegacyCompleteInstallationEraseJournalDisposition.noJournal) {
    debugPrint(
      'Legacy Complete Erase journal disposition: '
      '${compatibilityResult.disposition.name}; '
      '${compatibilityResult.diagnostics}',
    );
  }
  return compatibilityResult.authority;
}

Future<void> _reportArchiveAdmissionFailure(Object error) async {
  debugPrint('Archive admission failed: $error');
  if (!Platform.isMacOS) {
    return;
  }

  try {
    await const MethodChannelArchiveAdmissionFailurePresenter().present(error);
  } catch (reportingError) {
    debugPrint('Could not present archive admission failure: $reportingError');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ArchiveAccessAuthority archiveAuthority;
  try {
    archiveAuthority = await _admitArchive();
  } catch (error, stackTrace) {
    // Persistent diagnostics are forbidden before admission.
    debugPrintStack(stackTrace: stackTrace);
    await _reportArchiveAdmissionFailure(error);
    return;
  }

  // Initialize sqflite FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    // Suppress sqflite warning about changing default factory
    runZoned(
      () => databaseFactory = databaseFactoryFfi,
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          if (!line.contains('sqflite warning')) {
            debugPrint(line);
          }
        },
      ),
    );
  }

  // Initialize Rust library for URL preview parsing.
  // FRB's default loader uses Directory.current to resolve the ioDirectory,
  // which breaks when launched via macOS LaunchServices (CWD is /).
  // We resolve the dylib from the app bundle's Frameworks directory first,
  // falling back to the default (works during development from project dir).
  try {
    final bundlePath =
        Platform.resolvedExecutable; // .../MacOS/remember_every_text
    final frameworksDir = Directory(
      '${File(bundlePath).parent.parent.path}/Frameworks',
    );
    final bundledDylib = File(
      '${frameworksDir.path}/attributed_string_decoder.framework/attributed_string_decoder',
    );
    if (bundledDylib.existsSync()) {
      await RustLib.init(
        externalLibrary: ExternalLibrary.open(bundledDylib.path),
      );
    } else {
      await RustLib.init();
    }
  } catch (error) {
    debugPrint(
      'RustLib.init failed: $error — URL preview parsing will be unavailable',
    );
  }

  await _configureMacosWindowUtils();

  final startupFlags = await StartupFlagsService.instance.initialize();
  debugPrint(
    'Startup flags: optionLaunchResetRequested=${startupFlags.optionLaunchResetRequested}',
  );

  // Initialize Media Kit.
  MediaKit.ensureInitialized();

  // Keep the window delegate handle for the app lifetime so macOS window
  // close events keep flowing into the app-shell action boundary.
  final delegate = _MyDelegate();
  _windowDelegateLifetimeHandles.add(
    WindowManipulator.addNSWindowDelegate(delegate),
  );

  final brightness =
      sched.SchedulerBinding.instance.platformDispatcher.platformBrightness;

  // Create provider container.
  final container = ProviderContainer(
    overrides: [
      admittedArchiveAccessAuthorityProvider.overrideWith(
        (ref) => archiveAuthority,
      ),
      // Initialize platform brightness immediately.
      platformBrightnessProvider.overrideWith((ref) => brightness),
    ],
  );

  FlutterError.onError = FlutterError.presentError;
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught platform error before persistent startup: $error');
    debugPrintStack(stackTrace: stack);
    return true;
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: StartupApp(
        startupFlags: startupFlags,
        initializeAfterClassification: (installationState) {
          return _initializePersistentStartup(
            container: container,
            delegate: delegate,
            startupFlags: startupFlags,
            installationState: installationState,
          );
        },
      ),
    ),
  );
}

Future<void> _initializePersistentStartup({
  required ProviderContainer container,
  required _MyDelegate delegate,
  required StartupFlags startupFlags,
  required MessageLensInstallationState installationState,
}) async {
  delegate.attachContainer(container);
  final logger = container.read(appLoggerProvider.notifier);
  logger.info('App launch', source: 'App');
  logger.info(
    'Resolved startup flags',
    source: 'StartupFlags',
    context: {
      'optionLaunchResetRequested': startupFlags.optionLaunchResetRequested
          .toString(),
      'installationKind': installationState.kind.name,
      'installationReason': installationState.reason,
    },
  );

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(deferFlutterFrameworkErrorLog(details, logError: logger.error));
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error(
      error.toString(),
      source: 'PlatformDispatcher',
      context: {'stack': stack.toString().split('\n').take(10).join('\n')},
    );
    return true;
  };

  if (!shouldRestorePersistedWindowStateAfterClassification(
    installationState,
  )) {
    return;
  }

  try {
    await container.read(windowStateServiceProvider).restoreWindowState();
  } catch (error) {
    logger.warn(
      'Failed to restore window state: $error',
      source: 'WindowState',
    );
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    container.read(windowStateServiceProvider).enforceMinSize();
  });
}

bool shouldRestorePersistedWindowStateAfterClassification(
  MessageLensInstallationState installationState,
) {
  return installationState.kind == MessageLensInstallationStateKind.completed;
}

class StartupApp extends ConsumerStatefulWidget {
  const StartupApp({
    required this.startupFlags,
    this.admittedChild = const App(),
    this.initializeAfterClassification,
    super.key,
  });

  final StartupFlags startupFlags;
  final Widget admittedChild;
  final Future<void> Function(MessageLensInstallationState installationState)?
  initializeAfterClassification;

  @override
  ConsumerState<StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends ConsumerState<StartupApp> {
  bool _startupChoiceResolved = false;
  bool _startupAdmissionScheduled = false;
  bool _postClassificationInitializationScheduled = false;
  bool _postClassificationInitializationCompleted = false;
  Object? _postClassificationInitializationError;

  void _continueStartup() {
    if (!mounted || _startupChoiceResolved) {
      return;
    }

    setState(() {
      _startupChoiceResolved = true;
    });
  }

  void _schedulePostClassificationInitialization(
    MessageLensInstallationState installationState,
  ) {
    if (_postClassificationInitializationScheduled) {
      return;
    }

    _postClassificationInitializationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_initializeAfterClassification(installationState));
    });
  }

  Future<void> _initializeAfterClassification(
    MessageLensInstallationState installationState,
  ) async {
    try {
      await widget.initializeAfterClassification?.call(installationState);
    } catch (error, stackTrace) {
      debugPrint('Persistent startup initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      setState(() {
        _postClassificationInitializationError = error;
      });
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _postClassificationInitializationCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_startupChoiceResolved) {
      return widget.admittedChild;
    }

    final themeMode = ref.watch(switchableDarkModeProvider);
    final installationState = ref.watch(messageLensInstallationStateProvider);

    return installationState.when(
      data: (state) {
        if (!_postClassificationInitializationCompleted) {
          _schedulePostClassificationInitialization(state);
          final initializationError = _postClassificationInitializationError;
          if (initializationError != null) {
            return _startupMacosApp(
              themeMode: themeMode,
              child: _StartupClassificationFailure(error: initializationError),
            );
          }
          return _startupLoadingApp(themeMode);
        }

        final mustPauseStartup =
            widget.startupFlags.optionLaunchResetRequested ||
            state.requiresStartupAttention;
        if (!mustPauseStartup) {
          if (!_startupAdmissionScheduled) {
            _startupAdmissionScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _continueStartup();
            });
          }
          return widget.admittedChild;
        }

        return MacosApp(
          title: 'remember_that_text',
          theme: MacosThemeData.light().copyWith(),
          darkTheme: MacosThemeData.dark().copyWith(),
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: _StartupDialogHost(
            installationState: state,
            onChoiceHandled: _continueStartup,
          ),
        );
      },
      loading: () {
        return _startupLoadingApp(themeMode);
      },
      error: (error, _) {
        return _startupMacosApp(
          themeMode: themeMode,
          child: _StartupClassificationFailure(error: error),
        );
      },
    );
  }

  MacosApp _startupLoadingApp(ThemeMode themeMode) {
    return _startupMacosApp(
      themeMode: themeMode,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProgressCircle(),
            SizedBox(height: 16),
            Text('Checking databases…'),
          ],
        ),
      ),
    );
  }

  MacosApp _startupMacosApp({
    required ThemeMode themeMode,
    required Widget child,
  }) {
    return MacosApp(
      title: 'remember_that_text',
      theme: MacosThemeData.light().copyWith(),
      darkTheme: MacosThemeData.dark().copyWith(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: child,
    );
  }
}

class _StartupDialogHost extends ConsumerStatefulWidget {
  const _StartupDialogHost({
    required this.installationState,
    required this.onChoiceHandled,
  });

  final MessageLensInstallationState installationState;
  final VoidCallback onChoiceHandled;

  @override
  ConsumerState<_StartupDialogHost> createState() => _StartupDialogHostState();
}

class _StartupDialogHostState extends ConsumerState<_StartupDialogHost> {
  bool _dialogShown = false;
  bool _isStartingFresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_showStartupDialog());
    });
  }

  Future<void> _showStartupDialog() async {
    if (!mounted || _dialogShown) {
      return;
    }

    _dialogShown = true;
    final colors = ref.read(themeColorsProvider.notifier);
    final action = await showDialog<_StartupDialogAction>(
      context: context,
      barrierDismissible: false,
      barrierColor: colors.surfaces.canvas,
      builder: (_) {
        return _StartupResetConfirmationDialog(
          installationState: widget.installationState,
        );
      },
    );

    if (!mounted) {
      return;
    }

    final logger = ref.read(appLoggerProvider.notifier);
    switch (action ?? _StartupDialogAction.quit) {
      case _StartupDialogAction.continueStartup:
        logger.info('Startup continued', source: 'StartupDialog');
        widget.onChoiceHandled();
        return;
      case _StartupDialogAction.startFresh:
        await _confirmAndStartFresh();
        return;
      case _StartupDialogAction.exportLogs:
        logger.info('Export Logs clicked', source: 'StartupDialog');
        return;
      case _StartupDialogAction.quit:
        logger.info('Startup stopped by user', source: 'StartupDialog');
        exit(0);
    }
  }

  Future<void> _confirmAndStartFresh() async {
    final colors = ref.read(themeColorsProvider.notifier);
    final confirmed = await showStartFreshAuthorizationDialog(
      context,
      barrierColor: colors.surfaces.canvas,
    );
    if (!mounted) {
      return;
    }
    if (!confirmed) {
      _dialogShown = false;
      await _showStartupDialog();
      return;
    }

    setState(() {
      _isStartingFresh = true;
    });

    try {
      final service = await ref.read(startFreshServiceProvider.future);
      await service.startFresh();
      if (!mounted) {
        return;
      }
      widget.onChoiceHandled();
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .error(
            'Start Fresh failed: $error',
            source: 'StartupDialog',
            context: {'stack': stackTrace.toString()},
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _isStartingFresh = false;
      });
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("MessageLens couldn't start fresh"),
            content: const Text(
              'Your Apple Messages, Contacts, customizations, and archived '
              'attachments were not targeted. You can try again or export '
              'logs for diagnosis.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      _dialogShown = false;
      await _showStartupDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: _isStartingFresh
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProgressCircle(),
                  SizedBox(height: 16),
                  Text(
                    "I'm preparing a clean MessageLens setup. Your Messages "
                    "and Contacts won't be changed.",
                  ),
                ],
              ),
            )
          : const SizedBox.expand(),
    );
  }
}

enum _StartupDialogAction { continueStartup, exportLogs, startFresh, quit }

class _StartupResetConfirmationDialog extends ConsumerStatefulWidget {
  const _StartupResetConfirmationDialog({required this.installationState});

  final MessageLensInstallationState installationState;

  @override
  ConsumerState<_StartupResetConfirmationDialog> createState() =>
      _StartupResetConfirmationDialogState();
}

class _StartupResetConfirmationDialogState
    extends ConsumerState<_StartupResetConfirmationDialog> {
  bool _isExporting = false;
  String? _feedbackMessage;
  bool _exportFailed = false;

  Future<void> _exportLogs() async {
    if (_isExporting) {
      return;
    }

    final logger = ref.read(appLoggerProvider.notifier);
    setState(() {
      _isExporting = true;
      _feedbackMessage = null;
      _exportFailed = false;
    });

    logger.info('Export Logs clicked', source: 'StartupDialog');

    final diagnosticReportExporter = await ref.read(
      diagnosticReportExporterProvider.future,
    );
    final result = await exportDiagnosticReport(diagnosticReportExporter);
    if (!mounted) {
      return;
    }

    final exportPath = result.exportPath;
    if (exportPath == null) {
      logger.error('Startup log export failed', source: 'StartupDialog');
      setState(() {
        _isExporting = false;
        _exportFailed = true;
        _feedbackMessage =
            'Log export failed. The startup dialog will remain open.';
      });
      return;
    }

    logger.info(
      'Startup log export succeeded',
      source: 'StartupDialog',
      context: {'exportPath': exportPath},
    );
    setState(() {
      _isExporting = false;
      _exportFailed = false;
      _feedbackMessage = 'Logs exported to:\n$exportPath';
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    final title = switch (widget.installationState.kind) {
      MessageLensInstallationStateKind.virgin => 'No setup to reset',
      MessageLensInstallationStateKind.resumable =>
        'MessageLens setup can continue',
      MessageLensInstallationStateKind.completed =>
        'MessageLens setup is complete',
      MessageLensInstallationStateKind.abandoned =>
        "This MessageLens setup wasn't completed",
      MessageLensInstallationStateKind.remediationRequired =>
        'This MessageLens setup needs attention',
    };
    final message = switch (widget.installationState.kind) {
      MessageLensInstallationStateKind.virgin =>
        'MessageLens has not begun importing data. Continue to start setup.',
      MessageLensInstallationStateKind.resumable =>
        'MessageLens can continue from a safe boundary. You may also start '
            'again with a clean import and conversation index.',
      MessageLensInstallationStateKind.completed =>
        'The imported messages and conversation data reconcile. No reset is '
            'needed.',
      MessageLensInstallationStateKind.abandoned =>
        'You can start again with this version. Your Messages and Contacts on '
            "this Mac won't be changed.",
      MessageLensInstallationStateKind.remediationRequired =>
        'MessageLens found inconsistent or unreadable installation evidence. '
            'It will not continue or remove preserved data automatically.',
    };

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: colors.surfaces.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: typography.title2.copyWith(
                  color: colors.content.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: typography.body.copyWith(
                  color: colors.content.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (widget.installationState.mayContinue) ...[
                OutlinedButton(
                  onPressed: _isExporting
                      ? null
                      : () {
                          Navigator.of(
                            context,
                          ).pop(_StartupDialogAction.continueStartup);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.content.textPrimary,
                    side: BorderSide(color: colors.lines.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: _isExporting ? null : _exportLogs,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.content.textPrimary,
                  side: BorderSide(color: colors.lines.borderSubtle),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_isExporting ? 'Exporting Logs...' : 'Export Logs'),
              ),
              const SizedBox(height: 12),
              if (widget.installationState.mayStartFresh)
                FilledButton(
                  onPressed: _isExporting
                      ? null
                      : () {
                          Navigator.of(
                            context,
                          ).pop(_StartupDialogAction.startFresh);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.buttons.primaryBackground,
                    foregroundColor: colors.buttons.primaryForeground,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Start Fresh'),
                ),
              if (!widget.installationState.mayContinue) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isExporting
                      ? null
                      : () {
                          Navigator.of(context).pop(_StartupDialogAction.quit);
                        },
                  child: const Text('Quit MessageLens'),
                ),
              ],
              if (_feedbackMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _feedbackMessage!,
                  style: typography.caption.copyWith(
                    color: _exportFailed
                        ? colors.content.textPrimary
                        : colors.content.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StartupClassificationFailure extends ConsumerWidget {
  const _StartupClassificationFailure({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            "MessageLens couldn't determine whether this installation is "
            'safe to open. No data was changed.\n\n$error',
            style: typography.body.copyWith(color: colors.content.textPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class App extends ConsumerWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(switchableDarkModeProvider);

    if (kDebugMode && _presenceDevelopmentHarnessEnabled) {
      return MacosApp(
        title: 'Presence Iteration Simple',
        theme: MacosThemeData.light().copyWith(),
        darkTheme: MacosThemeData.dark().copyWith(),
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: const LinearPresenceExperimentHost(),
      );
    }

    final router = ref.watch(goRouterProvider);
    ref.watch(chatDbChangeMonitorProvider);

    return MacosApp.router(
      title: 'remember_that_text',
      theme: MacosThemeData.light().copyWith(),
      darkTheme: MacosThemeData.dark().copyWith(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
