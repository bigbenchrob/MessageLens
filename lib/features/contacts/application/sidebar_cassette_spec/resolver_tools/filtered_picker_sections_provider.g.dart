// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filtered_picker_sections_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredPickerSectionsHash() =>
    r'68a5ed0ccde25b32a46e2c531ae2760762dc15ca';

/// Produces picker sections filtered by the current [PickerFilterMode].
///
/// - **all**: Every contact grouped A–Z (no RECENTS / FAVORITES headers).
/// - **favouritesOnly**: Only favourites, still grouped A–Z.
///
/// Recents tracking continues behind the scenes via
/// [unifiedPickerSectionsProvider] and [recentContactsProvider].
///
/// Copied from [filteredPickerSections].
@ProviderFor(filteredPickerSections)
final filteredPickerSectionsProvider =
    AutoDisposeFutureProvider<UnifiedPickerSections>.internal(
      filteredPickerSections,
      name: r'filteredPickerSectionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredPickerSectionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredPickerSectionsRef =
    AutoDisposeFutureProviderRef<UnifiedPickerSections>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
