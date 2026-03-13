// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handle_display_name_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handleDisplayNameHash() => r'ede41016b3bd38295413d9b972b75c91174ec556';

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

/// Resolves the display name for a handle, checking overlay overrides first.
///
/// Priority: virtual participant name > real participant name > raw handle value.
///
/// Copied from [handleDisplayName].
@ProviderFor(handleDisplayName)
const handleDisplayNameProvider = HandleDisplayNameFamily();

/// Resolves the display name for a handle, checking overlay overrides first.
///
/// Priority: virtual participant name > real participant name > raw handle value.
///
/// Copied from [handleDisplayName].
class HandleDisplayNameFamily extends Family<AsyncValue<String>> {
  /// Resolves the display name for a handle, checking overlay overrides first.
  ///
  /// Priority: virtual participant name > real participant name > raw handle value.
  ///
  /// Copied from [handleDisplayName].
  const HandleDisplayNameFamily();

  /// Resolves the display name for a handle, checking overlay overrides first.
  ///
  /// Priority: virtual participant name > real participant name > raw handle value.
  ///
  /// Copied from [handleDisplayName].
  HandleDisplayNameProvider call({required int handleId}) {
    return HandleDisplayNameProvider(handleId: handleId);
  }

  @override
  HandleDisplayNameProvider getProviderOverride(
    covariant HandleDisplayNameProvider provider,
  ) {
    return call(handleId: provider.handleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'handleDisplayNameProvider';
}

/// Resolves the display name for a handle, checking overlay overrides first.
///
/// Priority: virtual participant name > real participant name > raw handle value.
///
/// Copied from [handleDisplayName].
class HandleDisplayNameProvider extends AutoDisposeFutureProvider<String> {
  /// Resolves the display name for a handle, checking overlay overrides first.
  ///
  /// Priority: virtual participant name > real participant name > raw handle value.
  ///
  /// Copied from [handleDisplayName].
  HandleDisplayNameProvider({required int handleId})
    : this._internal(
        (ref) =>
            handleDisplayName(ref as HandleDisplayNameRef, handleId: handleId),
        from: handleDisplayNameProvider,
        name: r'handleDisplayNameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$handleDisplayNameHash,
        dependencies: HandleDisplayNameFamily._dependencies,
        allTransitiveDependencies:
            HandleDisplayNameFamily._allTransitiveDependencies,
        handleId: handleId,
      );

  HandleDisplayNameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.handleId,
  }) : super.internal();

  final int handleId;

  @override
  Override overrideWith(
    FutureOr<String> Function(HandleDisplayNameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HandleDisplayNameProvider._internal(
        (ref) => create(ref as HandleDisplayNameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        handleId: handleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _HandleDisplayNameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HandleDisplayNameProvider && other.handleId == handleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, handleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HandleDisplayNameRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `handleId` of this provider.
  int get handleId;
}

class _HandleDisplayNameProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with HandleDisplayNameRef {
  _HandleDisplayNameProviderElement(super.provider);

  @override
  int get handleId => (origin as HandleDisplayNameProvider).handleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
