// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_widget_coordinator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cassetteWidgetCoordinatorHash() =>
    r'7fba19db9c1d240e14e83c5826f86ff70779f153';

/// Coordinates the construction of sidebar utility cassettes.
///
/// This provider reads the current [CassetteRack] from
/// [cassetteRackStateProvider] and transforms each [CassetteSpec] into
/// the corresponding [Widget] via the appropriate builder.  At this stage
/// only the top chat menu cassette is supported; additional cassette types
/// should be handled here as they are implemented.
/// Coordinates the construction of sidebar utility cassettes as a class-based
/// Riverpod notifier.
///
/// This notifier listens to the [cassetteRackStateProvider] and rebuilds
/// whenever the rack changes.  It converts each [CassetteSpec] in the rack
/// into a concrete [Widget] by delegating to the appropriate builder.
/// Currently only the top chat menu is supported.  Additional cassette
/// variants (e.g. unmatched handles, all messages) should be handled here as
/// they are implemented.
///
/// Copied from [CassetteWidgetCoordinator].
@ProviderFor(CassetteWidgetCoordinator)
final cassetteWidgetCoordinatorProvider =
    AutoDisposeNotifierProvider<
      CassetteWidgetCoordinator,
      List<Widget>
    >.internal(
      CassetteWidgetCoordinator.new,
      name: r'cassetteWidgetCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cassetteWidgetCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CassetteWidgetCoordinator = AutoDisposeNotifier<List<Widget>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
