// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_rack_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cassetteRackStateHash() => r'058018f73d4a5a73d390655cda46a23bcae9110c';

/// A Riverpod notifier managing the current [CassetteRack].
///
/// This class follows the class‑based provider syntax described in the
/// Riverpod documentation.  It exposes methods to mutate the rack in
/// response to user interactions (pushing new cassettes, updating existing
/// ones, truncating the stack, etc.).  Because the notifier’s state is
/// immutable, each mutation produces a new [CassetteRack] instance.
///
/// Copied from [CassetteRackState].
@ProviderFor(CassetteRackState)
final cassetteRackStateProvider =
    AutoDisposeNotifierProvider<CassetteRackState, CassetteRack>.internal(
      CassetteRackState.new,
      name: r'cassetteRackStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cassetteRackStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CassetteRackState = AutoDisposeNotifier<CassetteRack>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
