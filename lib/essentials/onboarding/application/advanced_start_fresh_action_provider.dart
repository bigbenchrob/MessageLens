import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../navigation/application/app_navigator_key.dart';
import '../domain/startup_installation_validation.dart';
import '../presentation/start_fresh_authorization_dialog.dart';
import 'advanced_start_fresh_action.dart';
import 'advanced_start_fresh_presentation_provider.dart';
import 'message_lens_installation_state_provider.dart';
import 'start_fresh_service_provider.dart';

part 'advanced_start_fresh_action_provider.g.dart';

@Riverpod(keepAlive: true)
AdvancedStartFreshAction advancedStartFreshAction(Ref ref) {
  StartupInstallationValidationState? terminalValidation;
  final terminalValidationCompleter =
      Completer<StartupInstallationValidationState>();

  void captureValidation(AsyncValue<StartupInstallationValidationState> next) {
    next.whenData((validation) {
      if (!_isTerminalValidation(validation)) {
        return;
      }
      terminalValidation = validation;
      if (!terminalValidationCompleter.isCompleted) {
        terminalValidationCompleter.complete(validation);
      }
    });
    if (next.hasError && !terminalValidationCompleter.isCompleted) {
      terminalValidationCompleter.completeError(
        next.error!,
        next.stackTrace ?? StackTrace.current,
      );
    }
  }

  captureValidation(ref.read(messageLensInstallationStateProvider));
  ref.listen(messageLensInstallationStateProvider, (_, next) {
    captureValidation(next);
  });

  return AdvancedStartFreshActionImpl(
    readInstallationState: () async {
      // Startup already established completed-installation eligibility. Reuse
      // its terminal typed result so opening the confirmation cannot repeat
      // archive inspection. StartFreshService performs full validation at the
      // mutation boundary.
      final validation =
          terminalValidation ?? await terminalValidationCompleter.future;
      final installationState = validation.resolvedInstallationState;
      if (installationState == null) {
        throw StateError(
          'Startup installation validation did not resolve an installation '
          'state.',
        );
      }
      return installationState;
    },
    requestAuthorization: () async {
      final context = appNavigatorKey.currentContext;
      if (context == null || !context.mounted) {
        throw StateError(
          'Start Fresh authorization requires an active navigator context.',
        );
      }
      final colors = ref.read(themeColorsProvider.notifier);
      return showStartFreshAuthorizationDialog(
        context,
        barrierColor: colors.surfaces.canvas,
      );
    },
    readStartFreshService: () {
      return ref.read(startFreshServiceProvider.future);
    },
    presentation: ref.read(
      advancedStartFreshPresentationControllerProvider.notifier,
    ),
    waitForPresentationFrame: () => SchedulerBinding.instance.endOfFrame,
    reportFailure: (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .error(
            'Advanced Start Fresh failed: $error',
            source: 'AdvancedStartFresh',
            context: {'stack': stackTrace.toString()},
          );
    },
  );
}

bool _isTerminalValidation(StartupInstallationValidationState validation) {
  return validation is StartupAdmissionGranted ||
      validation is StartupAdmissionWithheld ||
      validation is StartupIntegrityValidationFailed ||
      validation is StartupValidationBlocked;
}
