// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_navigation_restoration_policy_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sidebarNavigationRestorationEnabledHash() =>
    r'aa11165c100a3ad6144761676b5b6face5c8c472';

/// Controls whether a newly constructed sidebar flow may restore durable
/// semantic navigation from the preference store.
///
/// Legacy compositions retain restoration by default. Compositions that need
/// a neutral first frame can override this at their root provider scope without
/// disabling persistence of subsequent same-session navigation mutations.
///
/// Copied from [sidebarNavigationRestorationEnabled].
@ProviderFor(sidebarNavigationRestorationEnabled)
final sidebarNavigationRestorationEnabledProvider =
    AutoDisposeProvider<bool>.internal(
      sidebarNavigationRestorationEnabled,
      name: r'sidebarNavigationRestorationEnabledProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sidebarNavigationRestorationEnabledHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SidebarNavigationRestorationEnabledRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
