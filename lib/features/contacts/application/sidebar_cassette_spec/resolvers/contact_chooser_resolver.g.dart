// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_chooser_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactChooserResolverHash() =>
    r'4dbe9e52fc6d60b4b0182d8575b89e7aa4bf15d6';

/// Resolves a contact chooser cassette.
///
/// This resolver determines the correct content for the contact chooser
/// cassette by:
/// 1. Fetching contact count from the repository
/// 2. Using [determinePickerMode] to decide flat vs grouped display
/// 3. Wrapping the picker with recent contacts section
/// 4. Returning a view model with the appropriate widget builder
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Determines which widget builder to use
/// - Owns all decision-making for this cassette
///
/// Resolvers MUST NOT:
/// - Accept a spec object
/// - Read a spec from shared state
/// - Return widgets, builders, or partial results
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
