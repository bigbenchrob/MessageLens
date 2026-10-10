import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/startup_presentation_evidence.dart';
import 'app_czar_startup_presentation_evidence_provider.dart';
import 'startup_app_startup_presentation_evidence_provider.dart';
import 'startup_presentation_evidence_inputs.dart';

part 'startup_presentation_evidence_provider.g.dart';

@riverpod
StartupPresentationEvidence startupPresentationEvidence(Ref ref) {
  return switch (ref.watch(startupPresentationCompositionProvider)) {
    StartupPresentationComposition.startupApp => ref.watch(
      startupAppStartupPresentationEvidenceProvider,
    ),
    StartupPresentationComposition.appCzar => ref.watch(
      appCzarStartupPresentationEvidenceProvider,
    ),
  };
}

@riverpod
Future<StartupSupportEvidence> startupSupportEvidence(Ref ref) {
  return switch (ref.watch(startupPresentationCompositionProvider)) {
    StartupPresentationComposition.startupApp => ref.watch(
      startupAppStartupSupportEvidenceProvider.future,
    ),
    StartupPresentationComposition.appCzar => ref.watch(
      appCzarStartupSupportEvidenceProvider.future,
    ),
  };
}
