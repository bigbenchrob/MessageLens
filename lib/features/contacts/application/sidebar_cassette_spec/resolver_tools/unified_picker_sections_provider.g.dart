// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_picker_sections_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unifiedPickerSectionsHash() =>
    r'8468ac7e4dcff7211c421cb1ca8adb73c91b67c7';

/// Produces a unified section list for the contact picker.
///
/// When filter mode is `favorites`:
///   - Shows only favorited contacts, alphabetically sorted
///   - No limit on number of favorites
///
/// When filter mode is `all`:
///   - Shows all contacts alphabetically (A-Z sections)
///   - Favorite status preserved in [allFavoriteIds] for star indicators
///
/// Copied from [unifiedPickerSections].
@ProviderFor(unifiedPickerSections)
final unifiedPickerSectionsProvider =
    AutoDisposeFutureProvider<UnifiedPickerSections>.internal(
      unifiedPickerSections,
      name: r'unifiedPickerSectionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedPickerSectionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedPickerSectionsRef =
    AutoDisposeFutureProviderRef<UnifiedPickerSections>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
