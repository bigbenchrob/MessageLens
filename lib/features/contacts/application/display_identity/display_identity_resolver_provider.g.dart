// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_identity_resolver_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$displayIdentityResolverHash() =>
    r'3e91c9cfa34e97c41aa1ee19860b3ef5e9cd5f4d';

/// Semantic display-identity boundary.
///
/// This resolver answers "what should the user see?", not "which database row
/// owns this information?". Row ids and handle values are inputs/provenance;
/// the output is an app-facing identity label.
///
/// Copied from [displayIdentityResolver].
@ProviderFor(displayIdentityResolver)
final displayIdentityResolverProvider =
    AutoDisposeFutureProvider<DisplayIdentityResolver>.internal(
      displayIdentityResolver,
      name: r'displayIdentityResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$displayIdentityResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DisplayIdentityResolverRef =
    AutoDisposeFutureProviderRef<DisplayIdentityResolver>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
