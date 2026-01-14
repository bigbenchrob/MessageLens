// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_name_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactNameModeHash() => r'f117960c483c6d6ab0c21837b2a69fcfd1a7aaa9';

/// Key provider for the global default contact name mode.
///
/// Reads the persisted preference from the overlay database and falls back to
/// [ParticipantNameMode.firstNameOnly] when no explicit override exists yet.
///
/// Copied from [contactNameMode].
@ProviderFor(contactNameMode)
final contactNameModeProvider =
    AutoDisposeFutureProvider<ParticipantNameMode>.internal(
      contactNameMode,
      name: r'contactNameModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactNameModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactNameModeRef = AutoDisposeFutureProviderRef<ParticipantNameMode>;
String _$setContactNameModeHash() =>
    r'08707b5280492cd42aa1f7c083e920c0d3979e34';

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

/// Command provider for updating the global contact name mode preference.
///
/// Persists the new mode in the overlay database and invalidates the
/// [contactNameModeProvider] so dependents refresh automatically.
///
/// Copied from [setContactNameMode].
@ProviderFor(setContactNameMode)
const setContactNameModeProvider = SetContactNameModeFamily();

/// Command provider for updating the global contact name mode preference.
///
/// Persists the new mode in the overlay database and invalidates the
/// [contactNameModeProvider] so dependents refresh automatically.
///
/// Copied from [setContactNameMode].
class SetContactNameModeFamily extends Family<AsyncValue<void>> {
  /// Command provider for updating the global contact name mode preference.
  ///
  /// Persists the new mode in the overlay database and invalidates the
  /// [contactNameModeProvider] so dependents refresh automatically.
  ///
  /// Copied from [setContactNameMode].
  const SetContactNameModeFamily();

  /// Command provider for updating the global contact name mode preference.
  ///
  /// Persists the new mode in the overlay database and invalidates the
  /// [contactNameModeProvider] so dependents refresh automatically.
  ///
  /// Copied from [setContactNameMode].
  SetContactNameModeProvider call(ParticipantNameMode mode) {
    return SetContactNameModeProvider(mode);
  }

  @override
  SetContactNameModeProvider getProviderOverride(
    covariant SetContactNameModeProvider provider,
  ) {
    return call(provider.mode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'setContactNameModeProvider';
}

/// Command provider for updating the global contact name mode preference.
///
/// Persists the new mode in the overlay database and invalidates the
/// [contactNameModeProvider] so dependents refresh automatically.
///
/// Copied from [setContactNameMode].
class SetContactNameModeProvider extends AutoDisposeFutureProvider<void> {
  /// Command provider for updating the global contact name mode preference.
  ///
  /// Persists the new mode in the overlay database and invalidates the
  /// [contactNameModeProvider] so dependents refresh automatically.
  ///
  /// Copied from [setContactNameMode].
  SetContactNameModeProvider(ParticipantNameMode mode)
    : this._internal(
        (ref) => setContactNameMode(ref as SetContactNameModeRef, mode),
        from: setContactNameModeProvider,
        name: r'setContactNameModeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$setContactNameModeHash,
        dependencies: SetContactNameModeFamily._dependencies,
        allTransitiveDependencies:
            SetContactNameModeFamily._allTransitiveDependencies,
        mode: mode,
      );

  SetContactNameModeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mode,
  }) : super.internal();

  final ParticipantNameMode mode;

  @override
  Override overrideWith(
    FutureOr<void> Function(SetContactNameModeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SetContactNameModeProvider._internal(
        (ref) => create(ref as SetContactNameModeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mode: mode,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _SetContactNameModeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SetContactNameModeProvider && other.mode == mode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SetContactNameModeRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `mode` of this provider.
  ParticipantNameMode get mode;
}

class _SetContactNameModeProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with SetContactNameModeRef {
  _SetContactNameModeProviderElement(super.provider);

  @override
  ParticipantNameMode get mode => (origin as SetContactNameModeProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
