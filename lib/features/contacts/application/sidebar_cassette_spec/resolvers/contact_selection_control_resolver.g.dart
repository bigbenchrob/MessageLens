// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_selection_control_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactSelectionControlResolverHash() =>
    r'91cf1445a8dc37ed44924642c2906445bcd57332';

/// Resolves a contact selection control cassette.
///
/// This resolver produces a compact "Change contact" control view model
/// that displays the selected contact and provides re-entry to the picker.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Determines which widget builder to use
/// - Does NOT construct widgets itself (delegates to widget builder)
///
/// ## Visual Role
///
/// The selection control is visually subordinate to the Hero Card and serves
/// as a "collapsed" representation of the picker. It provides:
/// - Selected contact name display
/// - "Change" affordance to return to picker
/// - Compact height (~44px)
///
/// Copied from [ContactSelectionControlResolver].
@ProviderFor(ContactSelectionControlResolver)
final contactSelectionControlResolverProvider =
    AutoDisposeNotifierProvider<ContactSelectionControlResolver, void>.internal(
      ContactSelectionControlResolver.new,
      name: r'contactSelectionControlResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactSelectionControlResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactSelectionControlResolver = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
