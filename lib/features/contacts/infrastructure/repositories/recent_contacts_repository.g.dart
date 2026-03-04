// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_contacts_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentContactsHash() => r'eb002c791712bb0a66199230e59335de22f03aa8';

/// Provides list of recently accessed contacts (up to 3).
/// Combines overlay DB recent access tracking with working DB participant info.
/// The list persists across sessions via overlay.db.
///
/// ## Behavior
/// - Empty list in virgin state (no contacts picked yet)
/// - Shows up to 3 most recently accessed contacts
/// - Order: most recent first
/// - Persists across app restarts (stored in overlay.db)
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
