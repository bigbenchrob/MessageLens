// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeSidebarModeHash() => r'93d365ba34efdd8819218b9ff448f011d2d2994d';

/// Controls the active sidebar mode (Messages vs Settings).
///
/// Copied from [ActiveSidebarMode].
@ProviderFor(ActiveSidebarMode)
final activeSidebarModeProvider =
    AutoDisposeNotifierProvider<ActiveSidebarMode, SidebarMode>.internal(
      ActiveSidebarMode.new,
      name: r'activeSidebarModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeSidebarModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveSidebarMode = AutoDisposeNotifier<SidebarMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
