// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participants_for_picker_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$participantsForPickerHash() =>
    r'1595164ea4081f58d15af2219456c14ad549591a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider that fetches participants filtered by search query
///
/// This is used by the ContactPickerDialog to show searchable participants.
/// The search is case-insensitive and matches against display_name and short_name.
///
/// Copied from [participantsForPicker].
@ProviderFor(participantsForPicker)
const participantsForPickerProvider = ParticipantsForPickerFamily();

/// Provider that fetches participants filtered by search query
///
/// This is used by the ContactPickerDialog to show searchable participants.
/// The search is case-insensitive and matches against display_name and short_name.
///
/// Copied from [participantsForPicker].
class ParticipantsForPickerFamily
    extends Family<AsyncValue<List<ParticipantForPicker>>> {
  /// Provider that fetches participants filtered by search query
  ///
  /// This is used by the ContactPickerDialog to show searchable participants.
  /// The search is case-insensitive and matches against display_name and short_name.
  ///
  /// Copied from [participantsForPicker].
  const ParticipantsForPickerFamily();

  /// Provider that fetches participants filtered by search query
  ///
  /// This is used by the ContactPickerDialog to show searchable participants.
  /// The search is case-insensitive and matches against display_name and short_name.
  ///
  /// Copied from [participantsForPicker].
  ParticipantsForPickerProvider call({required String searchQuery}) {
    return ParticipantsForPickerProvider(searchQuery: searchQuery);
  }

  @override
  ParticipantsForPickerProvider getProviderOverride(
    covariant ParticipantsForPickerProvider provider,
  ) {
    return call(searchQuery: provider.searchQuery);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'participantsForPickerProvider';
}

/// Provider that fetches participants filtered by search query
///
/// This is used by the ContactPickerDialog to show searchable participants.
/// The search is case-insensitive and matches against display_name and short_name.
///
/// Copied from [participantsForPicker].
class ParticipantsForPickerProvider
    extends AutoDisposeFutureProvider<List<ParticipantForPicker>> {
  /// Provider that fetches participants filtered by search query
  ///
  /// This is used by the ContactPickerDialog to show searchable participants.
  /// The search is case-insensitive and matches against display_name and short_name.
  ///
  /// Copied from [participantsForPicker].
  ParticipantsForPickerProvider({required String searchQuery})
    : this._internal(
        (ref) => participantsForPicker(
          ref as ParticipantsForPickerRef,
          searchQuery: searchQuery,
        ),
        from: participantsForPickerProvider,
        name: r'participantsForPickerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$participantsForPickerHash,
        dependencies: ParticipantsForPickerFamily._dependencies,
        allTransitiveDependencies:
            ParticipantsForPickerFamily._allTransitiveDependencies,
        searchQuery: searchQuery,
      );

  ParticipantsForPickerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
  }) : super.internal();

  final String searchQuery;

  @override
  Override overrideWith(
    FutureOr<List<ParticipantForPicker>> Function(
      ParticipantsForPickerRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ParticipantsForPickerProvider._internal(
        (ref) => create(ref as ParticipantsForPickerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ParticipantForPicker>> createElement() {
    return _ParticipantsForPickerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ParticipantsForPickerProvider &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ParticipantsForPickerRef
    on AutoDisposeFutureProviderRef<List<ParticipantForPicker>> {
  /// The parameter `searchQuery` of this provider.
  String get searchQuery;
}

class _ParticipantsForPickerProviderElement
    extends AutoDisposeFutureProviderElement<List<ParticipantForPicker>>
    with ParticipantsForPickerRef {
  _ParticipantsForPickerProviderElement(super.provider);

  @override
  String get searchQuery =>
      (origin as ParticipantsForPickerProvider).searchQuery;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
