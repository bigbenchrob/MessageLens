// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_contacts_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentContactsHash() => r'c420fdc228bfd27438e16b27018d7b824080b537';

/// Provides list of recently accessed contacts (up to 6).
/// Combines overlay DB recent access tracking with working DB participant info.
///
/// Copied from [recentContacts].
@ProviderFor(recentContacts)
final recentContactsProvider =
    AutoDisposeFutureProvider<List<RecentContactSummary>>.internal(
      recentContacts,
      name: r'recentContactsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentContactsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentContactsRef =
    AutoDisposeFutureProviderRef<List<RecentContactSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
