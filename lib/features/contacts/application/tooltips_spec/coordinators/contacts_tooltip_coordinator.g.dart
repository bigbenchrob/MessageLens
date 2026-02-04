// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_tooltip_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsTooltipCoordinatorHash() =>
    r'd0d3dbba898f18034f3f5338a2569511c18547dc';

/// Contacts Tooltip Coordinator
///
/// Routes [ContactsTooltipSpec] variants to their resolvers and returns
/// the resolved tooltip text.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives a [ContactsTooltipSpec]
/// - Pattern-matches on the spec
/// - Calls the appropriate resolver
/// - Returns resolved text string
///
/// The coordinator MUST NOT:
/// - Perform IO
/// - Construct widgets
/// - Build view models itself
///
/// Copied from [ContactsTooltipCoordinator].
@ProviderFor(ContactsTooltipCoordinator)
final contactsTooltipCoordinatorProvider =
    AutoDisposeNotifierProvider<ContactsTooltipCoordinator, void>.internal(
      ContactsTooltipCoordinator.new,
      name: r'contactsTooltipCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsTooltipCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactsTooltipCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
