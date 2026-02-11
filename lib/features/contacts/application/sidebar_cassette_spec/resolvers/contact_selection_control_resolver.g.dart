// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_selection_control_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactSelectionControlResolverHash() =>
    r'5d1b3d2e4d7e89b9371c92a16dc7cd1be24ee65f';

/// Resolves the "back to picker" selection control.
///
/// The selection control is **navigation, not content and not identity**.
/// It uses [CassetteCardType.sidebarNavigation] — a full-bleed card type
/// purpose-built for "back to previous state" navigation affordances.
/// No card chrome, no shadow, no contact name.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Determines which widget builder to use
/// - Does NOT construct widgets itself (delegates to widget builder)
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
