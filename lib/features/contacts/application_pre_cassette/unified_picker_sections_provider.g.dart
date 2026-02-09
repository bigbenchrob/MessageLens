// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_picker_sections_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unifiedPickerSectionsHash() =>
    r'c43ce06d1bb6c5ec99156029d2a8c33c57069857';

/// Produces a unified section list for the contact picker by merging
/// recents, favourites, and alphabetical groups into a single flat
/// list of identically-styled sections.
///
/// **Precedence (hard invariant — see RECENTS-FAVORITES.md):**
///   RECENTS > FAVORITES > ALPHABETICAL
///
/// A contact appears in exactly one section. Recents outrank favourites,
/// favourites outrank alphabetical. Favourite *status* is preserved in
/// [UnifiedPickerSections.allFavoriteIds] for semantic indicators.
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
