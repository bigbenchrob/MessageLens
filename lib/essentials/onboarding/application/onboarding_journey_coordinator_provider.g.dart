// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_journey_coordinator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingJourneyCoordinatorHash() =>
    r'2bb6ab2641d58ed3a149ca4531a56825a4ac5fe3';

/// Sole authority for user-visible Onboarding Journey semantics.
///
/// Environment and operation providers publish evidence. This stable notifier
/// ingests that evidence, validates its currentness, and is the only component
/// that turns it into a user-visible Journey Episode.
///
/// Copied from [OnboardingJourneyCoordinator].
@ProviderFor(OnboardingJourneyCoordinator)
final onboardingJourneyCoordinatorProvider =
    NotifierProvider<
      OnboardingJourneyCoordinator,
      OnboardingJourneyState
    >.internal(
      OnboardingJourneyCoordinator.new,
      name: r'onboardingJourneyCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingJourneyCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingJourneyCoordinator = Notifier<OnboardingJourneyState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
