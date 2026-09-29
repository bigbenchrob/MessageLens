// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_journey_coordinator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingJourneyCoordinatorHash() =>
    r'c233417571f262325da27ec3f73b49150ef1e23f';

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
