import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart' show databaseDirectoryPath;
import '../../db_importers/presentation/view_model/db_import_control_provider.dart';
import '../domain/onboarding_status.dart';
import 'database_existence_checker.dart';

part 'onboarding_gate_provider.g.dart';

/// Controls the onboarding overlay lifecycle.
///
/// On [build], checks whether both import and working databases exist with data.
/// If not, exposes [OnboardingStatus.awaitingUserAction] so the overlay appears.
///
/// [startImportAndMigration] delegates to [DbImportControlViewModel] and
/// watches its state to transition through importing → migrating → complete.
@Riverpod(keepAlive: true)
class OnboardingGate extends _$OnboardingGate {
  static const _checker = DatabaseExistenceChecker();

  @override
  OnboardingStatus build() {
    final hasData = _checker.hasPopulatedDatabases(databaseDirectoryPath);
    if (hasData) {
      return OnboardingStatus.notNeeded;
    }
    return OnboardingStatus.awaitingUserAction;
  }

  /// Kick off the full import + migration pipeline.
  ///
  /// Calls [startImport] then [startMigration] separately so the overlay
  /// can show the correct phase, and passes `skipImportCheck: true` to
  /// prevent the recursive-loop bug in startMigration's unimported-data
  /// guard. Wrapped in try/catch so the user is **never** stranded.
  Future<void> startImportAndMigration() async {
    if (state != OnboardingStatus.awaitingUserAction) {
      return;
    }

    // ── Import phase ──
    state = OnboardingStatus.importing;
    // Wait until the frame has actually painted so the overlay's
    // _ProgressContent widget is mounted and ref.watch-ing
    // dbImportControlViewModelProvider.  A plain Future.delayed(Duration.zero)
    // fires before the frame pipeline, which means the widget isn't
    // watching yet and the auto-dispose provider may be a stale instance.
    await _waitForEndOfFrame();
    try {
      await ref.read(dbImportControlViewModelProvider.notifier).startImport();
    } catch (_) {
      state = OnboardingStatus.complete;
      return;
    }

    // ── Migration phase ──
    state = OnboardingStatus.migrating;
    await _waitForEndOfFrame();
    try {
      await ref
          .read(dbImportControlViewModelProvider.notifier)
          .startMigration(skipImportCheck: true);
    } catch (_) {
      // Swallow — land on complete so user can dismiss.
    }

    state = OnboardingStatus.complete;
  }

  /// Wait until the current frame has finished painting.
  ///
  /// Unlike [Future.delayed] with [Duration.zero] (which fires between
  /// microtasks, before the frame pipeline), this uses
  /// [WidgetsBinding.addPostFrameCallback] to guarantee that layout and
  /// paint have completed — meaning any widgets that depend on our state
  /// change have already mounted and started watching providers.
  Future<void> _waitForEndOfFrame() {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });
    return completer.future;
  }

  /// Dismiss the overlay.
  ///
  /// Deferred to the next frame so the [ModalBarrier] in the overlay is not
  /// removed during an active gesture callback (avoids the
  /// `!_debugDuringDeviceUpdate` assertion in mouse_tracker.dart).
  ///
  /// Does not navigate — the center panel stays empty until the user
  /// picks something from the sidebar.
  void dismiss() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state = OnboardingStatus.notNeeded;
    });
  }
}
