// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_links_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$manualLinksListHash() => r'128b1323dc786c53db4aec34c68a077cbf080239';

/// Provider that fetches all manual handle-to-participant links
///
/// This joins overlay database overrides with working database to provide
/// enriched display information (handle identifiers, participant names).
///
/// Copied from [manualLinksList].
@ProviderFor(manualLinksList)
final manualLinksListProvider =
    AutoDisposeFutureProvider<List<ManualHandleLink>>.internal(
      manualLinksList,
      name: r'manualLinksListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$manualLinksListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ManualLinksListRef =
    AutoDisposeFutureProviderRef<List<ManualHandleLink>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
