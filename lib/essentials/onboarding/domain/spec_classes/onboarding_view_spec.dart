import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_view_spec.freezed.dart';

@freezed
abstract class OnboardingSpec with _$OnboardingSpec {
  const factory OnboardingSpec.devPanel() = _DevPanel;
}
