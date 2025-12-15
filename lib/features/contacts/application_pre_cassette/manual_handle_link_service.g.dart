// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_handle_link_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$manualHandleLinkServiceHash() =>
    r'd60ccb399c626990cbe4d8d7e854b76eb9bd2218';

/// Service for managing manual handle-to-contact links
///
/// This service coordinates between overlay and working databases to:
/// 1. Create user-defined handle-participant associations
/// 2. Update the working database projection
/// 3. Rebuild affected message indexes
/// 4. Invalidate cached providers
///
/// Copied from [ManualHandleLinkService].
@ProviderFor(ManualHandleLinkService)
final manualHandleLinkServiceProvider =
    AutoDisposeNotifierProvider<ManualHandleLinkService, void>.internal(
      ManualHandleLinkService.new,
      name: r'manualHandleLinkServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$manualHandleLinkServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ManualHandleLinkService = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
