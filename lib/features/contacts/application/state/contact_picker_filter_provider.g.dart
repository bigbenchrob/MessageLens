// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_picker_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactPickerFilterHash() =>
    r'51727b72a731a0326f933c0635f2c478636a6f0f';

/// Provides and controls the current contact picker filter mode.
///
/// This is a global state provider that the filter switcher writes to
/// and the contact picker reads from.
///
/// Copied from [ContactPickerFilter].
@ProviderFor(ContactPickerFilter)
final contactPickerFilterProvider =
    NotifierProvider<ContactPickerFilter, ContactPickerFilterMode>.internal(
      ContactPickerFilter.new,
      name: r'contactPickerFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactPickerFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactPickerFilter = Notifier<ContactPickerFilterMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
