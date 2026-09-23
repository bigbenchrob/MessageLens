// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deterministic_recovery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deterministicRecoveryHash() =>
    r'a6a8ed51267043a524af007419158478246c554f';

/// Orchestrates the full deterministic historical attachment recovery pipeline:
/// Phase 1 (snapshot reader) → Phase 2 (mapper) → Phase 3 (archive writer).
///
/// Copied from [DeterministicRecovery].
@ProviderFor(DeterministicRecovery)
final deterministicRecoveryProvider =
    NotifierProvider<
      DeterministicRecovery,
      DeterministicRecoveryState
    >.internal(
      DeterministicRecovery.new,
      name: r'deterministicRecoveryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deterministicRecoveryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeterministicRecovery = Notifier<DeterministicRecoveryState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
