import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../features/messages/domain/spec_classes/messages_view_spec.dart';
import '../../../onboarding/domain/import_spec.dart';
import '../../../onboarding/domain/spec_classes/onboarding_view_spec.dart';

part 'view_spec.freezed.dart';

@freezed
abstract class ViewSpec with _$ViewSpec {
  const factory ViewSpec.messages(MessagesSpec spec) = _ViewMessages;
  const factory ViewSpec.import(ImportSpec spec) = _ViewImport;
  const factory ViewSpec.onboarding(OnboardingSpec spec) = _ViewOnboarding;
}

/// Whether this ViewSpec represents content that operates independently of
/// the sidebar cassette rack (e.g. import/migration panels).
///
/// When true, the sidebar should be replaced with a contextual overlay
/// rather than showing stale cassette state.
extension ViewSpecSidebarAwareness on ViewSpec {
  bool get isSidebarIndependent => switch (this) {
    _ViewImport() => true,
    _ViewOnboarding() => true,
    _ => false,
  };
}
