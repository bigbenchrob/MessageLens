// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsCassetteCoordinatorHash() =>
    r'f2421d9c68b9254a52dbf754ed7d6bc787c94ec3';

/// Contacts CassetteCoordinator
///
/// This coordinator is part of the Contacts feature and is responsible for
/// *routing only*:
///
/// - Accept a ContactsCassetteSpec (sidebar protocol entity)
/// - Pattern-match on the spec variant
/// - Extract payload parameters
/// - Call exactly ONE resolver
/// - Return the resolver's Future<SidebarCassetteCardViewModel>
///
/// Why return a view model instead of a widget?
///
/// - The app-level CassetteWidgetCoordinator centralizes UI chrome decisions.
/// - This keeps card layout/padding/header policies consistent across features.
/// - Features remain agnostic to how cards are visually framed.
/// - Future changes to card chrome happen in one place, not N features.
///
/// The coordinator:
/// - MUST NOT perform IO
/// - MUST NOT construct widgets
/// - MUST NOT build view models itself
/// - MUST NOT pass specs beyond this layer
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md
///
/// Copied from [ContactsCassetteCoordinator].
@ProviderFor(ContactsCassetteCoordinator)
final contactsCassetteCoordinatorProvider =
    AutoDisposeNotifierProvider<ContactsCassetteCoordinator, void>.internal(
      ContactsCassetteCoordinator.new,
      name: r'contactsCassetteCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsCassetteCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactsCassetteCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
