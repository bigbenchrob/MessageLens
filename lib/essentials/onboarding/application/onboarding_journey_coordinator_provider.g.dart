// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_journey_coordinator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingJourneyCoordinatorHash() =>
    r'767ba8a9b0ecea7d33a1d5958319178b97dc1069';

/// Sole authority for the active typed Onboarding Journey Episode.
///
/// Prerequisite providers, durable operation state, lifecycle callbacks, and
/// widgets contribute evidence or intent. This coordinator applies blocker
/// priority and transition policy, admits operational work through the archive
/// mutation boundary, and publishes exactly one [OnboardingJourneyState].
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
