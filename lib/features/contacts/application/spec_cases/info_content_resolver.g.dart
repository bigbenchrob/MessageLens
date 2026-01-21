// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_content_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$infoContentResolverHash() =>
    r'6683e5b2bd60b8e7eaeca656dc1c2731fb3fbb50';

/// Resolves Contacts informational keys into surface-agnostic content.
///
/// This is the single source of truth for "what does this info key mean?".
///
/// - May evolve to query repositories (e.g., counts, dynamic hints)
/// - May become async when it needs feature data
///
/// Copied from [InfoContentResolver].
@ProviderFor(InfoContentResolver)
final infoContentResolverProvider =
    AutoDisposeNotifierProvider<InfoContentResolver, void>.internal(
      InfoContentResolver.new,
      name: r'infoContentResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$infoContentResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InfoContentResolver = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
