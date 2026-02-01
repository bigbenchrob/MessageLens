// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_chooser_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactChooserResolverHash() =>
    r'a19576aee025a1688d59d4553df0571378bebe4d';

/// Resolves a contact chooser cassette.
///
/// This resolver determines the correct content for the contact chooser/recent
/// contacts cassette and returns a fully-realized [SidebarCassetteCardViewModel].
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Determines which widget builder to use
/// - Does NOT construct widgets itself (delegates to widget builder)
///
/// ## Parameters
///
/// - [chosenContactId] - Currently selected contact, if any
/// - [cassetteIndex] - Position in the cassette rack (for updates)
/// - [showRecentContacts] - Whether to prioritize recent contacts display
///
/// Copied from [ContactChooserResolver].
@ProviderFor(ContactChooserResolver)
final contactChooserResolverProvider =
    AutoDisposeNotifierProvider<ContactChooserResolver, void>.internal(
      ContactChooserResolver.new,
      name: r'contactChooserResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactChooserResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactChooserResolver = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
