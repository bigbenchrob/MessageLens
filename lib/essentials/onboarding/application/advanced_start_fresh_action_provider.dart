import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../navigation/application/app_navigator_key.dart';
import '../presentation/start_fresh_authorization_dialog.dart';
import 'advanced_start_fresh_action.dart';
import 'advanced_start_fresh_current_state_reader_provider.dart';
import 'advanced_start_fresh_presentation_provider.dart';
import 'start_fresh_service_provider.dart';

part 'advanced_start_fresh_action_provider.g.dart';

@Riverpod(keepAlive: true)
AdvancedStartFreshAction advancedStartFreshAction(Ref ref) {
  return AdvancedStartFreshActionImpl(
    readInstallationState: () {
      return ref
          .read(advancedStartFreshCurrentStateReaderProvider)
          .readCurrentState();
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
    reportLifecycle: (event, {required requestId, detail}) {
      ref
          .read(appLoggerProvider.notifier)
          .info(
            'Advanced Start Fresh lifecycle: ${event.name}',
            source: 'AdvancedStartFresh',
            context: {
              'requestId': requestId,
              if (detail != null) 'detail': detail,
            },
          );
    },
  );
}
