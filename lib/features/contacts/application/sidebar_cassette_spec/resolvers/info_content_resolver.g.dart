// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_content_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsInfoContentResolverHash() =>
    r'c0a1f78181ed15cde260efa889d5b04f7edf30da';

/// Resolves info card content for [ContactsInfoKey] values.
///
/// This resolver maps semantic keys to the actual text content displayed
/// in info cards. This keeps the text owned by the feature while allowing
/// the essentials layer to request it via keys.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (the info key)
/// - Returns resolved content (not view models or widgets)
/// - Owns the meaning of each key
///
/// Copied from [ContactsInfoContentResolver].
@ProviderFor(ContactsInfoContentResolver)
final contactsInfoContentResolverProvider =
    AutoDisposeNotifierProvider<ContactsInfoContentResolver, void>.internal(
      ContactsInfoContentResolver.new,
      name: r'contactsInfoContentResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsInfoContentResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactsInfoContentResolver = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
