import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/domain/app_czar_models.dart';
import '../domain/startup_presentation_evidence.dart';

part 'startup_presentation_evidence_inputs.g.dart';

/// Explicit composition input established by the admitted composition root.
@Riverpod(keepAlive: true)
StartupPresentationComposition startupPresentationComposition(Ref ref) {
  return StartupPresentationComposition.startupApp;
}

/// A completed AppCzar assessment already live in the selected composition.
///
/// The default is deliberately absent. Consumers must never construct an
/// assessment controller merely to populate presentation or support evidence.
@Riverpod(keepAlive: true)
AppCzarAssessmentState? startupPresentationAppCzarAssessmentSnapshot(Ref ref) {
  return null;
}
