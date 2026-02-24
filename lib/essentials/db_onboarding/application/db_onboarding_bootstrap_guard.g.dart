// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_onboarding_bootstrap_guard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dbOnboardingRequiredHash() =>
    r'b2cc34918f58dfbab450467d683e56f549b765d5';

/// Checks whether database onboarding is required.
///
/// Returns `true` if the working database has zero messages and
/// onboarding has not been completed, indicating a first-run scenario.
///
/// Copied from [dbOnboardingRequired].
@ProviderFor(dbOnboardingRequired)
final dbOnboardingRequiredProvider = AutoDisposeFutureProvider<bool>.internal(
  dbOnboardingRequired,
  name: r'dbOnboardingRequiredProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dbOnboardingRequiredHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DbOnboardingRequiredRef = AutoDisposeFutureProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
