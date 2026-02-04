// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_name_info_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$displayNameInfoResolverHash() =>
    r'70ed5c785e5f50eb7a12deb41fda85433e4499dd';

/// Resolver for ContactsSettingsSpec.displayNameInfo().
///
/// Returns an info card explaining how to customize contact display names.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Resolvers:
/// - Own the semantic interpretation of specs
/// - Read data and make decisions
/// - Return fully-configured ViewModels
///
/// Copied from [DisplayNameInfoResolver].
@ProviderFor(DisplayNameInfoResolver)
final displayNameInfoResolverProvider =
    AutoDisposeNotifierProvider<DisplayNameInfoResolver, void>.internal(
      DisplayNameInfoResolver.new,
      name: r'displayNameInfoResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$displayNameInfoResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DisplayNameInfoResolver = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
