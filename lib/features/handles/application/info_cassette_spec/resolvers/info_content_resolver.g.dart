// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_content_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handlesInfoContentResolverHash() =>
    r'096e8c534987bd916965d1f0a1db219d1fb57793';

/// Resolves Handles informational keys into surface-agnostic content.
///
/// This is the single source of truth for "what does this info key mean?".
///
/// - May evolve to query repositories (e.g., counts, dynamic hints)
/// - May become async when it needs feature data
///
/// Copied from [HandlesInfoContentResolver].
@ProviderFor(HandlesInfoContentResolver)
final handlesInfoContentResolverProvider =
    AutoDisposeNotifierProvider<HandlesInfoContentResolver, void>.internal(
      HandlesInfoContentResolver.new,
      name: r'handlesInfoContentResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handlesInfoContentResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HandlesInfoContentResolver = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
