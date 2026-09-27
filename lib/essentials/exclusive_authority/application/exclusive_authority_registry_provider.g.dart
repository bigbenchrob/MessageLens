// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exclusive_authority_registry_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$exclusiveAuthorityRegistryHash() =>
    r'c131cf910bc140141af855144e82e651f81738f4';

/// Process-local registry for exact, scoped exclusive-authority tenure.
///
/// It owns only tenure mechanics. Domain policy, scheduling, retries, and
/// presentation remain outside this registry.
///
/// Its supported lifecycle is exactly one [ProviderContainer] lifetime.
/// Production code must not refresh or invalidate this provider. Disposing the
/// container is the sole supported revocation boundary and permanently revokes
/// every tenure issued by that registry lifecycle.
///
/// Copied from [ExclusiveAuthorityRegistry].
@ProviderFor(ExclusiveAuthorityRegistry)
final exclusiveAuthorityRegistryProvider =
    NotifierProvider<
      ExclusiveAuthorityRegistry,
      ExclusiveAuthorityRegistryState
    >.internal(
      ExclusiveAuthorityRegistry.new,
      name: r'exclusiveAuthorityRegistryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$exclusiveAuthorityRegistryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExclusiveAuthorityRegistry =
    Notifier<ExclusiveAuthorityRegistryState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
