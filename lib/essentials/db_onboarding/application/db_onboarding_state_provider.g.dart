// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_onboarding_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dbOnboardingStateNotifierHash() =>
    r'091fafdcf743da52c2f202f9150cdba84b7edcc8';

/// Manages the onboarding state machine and coordinates with import/migration.
///
/// This provider maps the detailed internal import and migration stages to
/// user-friendly phases displayed in the stepper UI.
///
/// Copied from [DbOnboardingStateNotifier].
@ProviderFor(DbOnboardingStateNotifier)
final dbOnboardingStateNotifierProvider =
    NotifierProvider<DbOnboardingStateNotifier, DbOnboardingState>.internal(
      DbOnboardingStateNotifier.new,
      name: r'dbOnboardingStateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dbOnboardingStateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DbOnboardingStateNotifier = Notifier<DbOnboardingState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
