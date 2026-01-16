// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_short_names_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactShortNamesHash() => r'a6419cc58d9a5139ca680fbc3ab1ea8942284afa';

/// Controller for managing contact short names (nicknames) that override
/// the default display name for participants.
///
/// This stores user-defined nicknames in the overlay database, keyed by
/// 'participant:{id}'. These nicknames persist across re-imports and are
/// displayed throughout the app when the user has set the name mode to
/// "nickname".
///
/// Copied from [ContactShortNames].
@ProviderFor(ContactShortNames)
final contactShortNamesProvider =
    AutoDisposeAsyncNotifierProvider<
      ContactShortNames,
      Map<String, String>
    >.internal(
      ContactShortNames.new,
      name: r'contactShortNamesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactShortNamesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactShortNames = AutoDisposeAsyncNotifier<Map<String, String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
