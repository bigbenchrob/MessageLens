// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spam_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$spamHandlesHash() => r'c778d791e6e45980a65f994882119a8d62b6f12d';

/// Provider for managing spam/blacklisted handles
///
/// Copied from [spamHandles].
@ProviderFor(spamHandles)
final spamHandlesProvider =
    AutoDisposeFutureProvider<List<SpamHandleInfo>>.internal(
      spamHandles,
      name: r'spamHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$spamHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SpamHandlesRef = AutoDisposeFutureProviderRef<List<SpamHandleInfo>>;
String _$spamManagementHash() => r'40667c218dd7fcaf37a7c84e67e526b99b0badb9';

/// Provider for spam management operations
///
/// Copied from [SpamManagement].
@ProviderFor(SpamManagement)
final spamManagementProvider =
    AutoDisposeAsyncNotifierProvider<SpamManagement, void>.internal(
      SpamManagement.new,
      name: r'spamManagementProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$spamManagementHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SpamManagement = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
